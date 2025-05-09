import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'glassmorphic_container.dart';

class SocialShareGate extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  
  const SocialShareGate({
    Key? key, 
    required this.onContinue,
    required this.onSkip,
  }) : super(key: key);

  Future<void> _shareOnPlatform(String platform) async {
    String url = '';
    String message = 'Check out MyDea - the revolutionary app for transforming ideas into products! Think it. Say it. Build it.';
    
    switch (platform) {
      case 'twitter':
        url = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(message)}';
        break;
      case 'facebook':
        url = 'https://www.facebook.com/sharer/sharer.php?u=https://mydea.app&quote=${Uri.encodeComponent(message)}';
        break;
      case 'linkedin':
        url = 'https://www.linkedin.com/shareArticle?mini=true&url=https://mydea.app&title=MyDea&summary=${Uri.encodeComponent(message)}';
        break;
    }
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 340,
        borderRadius: 20,
        blur: 10,
        opacity: 0.2,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.3),
            AppTheme.secondaryColor.withOpacity(0.3),
          ],
        ),
        border: Border.all(
          width: 1.5,
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: AppTheme.glowShadow(
          color: AppTheme.primaryColor,
          intensity: 0.5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share The Innovation',
                style: AppTheme.headingStyle.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Help spread the word about MyDea and unlock premium features!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareButton(
                    'Twitter',
                    Colors.blue,
                    'twitter',
                    Icons.alternate_email,
                  ),
                  _buildShareButton(
                    'Facebook',
                    Colors.indigo,
                    'facebook',
                    Icons.facebook,
                  ),
                  _buildShareButton(
                    'LinkedIn',
                    const Color(0xFF0077B5),
                    'linkedin',
                    Icons.business,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onSkip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton(String platform, Color color, String id, IconData icon) {
    return InkWell(
      onTap: () => _shareOnPlatform(id),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            platform,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}