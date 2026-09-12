/// Representa um alerta de transição de atividade configurado pelos
/// pais: um aviso (falado por voz gravada ou por TTS) que avisa a
/// criança que uma atividade está prestes a mudar, seguido de uma
/// contagem visual e de um checklist gamificado.
///
/// Guardado como um Map simples dentro do Hive (sem gerador de
/// código/build_runner), seguindo o mesmo padrão já usado no Perfil
/// do Paciente e no Registro de Comportamento deste projeto — evita
/// depender de gerar arquivos .g.dart, que não é possível no fluxo
/// de trabalho atual (sem computador, só GitHub mobile).
class TransitionAlert {
  final String id;
  String title;
  String audioType; // 'gravado' ou 'tts'
  String? recordedAudioPath;
  String? ttsText;
  int countdownSeconds;
  List<String> checklistItems;
  bool isScheduled;
  int? scheduledHour;
  int? scheduledMinute;
  List<int> scheduledWeekdays; // 1 (domingo) a 7 (sábado)
  int notificationId;

  TransitionAlert({
    required this.id,
    required this.title,
    required this.audioType,
    this.recordedAudioPath,
    this.ttsText,
    this.countdownSeconds = 60,
    List<String>? checklistItems,
    this.isScheduled = false,
    this.scheduledHour,
    this.scheduledMinute,
    List<int>? scheduledWeekdays,
    required this.notificationId,
  })  : checklistItems = checklistItems ?? [],
        scheduledWeekdays = scheduledWeekdays ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audioType': audioType,
      'recordedAudioPath': recordedAudioPath,
      'ttsText': ttsText,
      'countdownSeconds': countdownSeconds,
      'checklistItems': checklistItems,
      'isScheduled': isScheduled,
      'scheduledHour': scheduledHour,
      'scheduledMinute': scheduledMinute,
      'scheduledWeekdays': scheduledWeekdays,
      'notificationId': notificationId,
    };
  }

  factory TransitionAlert.fromMap(Map map) {
    return TransitionAlert(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      audioType: map['audioType'] as String? ?? 'tts',
      recordedAudioPath: map['recordedAudioPath'] as String?,
      ttsText: map['ttsText'] as String?,
      countdownSeconds: map['countdownSeconds'] as int? ?? 60,
      checklistItems: (map['checklistItems'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isScheduled: map['isScheduled'] as bool? ?? false,
      scheduledHour: map['scheduledHour'] as int?,
      scheduledMinute: map['scheduledMinute'] as int?,
      scheduledWeekdays: (map['scheduledWeekdays'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      notificationId: map['notificationId'] as int? ?? 0,
    );
  }
}
