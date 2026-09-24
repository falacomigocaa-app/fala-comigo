import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/public_links.dart';
import '../../../../core/theme/app_theme.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.professionalBackground,
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  AppTheme.professionalBackground,
                  AppTheme.professionalSurface
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.professionalAccent,
                  child: Icon(Icons.lock_outline,
                      color: AppTheme.professionalBackground),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Você decide o que é registrado e quando algo é compartilhado.',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.25),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PrivacyCard(
            icon: Icons.phone_android_outlined,
            title: 'Armazenamento local',
            description:
                'Os registros e mídias ficam neste aparelho por padrão. A comunicação básica continua funcionando sem internet.',
          ),
          _PrivacyCard(
            icon: Icons.enhanced_encryption_outlined,
            title: 'Proteção',
            description:
                'Caixas sensíveis usam armazenamento protegido. O PIN controla a entrada na Área do Responsável.',
          ),
          _PrivacyCard(
            icon: Icons.verified_user_outlined,
            title: 'Transparência de segurança',
            description:
                'O projeto passa por testes automatizados e usa o OWASP MASVS como referência. Uma varredura MobSF foi concluída em APK de teste; os achados estão em revisão no site.',
          ),
          _PrivacyCard(
            icon: Icons.share_outlined,
            title: 'Compartilhamento',
            description:
                'O aplicativo não envia dados automaticamente para clínicas, escolas ou patrocinadores. Qualquer compartilhamento deve ser uma escolha explícita.',
          ),
          _PrivacyCard(
            icon: Icons.picture_as_pdf_outlined,
            title: 'Exportação',
            description:
                'Relatórios e arquivos exportados podem sair do armazenamento protegido. Revise o destinatário antes de compartilhar.',
          ),
          _PrivacyCard(
            icon: Icons.delete_outline,
            title: 'Exclusão local',
            description:
                'A opção Apagar todos os dados remove o conteúdo local e o PIN deste aparelho. Cópias já exportadas não são apagadas por essa ação.',
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
                  borderRadius: BorderRadius.circular(16)),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(
                        color: AppTheme.mutedText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
