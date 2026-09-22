import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/plans/plan_access_controller.dart';
import '../../../../core/plans/plan_access_provider.dart';
import '../../../../core/plans/plan_catalog.dart';
import '../../../../core/plans/plan_models.dart';
import '../../../../core/theme/app_theme.dart';

/// Exibe o estado comercial sem exigir conta, cobrança ou conexão.
class PlanStatusScreen extends ConsumerWidget {
  const PlanStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(planAccessProvider);
    final license = access.license;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Plano e recursos'),
        backgroundColor: AppTheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CurrentPlanCard(access: access),
          const SizedBox(height: 20),
          const Text(
            'Recursos da comunicação',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          _FeatureTile(
            icon: Icons.wifi_off_outlined,
            title: 'Comunicação offline',
            description: 'Cartões, frases e voz continuam disponíveis sem internet.',
            enabled: access.canUse(PlanFeature.offlineCommunication),
          ),
          _FeatureTile(
            icon: Icons.lock_outline,
            title: 'Controle familiar',
            description: 'PIN, configurações parentais e dados locais protegidos.',
            enabled: access.canUse(PlanFeature.parentalControls),
          ),
          _FeatureTile(
            icon: Icons.accessibility_new_outlined,
            title: 'Acessibilidade',
            description: 'Modos de toque e semântica acessível fazem parte do núcleo.',
            enabled: access.canUse(PlanFeature.accessibility),
          ),
          const SizedBox(height: 20),
          const Text(
            'Planos disponíveis',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 8),
          ...PlanCatalog.publicPlans.map(
            (plan) => _PlanCard(
              plan: plan,
              selected: plan.id == access.plan.id,
            ),
          ),
          if (license == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Nenhuma assinatura ou licença remota está conectada. O plano Essencial continua funcionando neste aparelho.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final PlanAccessController access;

  const _CurrentPlanCard({required this.access});

  @override
  Widget build(BuildContext context) {
    final license = access.license;
    final status = license == null ? 'Uso local' : _statusLabel(license.status);

    return Card(
      color: AppTheme.professionalBackground,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plano atual',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              access.plan.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: access.communicationRemainsAvailable
                    ? Colors.lightGreenAccent
                    : Colors.orangeAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'A comunicação básica não depende de assinatura e não será bloqueada por falta de conexão.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(LicenseStatus status) => switch (status) {
        LicenseStatus.invited => 'Convite pendente',
        LicenseStatus.active => 'Ativo',
        LicenseStatus.grace => 'Período de transição',
        LicenseStatus.suspended => 'Suspenso — uso local preservado',
        LicenseStatus.expired => 'Expirado — uso local preservado',
        LicenseStatus.revoked => 'Revogado — uso local preservado',
      };
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title: ${enabled ? 'disponível' : 'indisponível'}',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: enabled ? AppTheme.primary : Colors.grey),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(
          enabled ? Icons.check_circle_outline : Icons.lock_outline,
          color: enabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Plan plan;
  final bool selected;

  const _PlanCard({required this.plan, required this.selected});

  @override
  Widget build(BuildContext context) {
    final price = plan.isFree
        ? 'Gratuito'
        : plan.pricePending
            ? 'Preço a definir'
            : 'R\$ ${(plan.monthlyPriceCents! / 100).toStringAsFixed(2)} / mês';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppTheme.primary : AppTheme.cardBorder,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        title: Row(
          children: [
            Expanded(
              child: Text(
                plan.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(plan.description),
        ),
      ),
    );
  }
}
