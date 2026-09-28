import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';
import 'package:ptook/features/shared/presintation/widgets/banner_ad_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  // Social & Community URLs
  static const String _facebookUrl = 'https://www.facebook.com/share/1Eb4TAdWTk/';
  static const String _telegramUrl = 'https://t.me/+SZweuBAmJztlY2Zk';
  static const String _linkedinUrl = 'https://www.linkedin.com/company/ptook/';
  static const String _developerUrl = 'https://eng-moustafa-ahmad.web.app/';

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFFFD700);
    const cardBg = Color(0xFF141721);
    const borderDim = Color(0xFF1F2433);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryGold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -----------------------------------------------------------------
              // 1. BRAND HERO CARD
              // -----------------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primaryGold.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryGold.withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                        border: Border.all(color: primaryGold, width: 2),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: primaryGold,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'PTOOK ARENA',
                      style: TextStyle(
                        color: primaryGold,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'v1.0.0 • Gamified Competitions',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ptook is an interactive competitive platform designed to empower creators, gamers, and teams. Track live rosters, compete in ranked arenas, and earn power points in real time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // -----------------------------------------------------------------
              // 2. COMMUNITY & SOCIAL LINKS
              // -----------------------------------------------------------------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'JOIN THE COMMUNITY',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildSocialTile(
                icon: Icons.telegram_rounded,
                iconColor: const Color(0xFF0088CC),
                title: 'Telegram Community',
                subtitle: 'Chat live with competitors & organizers',
                badgeText: 'Active',
                onTap: () => _launchURL(_telegramUrl),
              ),
              const SizedBox(height: 10),

              _buildSocialTile(
                icon: Icons.facebook_rounded,
                iconColor: const Color(0xFF1877F2),
                title: 'Facebook Page',
                subtitle: 'Stay updated with tournament news & events',
                onTap: () => _launchURL(_facebookUrl),
              ),
              const SizedBox(height: 10),

              _buildSocialTile(
                icon: Icons.business_center_rounded,
                iconColor: const Color(0xFF0A66C2),
                title: 'Ptook LinkedIn',
                subtitle: 'Official corporate & ecosystem updates',
                onTap: () => _launchURL(_linkedinUrl),
              ),

              const SizedBox(height: 28),

              // -----------------------------------------------------------------
              // 3. DEVELOPER CREDITS
              // -----------------------------------------------------------------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DEVELOPMENT & ENGINE',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderDim),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryGold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.code_rounded,
                        color: primaryGold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Eng. Moustafa Ahmad',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Lead Architect & Flutter Developer',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _launchURL(_developerUrl),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.open_in_new_rounded,
                          color: primaryGold,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // -----------------------------------------------------------------
              // FOOTER COPYRIGHT
              // -----------------------------------------------------------------
              const Text(
                '© 2026 Ptook Ecosystem. All rights reserved.',
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildSocialTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    const cardBg = Color(0xFF141721);
    const borderDim = Color(0xFF1F2433);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderDim),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.green.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
    
  }
}