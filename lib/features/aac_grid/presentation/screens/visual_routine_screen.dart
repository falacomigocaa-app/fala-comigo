import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/providers/visual_routine_provider.dart';

class VisualRoutineScreen extends StatefulWidget {
  final bool readOnly;

  const VisualRoutineScreen({super.key, this.readOnly = true});

  @override
  State<VisualRoutineScreen> createState() => _VisualRoutineScreenState();
}

class _VisualRoutineScreenState extends State<VisualRoutineScreen> {
  final _titleController = TextEditingController();
  final _emojiController = TextEditingController(text: '⭐');
  List<VisualRoutineItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await VisualRoutineStore.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _save() => VisualRoutineStore.save(_items);

  Future<void> _toggle(int index) async {
    setState(() {
      _items[index] = _items[index].copyWith(
        completed: !_items[index].completed,
      );
    });
    await _save();
  }

  Future<void> _resetDay() async {
    setState(() {
      _items = _items.map((item) => item.copyWith(completed: false)).toList();
    });
    await _save();
  }

  Future<void> _addItem() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _items.add(VisualRoutineItem(
        id: VisualRoutineStore.newId(),
        title: title,
        emoji: _emojiController.text.trim().isEmpty
            ? '⭐'
            : _emojiController.text.trim(),
      ));
      _titleController.clear();
      _emojiController.text = '⭐';
    });
    await _save();
  }

  Future<void> _removeItem(int index) async {
    setState(() => _items.removeAt(index));
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final completed = _items.where((item) => item.completed).length;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Rotina visual'),
        backgroundColor: widget.readOnly
            ? AppTheme.primary
            : AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              onPressed: _resetDay,
              tooltip: 'Recomeçar a rotina',
              icon: const Icon(Icons.refresh_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _RoutineHeader(
                  readOnly: widget.readOnly,
                  completed: completed,
                  total: _items.length,
                ),
                const SizedBox(height: 16),
                if (_items.isEmpty)
                  const _EmptyRoutine()
                else
                  ..._items.asMap().entries.map(
                        (entry) => _RoutineItemTile(
                          item: entry.value,
                          readOnly: widget.readOnly,
                          onTap: () => _toggle(entry.key),
                          onDelete: widget.readOnly
                              ? null
                              : () => _removeItem(entry.key),
                        ),
                      ),
                if (!widget.readOnly) ...[
                  const SizedBox(height: 18),
                  _AddRoutineItem(
                    titleController: _titleController,
                    emojiController: _emojiController,
                    onAdd: _addItem,
                  ),
                ],
              ],
            ),
    );
  }
}

class _RoutineHeader extends StatelessWidget {
  final bool readOnly;
  final int completed;
  final int total;

  const _RoutineHeader({
    required this.readOnly,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: readOnly ? AppTheme.primary : AppTheme.professionalBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🗓️', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  readOnly ? 'O que vem agora?' : 'Organize o dia',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  total == 0
                      ? 'O responsável pode adicionar passos simples para a rotina.'
                      : '$completed de $total itens marcados. Você pode mudar a ordem do seu dia.',
                  style: const TextStyle(
                      color: Colors.white70, height: 1.35, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineItemTile extends StatelessWidget {
  final VisualRoutineItem item;
  final bool readOnly;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _RoutineItemTile({
    required this.item,
    required this.readOnly,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: item.completed
          ? AppTheme.accentGreen.withValues(alpha: 0.12)
          : AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: item.completed ? AppTheme.accentGreen : AppTheme.cardBorder,
          width: item.completed ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Text(item.emoji, style: const TextStyle(fontSize: 30)),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            decoration: item.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
            item.completed ? 'Concluído por agora' : 'Toque quando quiser'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: item.completed,
              onChanged: (_) => onTap(),
              semanticLabel: 'Marcar ${item.title}',
            ),
            if (!readOnly)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remover ${item.title}',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _AddRoutineItem extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController emojiController;
  final VoidCallback onAdd;

  const _AddRoutineItem({
    required this.titleController,
    required this.emojiController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Adicionar passo',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 62,
                  child: TextField(
                    controller: emojiController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        labelText: 'Ícone', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: titleController,
                    onSubmitted: (_) => onAdd(),
                    decoration: const InputDecoration(
                        labelText: 'Ex.: Lavar as mãos',
                        border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar à rotina'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutine extends StatelessWidget {
  const _EmptyRoutine();

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
          Icon(Icons.view_timeline_outlined, size: 46, color: AppTheme.primary),
          SizedBox(height: 10),
          Text('Nenhum passo foi adicionado ainda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          SizedBox(height: 5),
          Text('A rotina é opcional e pode mudar conforme o dia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedText)),
        ],
      ),
    );
  }
}
