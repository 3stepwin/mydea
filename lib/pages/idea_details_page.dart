import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/glassmorphic_container.dart';
import 'idea_analysis_page.dart';

/// Idea details page that displays the details of an existing idea
class IdeaDetailsPage extends StatefulWidget {
  /// Creates an idea details page
  const IdeaDetailsPage({
    Key? key,
    required this.idea,
  }) : super(key: key);

  /// The idea to display
  final Map<String, dynamic> idea;

  @override
  State<IdeaDetailsPage> createState() => _IdeaDetailsPageState();
}

class _IdeaDetailsPageState extends State<IdeaDetailsPage> with TickerProviderStateMixin {
  late AnimationController _particlesController;
  late AnimationController _slideController;
  
  List<Particle> _particles = [];
  bool _isEditing = false;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

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
    
    _titleController = TextEditingController(text: widget.idea['title']);
    _descriptionController = TextEditingController(text: widget.idea['description']);
    
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
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
    
    if (!_isEditing) {
      // Save changes to the idea
      widget.idea['title'] = _titleController.text;
      widget.idea['description'] = _descriptionController.text;
    }
  }
  
  void _analyzeIdea() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdeaAnalysisPage(idea: widget.idea),
      ),
    );
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
            'Idea Details',
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
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEditing,
          ),
        ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdeaDetailsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Idea statistics
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _slideController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: AnimationUtils.createSlideInAnimation(
                              controller: _slideController,
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                              startInterval: 0.2,
                            ),
                            child: FadeTransition(
                              opacity: AnimationUtils.createFadeInAnimation(
                                controller: _slideController,
                                startInterval: 0.2,
                              ),
                              child: _buildIdeaStats(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GlassmorphicButton(
        onPressed: _analyzeIdea,
        gradient: AppTheme.secondaryButtonGradient,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Analyze Idea',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIdeaDetailsSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: AnimationUtils.createSlideInAnimation(
            controller: _slideController,
            begin: const Offset(0.0, -0.2),
            end: Offset.zero,
          ),
          child: FadeTransition(
            opacity: _slideController,
            child: GlassmorphicCard(
              highlightGradient: true,
              child: _isEditing
                  ? _buildEditableContent()
                  : _buildDisplayContent(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDisplayContent() {
    final tags = widget.idea.containsKey('tags') 
        ? widget.idea['tags'] as List<dynamic>
        : [];
    
    final date = widget.idea.containsKey('date')
        ? widget.idea['date'] as DateTime
        : DateTime.now();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.idea['title'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.access_time,
              size: 16,
              color: Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Tags: ${tags.join(", ")}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Description:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.idea['description'],
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEditableContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            labelText: 'Title',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00CCFF)),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          style: const TextStyle(color: Colors.white),
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00CCFF)),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildIdeaStats() {
    // Show progress if available
    final progress = widget.idea.containsKey('progress')
        ? widget.idea['progress'] as double
        : 0.0;
    
    // Show analysis data if available
    final hasAnalysis = widget.idea.containsKey('analysis');
    
    return CustomScrollView(
      slivers: [
        // Progress section
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Completion Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGradient[0],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          HSLColor.fromColor(AppTheme.primaryGradient[0])
                              .withLightness(0.6)
                              .toColor(),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Next Steps:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Run the idea through AI analysis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Generate a development roadmap',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Create milestones to track progress',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Analysis section (if available)
        if (hasAnalysis) ...[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAnalysisCard(),
              ],
            ),
          ),
        ],
        
        // Additional information
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              GlassmorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoItem(
                      icon: Icons.category,
                      title: 'Category',
                      value: widget.idea.containsKey('category')
                          ? widget.idea['category']
                          : 'Uncategorized',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      icon: Icons.people,
                      title: 'Target Audience',
                      value: widget.idea.containsKey('targetAudience')
                          ? widget.idea['targetAudience']
                          : 'Not specified',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      icon: Icons.lightbulb_outline,
                      title: 'Problem Solved',
                      value: widget.idea.containsKey('problem')
                          ? widget.idea['problem']
                          : 'Not specified',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Bottom space for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
  
  Widget _buildAnalysisCard() {
    final analysis = widget.idea['analysis'] as Map<String, dynamic>;
    final score = analysis['score'] as double;
    
    return GlassmorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryGradient[0].withOpacity(0.8),
                      AppTheme.primaryGradient[0].withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${(score * 100).toInt()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap "Analyze Idea" to see full details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Show metrics if available
          if (analysis.containsKey('marketPotential') && 
              analysis.containsKey('feasibility') &&
              analysis.containsKey('innovation')) ...[
            _buildMetricItem(
              title: 'Market Potential',
              value: analysis['marketPotential'] as double,
              color: AppTheme.primaryGradient[0],
            ),
            const SizedBox(height: 12),
            _buildMetricItem(
              title: 'Feasibility',
              value: analysis['feasibility'] as double,
              color: AppTheme.primaryGradient[1],
            ),
            const SizedBox(height: 12),
            _buildMetricItem(
              title: 'Innovation',
              value: analysis['innovation'] as double,
              color: AppTheme.primaryGradient[2],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMetricItem({
    required String title,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryGradient[0],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
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