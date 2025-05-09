import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/glassmorphic_container.dart';

/// Settings page for the app
class SettingsPage extends StatefulWidget {
  /// Creates a settings page
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  late AnimationController _particlesController;
  late AnimationController _slideController;
  
  List<Particle> _particles = [];
  
  // Settings
  bool _isDarkMode = true;
  bool _enableNotifications = true;
  bool _enableHapticFeedback = true;
  bool _enableDailyReminders = true;
  bool _enableSoundEffects = true;
  bool _enableDataBackup = false;
  
  String _selectedTheme = 'Dark';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    )..repeat();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    // Generate particles
    _generateParticles();
  }
  
  void _generateParticles() {
    final random = Random();
    _particles = List.generate(
      15,
      (index) => Particle(
        position: Offset(
          random.nextDouble() * MediaQuery.of(context).size.width,
          random.nextDouble() * MediaQuery.of(context).size.height,
        ),
        size: random.nextDouble() * 3 + 1,
        color: AppTheme.primaryGradient[random.nextInt(AppTheme.primaryGradient.length)]
            .withOpacity(0.2 + random.nextDouble() * 0.1),
        speed: random.nextDouble() * 0.5 + 0.2,
        angle: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
        amplitude: random.nextDouble() * 15 + 5,
        phase: random.nextDouble() * 2 * pi,
      ),
    );
  }

  @override
  void dispose() {
    _particlesController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppTheme.primaryGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background particles animation
            AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  painter: ParticlesPainter(
                    particles: _particles,
                    animation: _particlesController.value,
                  ),
                );
              },
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedBuilder(
                  animation: _slideController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _slideController,
                      child: CustomScrollView(
                        slivers: [
                          // App info section
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppTheme.primaryGradient[0],
                                        AppTheme.primaryGradient[1],
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.lightbulb,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'MyDea',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Version 1.0.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                          
                          // Appearance settings
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Appearance',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GlassmorphicCard(
                                  child: Column(
                                    children: [
                                      _buildSwitchTile(
                                        title: 'Dark Mode',
                                        subtitle: 'Enable dark theme',
                                        icon: Icons.dark_mode,
                                        value: _isDarkMode,
                                        onChanged: (value) {
                                          setState(() {
                                            _isDarkMode = value;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                      _buildDropdownTile(
                                        title: 'Theme',
                                        icon: Icons.color_lens,
                                        value: _selectedTheme,
                                        items: const ['Dark', 'Midnight', 'Ocean', 'Aurora'],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedTheme = value;
                                            });
                                            HapticFeedback.selectionClick();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Notifications settings
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GlassmorphicCard(
                                  child: Column(
                                    children: [
                                      _buildSwitchTile(
                                        title: 'Notifications',
                                        subtitle: 'Enable push notifications',
                                        icon: Icons.notifications,
                                        value: _enableNotifications,
                                        onChanged: (value) {
                                          setState(() {
                                            _enableNotifications = value;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                      _buildSwitchTile(
                                        title: 'Daily Reminders',
                                        subtitle: 'Get reminded about your ideas',
                                        icon: Icons.calendar_today,
                                        value: _enableDailyReminders,
                                        onChanged: _enableNotifications
                                            ? (value) {
                                                setState(() {
                                                  _enableDailyReminders = value;
                                                });
                                                HapticFeedback.selectionClick();
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Feedback settings
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const Text(
                                  'Feedback',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GlassmorphicCard(
                                  child: Column(
                                    children: [
                                      _buildSwitchTile(
                                        title: 'Haptic Feedback',
                                        subtitle: 'Enable vibration feedback',
                                        icon: Icons.vibration,
                                        value: _enableHapticFeedback,
                                        onChanged: (value) {
                                          setState(() {
                                            _enableHapticFeedback = value;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                      _buildSwitchTile(
                                        title: 'Sound Effects',
                                        subtitle: 'Enable sound effects',
                                        icon: Icons.volume_up,
                                        value: _enableSoundEffects,
                                        onChanged: (value) {
                                          setState(() {
                                            _enableSoundEffects = value;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Data settings
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const Text(
                                  'Data',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GlassmorphicCard(
                                  child: Column(
                                    children: [
                                      _buildSwitchTile(
                                        title: 'Auto Backup',
                                        subtitle: 'Backup your ideas to the cloud',
                                        icon: Icons.backup,
                                        value: _enableDataBackup,
                                        onChanged: (value) {
                                          setState(() {
                                            _enableDataBackup = value;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                      _buildDropdownTile(
                                        title: 'Language',
                                        icon: Icons.language,
                                        value: _selectedLanguage,
                                        items: const ['English', 'Spanish', 'French', 'German', 'Chinese'],
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedLanguage = value;
                                            });
                                            HapticFeedback.selectionClick();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Action buttons
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                const Text(
                                  'Actions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GlassmorphicCard(
                                  child: Column(
                                    children: [
                                      _buildActionTile(
                                        title: 'Export Data',
                                        icon: Icons.file_download,
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          // TODO: Implement export data functionality
                                        },
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                      _buildActionTile(
                                        title: 'Clear Cache',
                                        icon: Icons.cleaning_services,
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          // TODO: Implement clear cache functionality
                                        },
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                      _buildActionTile(
                                        title: 'Privacy Policy',
                                        icon: Icons.privacy_tip,
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          // TODO: Navigate to privacy policy
                                        },
                                      ),
                                      const Divider(
                                        color: Colors.white24,
                                        height: 1,
                                      ),
                                      _buildActionTile(
                                        title: 'Terms of Service',
                                        icon: Icons.description,
                                        onTap: () {
                                          HapticFeedback.mediumImpact();
                                          // TODO: Navigate to terms of service
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // About section
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Show about dialog
                                  },
                                  child: const Text(
                                    'Made with ❤️ by MyDea Team',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
      secondary: Icon(
        icon,
        color: AppTheme.primaryGradient[1],
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGradient[0],
      inactiveTrackColor: Colors.white24,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
  
  Widget _buildDropdownTile<T>({
    required String title,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryGradient[1],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<T>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: AppTheme.darkBackgroundColor,
            underline: Container(
              height: 1,
              color: Colors.white24,
            ),
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryGradient[1],
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white54,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

/// Particle class for the animated particles
class Particle {
  /// Creates a particle with the given properties
  Particle({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
    required this.amplitude,
    required this.phase,
  });

  /// The position of the particle
  Offset position;
  
  /// The size of the particle
  double size;
  
  /// The color of the particle
  Color color;
  
  /// The speed of the particle
  double speed;
  
  /// The angle of movement
  double angle;
  
  /// The rotation speed of the particle
  double rotationSpeed;
  
  /// The amplitude of the sine wave motion
  double amplitude;
  
  /// The phase of the sine wave motion
  double phase;
}

/// Custom painter for particles
class ParticlesPainter extends CustomPainter {
  /// Creates a particles painter
  ParticlesPainter({
    required this.particles,
    required this.animation,
  });

  /// The list of particles
  final List<Particle> particles;
  
  /// The animation value
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final offset = Offset(
        particle.position.dx + sin(particle.phase + animation * 2 * pi) * particle.amplitude,
        particle.position.dy + cos(particle.phase + animation * 2 * pi) * particle.amplitude,
      );
      
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(offset, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}