import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_logo.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/social_share_gate.dart';
import 'dashboard_page.dart';

enum SlideDirection { up, down, left, right }

class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  final Duration duration;

  const FadeInAnimation({
    Key? key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final int delay;
  final Duration duration;
  final Curve curve;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.direction = SlideDirection.up,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutQuad,
  }) : super(key: key);

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    Offset begin;
    switch (widget.direction) {
      case SlideDirection.up:
        begin = const Offset(0, 0.2);
        break;
      case SlideDirection.down:
        begin = const Offset(0, -0.2);
        break;
      case SlideDirection.left:
        begin = const Offset(0.2, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(-0.2, 0);
        break;
    }
    
    _animation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  final Duration duration;
  final Curve curve;

  const ScaleInAnimation({
    Key? key,
    required this.child,
    this.delay = 0,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutQuad,
  }) : super(key: key);

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String username = 'Username';
  bool isFirstLaunch = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Innovator';
      isFirstLaunch = prefs.getBool('first_launch') ?? true;
    });
  }
  
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
  }
  
  // Share gate functionality removed per user request

  void _navigateToDashboard() async {
    await _saveUserData();
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const DashboardPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.darkBackground, AppTheme.darkerBackground],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            const ParticlesBackground(),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Animated logo with glow - bigger and more prominent
                        const AnimatedLogo(
                          size: 240, // Larger size for the revolutionary tech
                          glowIntensity: 0.8, // More controlled glow that enhances but doesn't overpower
                        ),
                        const SizedBox(height: 40),
                        
                        // Welcome text with personalized username and enhanced glow
                        FadeInAnimation(
                          delay: 300,
                          child: SlideInAnimation(
                            direction: SlideDirection.up,
                            delay: 300,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Welcome, $username',
                                style: AppTheme.headingStyle.copyWith(
                                  fontSize: 32, // Larger font size
                                  letterSpacing: 0.5, // Better letter spacing
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.primaryColor.withOpacity(0.7),
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // App tagline
                        FadeInAnimation(
                          delay: 500,
                          child: SlideInAnimation(
                            direction: SlideDirection.up,
                            delay: 500,
                            child: Text(
                              'Think it. Say it. Build it.',
                              style: AppTheme.subtitleStyle.copyWith(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Powered by Google Gemini branding
                        FadeInAnimation(
                          delay: 600,
                          child: SlideInAnimation(
                            direction: SlideDirection.up,
                            delay: 600,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Powered by ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Google ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/partners/gemini_logo.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Gemini',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Get started button with glassmorphic effect
                        FadeInAnimation(
                          delay: 700,
                          child: ScaleInAnimation(
                            delay: 700,
                            child: GlassmorphicContainer(
                              width: 220,
                              height: 60,
                              borderRadius: 30,
                              blur: 8,
                              opacity: 0.1,
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: _navigateToDashboard,
                                  splashColor: AppTheme.primaryColor.withOpacity(0.2),
                                  highlightColor: AppTheme.primaryColor.withOpacity(0.1),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get Started',
                                          style: AppTheme.buttonTextStyle,
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlesBackground extends StatelessWidget {
  const ParticlesBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: CustomPaint(
        painter: ParticlesPainter(),
      ),
    );
  }
}

class Particle {
  final Offset position;
  final double size;
  final Color color;
  final double opacity;

  Particle({
    required this.position,
    required this.size,
    required this.color,
    required this.opacity,
  });
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles = [];
  
  ParticlesPainter() {
    // Generate random particles
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 50; i++) {
      final x = (random * (i + 1) % 1000) / 1000 * 400;
      final y = (random * (i + 2) % 1000) / 1000 * 800;
      final size = (random * (i + 3) % 100) / 100 * 4 + 1;
      final opacity = (random * (i + 4) % 100) / 100 * 0.5 + 0.1;
      
      Color color;
      final colorSelector = (random * (i + 5) % 100) / 100;
      if (colorSelector < 0.33) {
        color = AppTheme.primaryColor;
      } else if (colorSelector < 0.66) {
        color = AppTheme.secondaryColor;
      } else {
        color = AppTheme.tertiaryColor;
      }
      
      particles.add(
        Particle(
          position: Offset(x, y),
          size: size,
          color: color,
          opacity: opacity,
        ),
      );
    }
  }
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(
          particle.position.dx % size.width,
          particle.position.dy % size.height,
        ),
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}