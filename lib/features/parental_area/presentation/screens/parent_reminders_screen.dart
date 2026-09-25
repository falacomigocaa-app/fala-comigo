import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/transition_alert_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/parent_reminders.dart';

const _weekdayLabels = {1: 'D', 2: 'S', 3: 'T', 4: 'Q', 5: 'Q', 6: 'S', 7: 'S'};

class ParentRemindersScreen extends StatefulWidget {
  const ParentRemindersScreen({super.key});

  @override
  State<ParentRemindersScreen> createState() => _ParentRemindersScreenState();
}

class _ParentRemindersScreenState extends State<ParentRemindersScreen> {
  List<ParentReminder> _reminders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reminders = await ParentReminderStore.load();
    if (!mounted) return;
    setState(() {
      _reminders = reminders;
      _loading = false;
    });
  }

  Future<void> _save() => ParentReminderStore.save(_reminders);

  Future<void> _requestPermissions() async {
    await TransitionAlertService.instance.requestPermissions();
    if (!mounted) return;
    final status =
        await TransitionAlertService.instance.checkPermissionStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
  }

  Future<void> _addReminder() async {
    final result = await showDialog<_ReminderDraft>(
      context: context,
      builder: (_) => const _ReminderDialog(),
    );
    if (result == null || result.weekdays.isEmpty) return;
    final reminder = ParentReminder(
      id: const Uuid().v4(),
      label: result.label,
      hour: result.time.hour,
      minute: result.time.minute,
      weekdays: result.weekdays,
      notificationId: DateTime.now().millisecondsSinceEpoch.remainder(
            1000000000,
          ),
    );
    try {
      await TransitionAlertService.instance.scheduleParentReminder(
        notificationId: reminder.notificationId,
        hour: reminder.hour,
        minute: reminder.minute,
        weekdays: reminder.weekdays,
      );
      setState(() => _reminders.add(reminder));
      await _save();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível agendar o lembrete.')),
        );
      }
    }
  }

  Future<void> _deleteReminder(ParentReminder reminder) async {
    await TransitionAlertService.instance.cancelParentReminder(
      reminder.notificationId,
    );
    setState(() => _reminders.removeWhere((item) => item.id == reminder.id));
    await _save();
  }

  String _summary(ParentReminder reminder) {
    final days = reminder.weekdays.map((day) => _weekdayLabels[day]).join(' ');
    final hour = reminder.hour.toString().padLeft(2, '0');
    final minute = reminder.minute.toString().padLeft(2, '0');
    return '$days • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lembretes da rotina'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Novo lembrete'),
        backgroundColor: AppTheme.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.professionalBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        color: AppTheme.professionalAccent,
                        size: 28,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Lembretes locais para o responsável consultar a rotina. O texto da notificação é sempre genérico.',
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.35,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _requestPermissions,
                  icon: const Icon(Icons.security_outlined),
                  label: const Text('Verificar permissões'),
                ),
                const SizedBox(height: 16),
                if (_reminders.isEmpty)
                  const _EmptyReminders()
                else
                  ..._reminders.map(
                    (reminder) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.alarm_outlined,
                          color: AppTheme.primary,
                          size: 30,
                        ),
                        title: Text(
                          reminder.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(_summary(reminder)),
                        trailing: IconButton(
                          onPressed: () => _deleteReminder(reminder),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Excluir lembrete',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ReminderDraft {
  final String label;
  final TimeOfDay time;
  final List<int> weekdays;

  const _ReminderDraft(this.label, this.time, this.weekdays);
}

class _ReminderDialog extends StatefulWidget {
  const _ReminderDialog();

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  final _labelController = TextEditingController(text: 'Consultar a rotina');
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  final _weekdays = <int>{2, 3, 4, 5, 6};

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo lembrete'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Nome no aplicativo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
              icon: const Icon(Icons.access_time),
              label: Text('Horário: ${_time.format(context)}'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dias da semana',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 4,
              children: _weekdayLabels.entries
                  .map(
                    (entry) => FilterChip(
                      label: Text(entry.value),
                      selected: _weekdays.contains(entry.key),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _weekdays.add(entry.key);
                        } else {
                          _weekdays.remove(entry.key);
                        }
                      }),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _weekdays.isEmpty || _labelController.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    _ReminderDraft(
                      _labelController.text.trim(),
                      _time,
                      _weekdays.toList()..sort(),
                    ),
                  ),
          child: const Text('Agendar'),
        ),
      ],
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 44,
            color: AppTheme.primary,
          ),
          SizedBox(height: 10),
          Text(
            'Nenhum lembrete configurado.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            'Os lembretes são opcionais e podem ser removidos a qualquer momento.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedText),
          ),
        ],
      ),
    );
  }
}
