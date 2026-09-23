import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/public_links.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/parental_ui.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  Future<void> _openPolicy(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(PublicLinks.privacyPolicy),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Não foi possível abrir a política agora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Privacidade e dados'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          const ParentalSectionHeading(
            eyebrow: 'CONTROLE DOS DADOS',
            title: 'Privacidade e dados',
            description:
                'Veja onde os dados ficam, quando podem sair do aparelho e como apagá-los.',
          ),
          const SizedBox(height: 18),
          const ParentalInfoBanner(
            icon: Icons.lock_outline,
            eyebrow: 'PRIVACIDADE POR PADRÃO',
            message:
                'Você decide o que é registrado e quando algo é compartilhado. A comunicação básica continua funcionando sem internet.',
          ),
          const SizedBox(height: 16),
          const _PrivacyCard(
            icon: Icons.phone_android_outlined,
            title: 'Armazenamento local',
            description:
                'Os registros e mídias ficam neste aparelho por padrão.',
          ),
          const _PrivacyCard(
            icon: Icons.enhanced_encryption_outlined,
            title: 'Proteção',
            description:
                'Caixas sensíveis usam armazenamento protegido. O PIN controla a entrada na Área Parental.',
          ),
          const _PrivacyCard(
            icon: Icons.share_outlined,
            title: 'Compartilhamento',
            description:
                'O aplicativo não envia dados automaticamente para clínicas, escolas ou patrocinadores.',
          ),
          const _PrivacyCard(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Exportação',
            description:
                'Relatórios exportados podem sair do armazenamento protegido. Revise o destinatário antes de compartilhar.',
          ),
          const _PrivacyCard(
            icon: Icons.delete_outline,
            title: 'Exclusão local',
            description:
                'Apagar os dados remove o conteúdo local e o PIN. Cópias já exportadas não são apagadas por essa ação.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openPolicy(context),
            icon: const Icon(Icons.open_in_new_outlined),
            label: const Text('Ler a política de privacidade'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.cardBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(description,
                    style: const TextStyle(
                        color: AppTheme.mutedText, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
