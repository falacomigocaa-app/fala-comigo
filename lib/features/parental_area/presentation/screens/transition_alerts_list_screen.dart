import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/transition_alert_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transition_alerts/data/providers/transition_alerts_provider.dart';
import '../../../transition_alerts/domain/models/transition_alert.dart';
import 'transition_alert_edit_screen.dart';

/// Lista os Alertas de Transição de Atividade cadastrados, permite
/// criar novos, editar, excluir e testar cada um imediatamente.
class TransitionAlertsListScreen extends ConsumerWidget {
  const TransitionAlertsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(transitionAlertsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Alertas de Transição'),
        backgroundColor: AppTheme.surface,
      ),
      floatingActionButton: F
