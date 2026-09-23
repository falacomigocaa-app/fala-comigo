import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/shared_tasks.dart';
import '../widgets/parental_ui.dart';

class SharedTasksScreen extends StatefulWidget {
  const SharedTasksScreen({super.key});

  @override
  State<SharedTasksScreen> createState() => _SharedTasksScreenState();
}

class _SharedTasksScreenState extends State<SharedTasksScreen> {
  final _uuid = Uuid();
  List<SharedTask> _tasks = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final tasks = await SharedTaskStore.load();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _createTask() async {
    final task = await showModalBottomSheet<SharedTask>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TaskForm(id: _uuid.v4()),
    );
    if (task == null) return;
    await SharedTaskStore.save(task);
    if (!mounted) return;
    setState(() => _tasks = [..._tasks, task]..sort((a, b) => a.dueAt.compareTo(b.dueAt)));
  }

  Future<void> _changeStatus(SharedTask task, SharedTaskStatus status) async {
    String? feedback = task.feedback;
    if (status == SharedTaskStatus.needsHelp ||
        status == SharedTaskStatus.declined ||
        status == SharedTaskStatus.partiallyCompleted) {
      feedback = await _askFeedback(status);
      if (!mounted) return;
    }
    final updated = task.copyWith(
      status: status,
      feedback: feedback,
      updatedAt: DateTime.now(),
    );
    await SharedTaskStore.save(updated);
    if (!mounted) return;
    setState(() => _tasks = _tasks
        .map((item) => item.id == task.id ? updated : item)
        .toList());
  }

  Future<String?> _askFeedback(SharedTaskStatus status) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(switch (status) {
          SharedTaskStatus.needsHelp => 'O que precisa de ajuda?',
          SharedTaskStatus.declined => 'Quer registrar o motivo?',
          _ => 'Como foi a tarefa?',
        }),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Opcional, mas ajuda a equipe a entender o contexto.'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Pular')),
          FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Salvar retorno')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tarefas compartilhadas'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Nova tarefa'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              children: [
                const ParentalSectionHeading(
                  eyebrow: 'COORDENAÇÃO DO CUIDADO',
                  title: 'Tarefas que conectam',
                  description:
                      'Família, escola e profissionais podem combinar o próximo passo sem perder o contexto.',
                ),
                const SizedBox(height: 18),
                const ParentalInfoBanner(
                  icon: Icons.handshake_outlined,
                  eyebrow: 'RETORNO SEM CULPA',
                  message:
                      'Não realizada, recusada e preciso de ajuda são respostas válidas. Elas orientam o próximo apoio e não penalizam a criança.',
                ),
                const SizedBox(height: 18),
                if (_tasks.isEmpty)
                  const ParentalSurface(
                    child: Column(
                      children: [
                        Icon(Icons.checklist_outlined,
                            size: 42, color: AppTheme.primary),
                        SizedBox(height: 10),
                        Text('Nenhuma tarefa compartilhada',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800)),
                        SizedBox(height: 5),
                        Text(
                          'Crie uma tarefa para a família, escola ou profissional acompanhar um próximo passo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.mutedText, height: 1.35),
                        ),
                      ],
                    ),
                  )
                else
                  ..._tasks.map((task) => _TaskCard(
                        task: task,
                        onStatus: (status) => _changeStatus(task, status),
                      )),
              ],
            ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final SharedTask task;
  final ValueChanged<SharedTaskStatus> onStatus;

  const _TaskCard({required this.task, required this.onStatus});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(task.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(task.title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              PopupMenuButton<SharedTaskStatus>(
                tooltip: 'Atualizar tarefa',
                onSelected: onStatus,
                itemBuilder: (_) => [
                  for (final status in [
                    SharedTaskStatus.inProgress,
                    SharedTaskStatus.completed,
                    SharedTaskStatus.partiallyCompleted,
                    SharedTaskStatus.needsHelp,
                    SharedTaskStatus.declined,
                  ])
                    PopupMenuItem(value: status, child: Text(_label(status))),
                ],
              ),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(task.description,
                style: const TextStyle(color: AppTheme.mutedText, height: 1.3)),
          ],
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              _MetaChip(icon: Icons.person_outline, label: task.assignedTo),
              _MetaChip(icon: Icons.category_outlined, label: task.contextLabel),
              _MetaChip(icon: Icons.event_outlined, label: _date(task.dueAt)),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(task.statusLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              if (task.reminderEnabled)
                const Icon(Icons.notifications_active_outlined,
                    size: 18, color: AppTheme.mutedText),
            ],
          ),
          if (task.feedback?.isNotEmpty == true) ...[
            const Divider(height: 22),
            Text('Retorno: ${task.feedback}',
                style: const TextStyle(color: AppTheme.mutedText, height: 1.3)),
          ],
        ],
      ),
    );
  }

  static Color _statusColor(SharedTaskStatus status) => switch (status) {
        SharedTaskStatus.completed => AppTheme.accentGreen,
        SharedTaskStatus.needsHelp => Colors.orange.shade800,
        SharedTaskStatus.declined => Colors.redAccent,
        SharedTaskStatus.cancelled => AppTheme.mutedText,
        _ => AppTheme.primary,
      };

  static String _label(SharedTaskStatus status) => switch (status) {
        SharedTaskStatus.inProgress => 'Em andamento',
        SharedTaskStatus.completed => 'Concluída',
        SharedTaskStatus.partiallyCompleted => 'Concluída parcialmente',
        SharedTaskStatus.needsHelp => 'Preciso de ajuda',
        SharedTaskStatus.declined => 'Não realizada',
        _ => 'Atualizar',
      };

  static String _date(DateTime date) =>
      'Até ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 16, color: AppTheme.mutedText),
        label: Text(label),
        visualDensity: VisualDensity.compact,
        side: const BorderSide(color: AppTheme.cardBorder),
      );
}

