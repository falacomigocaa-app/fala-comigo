import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/services/transition_alert_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transition_alerts/data/providers/transition_alerts_provider.dart';
import '../../../transition_alerts/domain/models/transition_alert.dart';

const Map<int, String> _weekdayLabels = {
  1: 'D',
  2: 'S',
  3: 'T',
  4: 'Q',
  5: 'Q',
  6: 'S',
  7: 'S',
};

classe TransitionAlertEditScreen estende ConsumerStatefulWidget {
  Alerta de transição final? Alerta existente;

  const TransitionAlertEditScreen({super.key, this.existingAlert});

  @override
  ConsumerState<TransitionAlertEditScreen> createState() =>
      _TransitionAlertEditScreenState();
}

classe _TransitionAlertEditScreenState
    estende ConsumerState<TransitionAlertEditScreen> {
  final tardio TextEditingController _titleController;
  Controlador de edição de texto final tardio _ttsController;
  final TextEditingController _checklistInputController =
      Controlador de edição de texto();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String _alertId atrasado;
  int _notificationId tardio;
  String _audioType tardio;
  String? _recordedAudioPath;
  bool _isRecording = false;
  bool _isPlayingPreview = false;

  tarde bool _isScheduled;
  Hora do dia? _horário agendado;
  definir tarde<int> _scheduledWeekdays;
  int _countdownSeconds tardio;
  Lista tardia<String> _checklistItems;

  bool get _isEditing => widget.existingAlert != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAlert;
    notificador final = ref.read(transitionAlertsListProvider.notifier);

    _alertId = existing?.id ?? notifier.generateId();
    _notificationId =
        existing?.notificationId ?? notifier.generateNotificationId();

    _titleController = TextEditingController(text: existing?.title ?? '');
    _audioType = existing?.audioType ?? 'tts';
    _ttsController = TextEditingController(text: existing?.ttsText ?? '');
    _recordedAudioPath = existing?.recordedAudioPath;

    _isScheduled = existing?.isScheduled ?? false;
    _scheduledWeekdays = {...(existing?.scheduledWeekdays ?? [])};
    _countdownSeconds = existing?.countdownSeconds ?? 60;
    _checklistItems = [...(existing?.checklistItems ?? [])];

    se (existindo?.horaAgendada != nulo &&
        existing?.scheduledMinute != null) {
      _scheduledTimeOfDay = TimeOfDay(
          hora: existente!.horaAgendada!, minuto: existente.minutoAgendado!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ttsController.dispose();
    _checklistInputController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<String> _recordingFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final alertsDir = Directory(dir.path + '/transition_alerts_audio');
    se (!await alertsDir.exists()) {
      aguarde alertsDir.create(recursive: true);
    }
    retornar alertsDir.path + '/' + _alertId + '.m4a';
  }

  Future<void> _toggleRecording() async {
    se (_isRecording) {
      caminho final = aguarde _recorder.stop();
      setState(() {
        _isRecording = falso;
        _recordedAudioPath = caminho ?? _recordedAudioPath;
      });
      retornar;
    }

    if (!await _recorder.hasPermission()) {
      se (montado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E preciso autorizar o uso do microfone para gravar.'),
          ),
        );
      }
      retornar;
    }

    caminho final = aguarde _recordingFilePath();
    aguarde _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),
        caminho: caminho);
    setState(() => _isRecording = true);
  }

  Futuro<void> _playPreview() assíncrono {
    se (_recordedAudioPath == nulo) retorne;
    setState(() => _isPlayingPreview = true);
    await _player.play(DeviceFileSource(_recordedAudioPath!));
    _player.onPlayerComplete.first.then((_) {
      se (montado) setState(() => _isPlayingPreview = false);
    });
  }

  Futuro<void> _pickTime() assíncrono {
    final escolhido = aguarde showTimePicker(
      contexto: contexto,
      initialTime: _scheduledTimeOfDay ?? TimeOfDay.now(),
    );
    se (escolhido != nulo) {
      setState(() => _scheduledTimeOfDay = escolhido);
    }
  }

  void _addChecklistItem() {
    texto final = _checklistInputController.text.trim();
    se (texto.isEmpty) retorne;
    setState(() {
      _checklistItems.add(text);
      _checklistInputController.clear();
    });
  }

  TransitionAlert _buildAlert() {
    retornar AlertaDeTransição(
      id: _alertId,
      título: _titleController.text.trim(),
      audioType: _audioType,
      caminhoAudioGravado: _caminhoAudioGravado,
      ttsText: _ttsController.text.trim(),
      contagemRegressivaSegundos: _contagemRegressivaSegundos,
      checklistItems: _checklistItems,
      estáAgendado: _estáAgendado,
      horaAgendada: _horaAgendadaDoDia?.hora,
      minutoAgendado: _horárioAgendadoDoDia?.minuto,
      dias da semana agendados: _scheduledWeekdays.toList(),
      ID da notificação: _notificationId,
    );
  }

  Future<void> _save() async {
    se (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('De um nome para o alerta antes de salvar.')),
      );
      retornar;
    }
    alerta final = _buildAlert();
    se (_isEditing) {
      await ref.read(transitionAlertsListProvider.notifier).updateAlert(alert);
    } outro {
      await ref.read(transitionAlertsListProvider.notifier).addAlert(alert);
    }
    String? erroAgendamento;
    tentar {
      aguardar TransitionAlertService.instance.scheduleRecurring(alert);
    } catch (e) {
      scheduleError = e.toString();
    }
    se (!montado) retornar;
    se (scheduleError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao agendar: ' + agendaError)),
      );
      retornar;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    retornar Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Alerta' : 'Novo Alerta'),
        backgroundColor: AppTheme.surface,
      ),
      corpo: ListView(
        preenchimento: const EdgeInsets.all(16),
        crianças: [
          const Text('Nome do alerta',
              estilo: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(altura: 4),
          Campo de texto(
            controlador: _titleController,
            decoração: const InputDecoration(
              dicaText: 'Ex: Hora do banho',
              borda: OutlineInputBorder(),
            ),
          ),
          const Divider(altura: 32),

          const Text('Mensagem de áudio',
              estilo: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(altura: 8),
          Enrolar(
            espaçamento: 8,
            crianças: [
              ChoiceChip(
                label: const Text('Gravar minha voz'),
                selecionado: _audioType == 'gravado',
                onSelected: (_) => setState(() => _audioType = 'gravado'),
              ),
              ChoiceChip(
                rótulo: const Text('Digitar (o app fala)'),
                selecionado: _audioType == 'tts',
                onSelected: (_) => setState(() => _audioType = 'tts'),
              ),
            ],
          ),
          const SizedBox(altura: 12),
          se (_audioType == 'gravado')
            Linha(
              crianças: [
                ElevatedButton.ícone(
                  onPressed: _toggleRecording,
                  ícone: Icon(_isRecording ? Icons.stop : Icons.mic),
                  rótulo: Text(_isRecording ? 'Parar' : 'Gravar'),
                  estilo: ElevatedButton.styleFrom(
                    cor de fundo:
                        _estágravando? Colors.redAccent: AppTheme.primary,
                    cor de primeiro plano: Cores.branco,
                  ),
                ),
                const SizedBox(largura: 12),
                se (_recordedAudioPath != null)
                  Botão de ícone(
                    onPressed: _isPlayingPreview ? null : _playPreview,
                    ícone: const Icon(Icons.play_circle,
                        cor: AppTheme.accentGreen, tamanho: 32),
                    dica de ferramenta: 'Ouvir gravacao',
                  ),
              ],
            )
          outro
            Campo de texto(
              controlador: _ttsController,
              maxLines: 3,
              decoração: const InputDecoration(
                hintText: 'Ex: Vamos guardar os brinquedos e ir para o banho!',
                borda: OutlineInputBorder(),
              ),
            ),
          const Divider(altura: 32),

          const Text('Contagem visual',
              estilo: TextStyle(fontWeight: FontWeight.w700)),
          Texto(_countdownSeconds.toString() + ' segundos',
              estilo: const TextStyle(cor: Colors.grey)),
          Slider(
            valor: _countdownSeconds.toDouble(),
            min: 10,
            máx.: 300,
            divisões: 29,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _countdownSeconds = v.round()),
          ),
          const Divider(altura: 32),

          Linha(
            crianças: [
              const Expandido(
                filho: Text('Repetir em horario fixo',
                    estilo: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Trocar(
                valor: _isScheduled,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _isScheduled = v),
              ),
            ],
          ),
          se (_isScheduled) ...[
            const SizedBox(altura: 8),
            Ícone de botão com contorno (
              onPressed: _pickTime,
              ícone: const Icon(Icons.access_time),
              rótulo: Texto(
                _scheduledTimeOfDay == null
                    ? 'Escolher horario'
                    : _scheduledTimeOfDay!.format(context),
              ),
            ),
            const SizedBox(altura: 12),
            Enrolar(
              espaçamento: 6,
              filhos: _weekdayLabels.entries.map((entry) {
                final selecionado = _scheduledWeekdays.contains(entry.key);
                retornar FilterChip(
                  rótulo: Texto(entrada.valor),
                  selecionado: selecionado,
                  selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                  onSelected: (sel) => setState(() {
                    se (sel) {
                      _scheduledWeekdays.add(entry.key);
                    } outro {
                      _scheduledWeekdays.remove(entry.key);
                    }
                  }),
                );
              }).toList(),
            ),
          ],
          const Divider(altura: 32),

          const Text('Checklist depois do alerta',
              estilo: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(altura: 4),
          const Texto(
            'Dica: comece cada item com um emoji, ex: Guardar os brinquedos.',
            estilo: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(altura: 8),
          Linha(
            crianças: [
              Expandido(
                filho: Campo de texto(
                  controlador: _checklistInputController,
                  decoração: const InputDecoration(
                    hintText: 'Guardar os brinquedos',
                    borda: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addChecklistItem(),
                ),
              ),
              Botão de ícone(
                onPressed: _addChecklistItem,
                ícone: const Icon(Icons.add_circle,
                    cor: AppTheme.primary, tamanho: 32),
              ),
            ],
          ),
          const SizedBox(altura: 8),
          para (var i = 0; i < _checklistItems.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              título: Texto(_checklistItems[i]),
              final: IconButton(
                ícone: const Icon(Icons.close, cor: Colors.redAccent),
                onPressed: () => setState(() => _checklistItems.removeAt(i)),
              ),
            ),
          const SizedBox(altura: 24),

          ElevatedButton.ícone(
            onPressed: _salvar,
            ícone: const Icon(Icons.check),
            rótulo: const Text('Salvar alerta'),
            estilo: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              cor de primeiro plano: Cores.branco,
              tamanhoMínimo: const Tamanho.daAltura(48),
            ),
          ),
          const SizedBox(altura: 40),
        ],
      ),
    );
  }
}
