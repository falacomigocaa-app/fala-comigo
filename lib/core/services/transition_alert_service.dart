import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/transition_alerts/domain/models/transition_alert.dart';

/// Identificador do canal de notificação do Alerta de Transição de
/// Atividade — precisa de alta prioridade e "tela cheia" para
/// acordar o aparelho e chamar a atenção, do mesmo jeito que um
/// despertador ou uma ligação.
const String _channelId = 'transition_alert_channel';
const String _channelName = 'Alertas de Transição';
const String _channelDescription =
    'Avisos de transição de atividade com contagem visual e checklist';

/// Prefixo do payload usado para identificar, quando a notificação é
/// tocada, qual TransitionAlert deve abrir a tela em tela cheia.
const String transitionAlertPayloadPrefix = 'transition_alert:';

/// Serviço responsável por dois papéis do Alerta de Transição de
/// Atividade: pedir as permissões do Android e disparar/agendar as
/// notificações em tela cheia.
class TransitionAlertService {
  TransitionAlertService._();
  static final TransitionAlertService instance = TransitionAlertService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Chamado quando o usuário toca numa notificação (ou ela dispara
  /// em tela cheia com o app já aberto). Recebe o ID do
  /// TransitionAlert correspondente. Definido pelo app na Fase D,
  /// quando a tela de alerta existir.
  void Function(String alertId)? onAlertTriggered;

  Future<void> init() async {
    // Fuso horário fixo em horário de Brasília, para simplificar
    // (o app é voltado ao público brasileiro).
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handlePayload(response.payload);
      },
    );

    // Caso o app tenha sido aberto justamente por causa de um alerta
    // (estava fechado quando o alerta disparou).
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _handlePayload(launchDetails?.notificationResponse?.payload);
    }
  }

  void _handlePayload(String? payload) {
    if (payload == null ||
        !payload.startsWith(transitionAlertPayloadPrefix)) {
      return;
    }
    final alertId = payload.substring(transitionAlertPayloadPrefix.length);
    onAlertTriggered?.call(alertId);
  }

  /// Pede as permissões necessárias no Android: notificações, alarme
  /// exato e tela cheia. Deve ser chamado a partir de uma tela (ex:
  /// ao criar o primeiro alerta), nunca silenciosamente ao abrir o
  /// app, para o responsável entender o motivo do pedido.
  Future<void> requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;
    await androidPlugin.requestNotificationsPermission();
    await androidPlugin.requestExactAlarmsPermission();
    await androidPlugin.requestFullScreenIntentPermission();
  }

  NotificationDetails _buildDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Dispara o alerta imediatamente (modo manual).
  Future<void> triggerNow(TransitionAlert alert) async {
    await _plugin.show(
      alert.notificationId,
      alert.title,
      'Hora de mudar de atividade!',
      _buildDetails(),
      payload: '$transitionAlertPayloadPrefix${alert.id}',
    );
  }

  /// Agenda (ou reagenda) as notificações recorrentes do alerta, uma
  /// para cada dia da semana selecionado. Cada dia usa seu próprio ID
  /// de notificação (base + número do dia) para poder ser cancelado
  /// individualmente depois.
  Future<void> scheduleRecurring(TransitionAlert alert) async {
    await cancelSchedule(alert);
    if (!alert.isScheduled ||
        alert.scheduledHour == null ||
        alert.scheduledMinute == null ||
        alert.scheduledWeekdays.isEmpty) {
      return;
    }

    for (final weekday in alert.scheduledWeekdays) {
      final scheduledDate = _nextInstanceOfWeekdayTime(
        weekday,
        alert.scheduledHour!,
        alert.scheduledMinute!,
      );
      await _plugin.zonedSchedule(
        alert.notificationId + weekday,
        alert.title,
        'Hora de mudar de atividade!',
        scheduledDate,
        _buildDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: '$transitionAlertPayloadPrefix${alert.id}',
      );
    }
  }

  /// Cancela as notificações agendadas (nos 7 dias da semana) deste
  /// alerta.
  Future<void> cancelSchedule(TransitionAlert alert) async {
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(alert.notificationId + weekday);
    }
  }

  /// Calcula a próxima ocorrência de um dia da semana (1=domingo ...
  /// 7=sábado, convenção usada no resto do app) num horário
  /// determinado.
  tz.TZDateTime _nextInstanceOfWeekdayTime(
      int weekday, int hour, int minute) {
    // package:timezone/Dart usa 1=segunda...7=domingo; convertemos
    // da convenção do app (1=domingo...7=sábado).
    final dartWeekday = weekday == 1 ? DateTime.sunday : weekday - 1;

    var scheduled = tz.TZDateTime.now(tz.local);
    scheduled = tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      hour,
      minute,
    );
    while (scheduled.weekday != dartWeekday ||
        scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