class _TaskForm extends StatefulWidget {
  final String id;

  const _TaskForm({required this.id});

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _assignedTo = TextEditingController(text: 'Família');
  final _context = TextEditingController(text: 'Rotina');
  DateTime _dueAt = DateTime.now().add(const Duration(days: 1));
  bool _reminder = true;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _assignedTo.dispose();
    _context.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _dueAt,
    );
    if (selected == null || !mounted) return;
    setState(() => _dueAt = DateTime(
        selected.year, selected.month, selected.day, _dueAt.hour, _dueAt.minute));
  }

  void _submit() {
    if (_title.text.trim().isEmpty || _assignedTo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe o título e quem receberá a tarefa.')));
      return;
    }
    final now = DateTime.now();
    Navigator.of(context).pop(SharedTask(
      id: widget.id,
      title: _title.text.trim(),
      description: _description.text.trim(),
      createdBy: 'Família',
      assignedTo: _assignedTo.text.trim(),
      contextLabel: _context.text.trim().isEmpty ? 'Rotina' : _context.text.trim(),
      dueAt: _dueAt,
      reminderEnabled: _reminder,
      status: SharedTaskStatus.pending,
      feedback: null,
      createdAt: now,
      updatedAt: now,
    ));
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ParentalSectionHeading(
                  eyebrow: 'NOVA TAREFA',
                  title: 'Combinar o próximo passo',
                  description:
                      'A tarefa pode ser ajustada, adiada ou respondida com um pedido de ajuda.',
                ),
                const SizedBox(height: 18),
                TextField(
                    controller: _title,
                    autofocus: true,
                    decoration: parentalInputDecoration(
                        labelText: 'Título curto', icon: Icons.title_outlined)),
                const SizedBox(height: 12),
                TextField(
                    controller: _description,
                    maxLines: 3,
                    decoration: parentalInputDecoration(
                        labelText: 'Instrução ou materiais (opcional)',
                        icon: Icons.notes_outlined)),
                const SizedBox(height: 12),
                TextField(
                    controller: _assignedTo,
                    decoration: parentalInputDecoration(
                        labelText: 'Para quem?', icon: Icons.person_outline)),
                const SizedBox(height: 12),
                TextField(
                    controller: _context,
                    decoration: parentalInputDecoration(
                        labelText: 'Contexto', icon: Icons.category_outlined)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Prazo'),
                  subtitle: Text(
                      '${_dueAt.day.toString().padLeft(2, '0')}/${_dueAt.month.toString().padLeft(2, '0')}/${_dueAt.year}'),
                  onTap: _pickDate,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Lembrar no aparelho'),
                  subtitle: const Text('O agendamento será conectado na próxima etapa.'),
                  value: _reminder,
                  onChanged: (value) => setState(() => _reminder = value),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_outlined),
                  label: const Text('Criar tarefa'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: AppTheme.professionalBackground,
                      foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
}
