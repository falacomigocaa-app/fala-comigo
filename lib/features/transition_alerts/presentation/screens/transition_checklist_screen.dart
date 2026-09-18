import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/hyperfocus_theme.dart';
import '../../domain/models/transition_alert.dart';

/// Checklist gamificado mostrado depois do alerta de transição: cada
/// item marcado acende uma estrela; ao concluir tudo, toca uma
/// mensagem de parabéns falada.
class TransitionChecklistScreen extends ConsumerStatefulWidget {
  final TransitionAlert alert;

  const TransitionChecklistScreen({super.key, required this.alert});

  @override
  ConsumerState<TransitionChecklistScreen> createState() =>
      _TransitionChecklistScreenState();
}

class _TransitionChecklistScreenState
    extends ConsumerState<TransitionChecklistScreen> {
  late List<bool> _checked;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _checked = List.filled(widget.alert.checklistItems.length, false);
  }

  bool get _allDone => _checked.isNotEmpty && _checked.every((c) => c);

  void _closeAll() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(hyperfocusThemeProvider);
    final color = theme.primaryColor;
    final total = _checked.length;

    if (_allDone && !_celebrated) {
      _celebrated = true;
      TtsService.instance.speak('Parabéns! Você conseguiu!');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Checklist',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 12),
              if (total > 0)
                Wrap(
                  children: List.generate(total, (i) {
                    return Icon(
                      _checked[i] ? Icons.star : Icons.star_border,
                      color: color,
                      size: 32,
                    );
                  }),
                ),
              const SizedBox(height: 24),
              Expanded(
                child: total == 0
                    ? Center(
                        child: ElevatedButton(
                          onPressed: _closeAll,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white),
                          child: const Text('Concluir'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: total,
                        itemBuilder: (context, i) {
                          final item = widget.alert.checklistItems[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: CheckboxListTile(
                              value: _checked[i],
                              title:
                                  Text(item, style: const TextStyle(fontSize: 20)),
                              activeColor: color,
                              onChanged: (v) {
                                setState(() => _checked[i] = v ?? false);
                              },
                            ),
                          );
                        },
                      ),
              ),
              if (_allDone)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: _closeAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Concluído! 🎉',
                        style: TextStyle(fontSize: 20)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
