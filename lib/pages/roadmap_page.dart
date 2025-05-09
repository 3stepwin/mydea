import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/glassmorphic_container.dart';
import '../services/gemini_service.dart';
import '../main.dart' show geminiService;
import 'milestones_page.dart';

/// Roadmap page that displays the MVP development roadmap
class RoadmapPage extends StatefulWidget {
  /// Creates a roadmap page
  const RoadmapPage({
    Key? key,
    required this.idea,
  }) : super(key: key);

  /// The idea with analysis data
  final Map<String, dynamic> idea;

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> with TickerProviderStateMixin {
  late AnimationController _particlesController;
  late AnimationController _generateController;
  late AnimationController _resultsController;
  
  List<Particle> _particles = [];
  bool _isGenerating = true;
  bool _showResults = false;
  double _generationProgress = 0.0;
  
  late List<Map<String, dynamic>> _roadmapPhases;
  late List<Map<String, dynamic>> _milestones;

  @override
  void initState() {
    super.initState();
    
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    )..repeat();
    
    _generateController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Generate particles
    _generateParticles();
    
    // Simulate roadmap generation
    _simulateGeneration();
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
        size: random.nextDouble() * 4 + 1,
        color: AppTheme.primaryGradient[random.nextInt(AppTheme.primaryGradient.length)]
            .withOpacity(0.3 + random.nextDouble() * 0.2),
        speed: random.nextDouble() * 0.5 + 0.2,
        angle: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
        amplitude: random.nextDouble() * 15 + 5,
        phase: random.nextDouble() * 2 * pi,
      ),
    );
  }
  
  void _simulateGeneration() {
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _generationProgress = 0.25;
      });
      
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _generationProgress = 0.5;
        });
        
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _generationProgress = 0.75;
          });
          
          Future.delayed(const Duration(milliseconds: 800), () async {
            // Call the Gemini API for roadmap generation
            await _generateRoadmap();
            
            if (mounted) {
              setState(() {
                _generationProgress = 1.0;
                _isGenerating = false;
              });
              
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  setState(() {
                    _showResults = true;
                  });
                  _resultsController.forward();
                }
              });
            }
          });
        });
      });
    });
  }
  
  Future<void> _generateRoadmap() async {
    try {
      // Get idea details for roadmap generation
      final ideaTitle = widget.idea['title'] ?? '';
      final ideaDescription = widget.idea['description'] ?? '';
      final ideaCategory = widget.idea['category'] ?? '';
      
      // Get analysis data if available
      final analysisData = widget.idea['analysis'] ?? {};
      final strengths = analysisData['strengths'] ?? [];
      final weaknesses = analysisData['weaknesses'] ?? [];
      
      // Combine all information for comprehensive roadmap
      String ideaText = 'Title: $ideaTitle\n'
          'Description: $ideaDescription\n'
          'Category: $ideaCategory\n'
          'Strengths: ${strengths.join(', ')}\n'
          'Weaknesses: ${weaknesses.join(', ')}';
      
      // Call Gemini API for roadmap generation
      final response = await geminiService.generateRoadmap(ideaText);
      
      // Process the roadmap data
      if (response.containsKey('error') && response['error'] == true) {
        // Fallback to default roadmap if API call fails
        _createDefaultRoadmap();
        debugPrint('Error from Gemini API: ${response['message']}');
      } else {
        // Parse the AI-generated roadmap
        _parseGeminiRoadmap(response);
      }
    } catch (e) {
      // Handle exceptions
      debugPrint('Exception during roadmap generation: $e');
      _createDefaultRoadmap();
    }
  }
  
  void _parseGeminiRoadmap(Map<String, dynamic> response) {
    try {
      // Extract phases from the response
      final phases = response['phases'] as List? ?? [];
      
      // Map the phases to our app's data structure
      _roadmapPhases = phases.map((phase) {
        // Extract tasks as a List<String>
        List<String> tasks = [];
        if (phase['tasks'] is List) {
          tasks = (phase['tasks'] as List).map((task) => task.toString()).toList();
        }
        
        return {
          'title': phase['name'] ?? 'Phase',
          'duration': phase['duration'] ?? '2-4 weeks',
          'description': phase['description'] ?? 'Implementation phase',
          'tasks': tasks.isNotEmpty ? tasks : ['Plan', 'Design', 'Implement', 'Test', 'Deploy'],
        };
      }).toList();
      
      // If no phases were returned, use defaults
      if (_roadmapPhases.isEmpty) {
        _createDefaultPhases();
      }
      
      // Extract key milestones from the response
      final keyMilestones = response['keyMilestones'] as List? ?? [];
      
      // Create milestone objects with due dates
      _milestones = [];
      int daysOffset = 14; // Start with 2 weeks
      
      for (final milestone in keyMilestones) {
        _milestones.add({
          'title': milestone.toString(),
          'dueDate': DateTime.now().add(Duration(days: daysOffset)),
          'description': 'Complete this milestone for the project to progress.',
          'completed': false,
        });
        
        daysOffset += 15; // Space milestones about 2 weeks apart
      }
      
      // If no milestones were returned, use defaults
      if (_milestones.isEmpty) {
        _createDefaultMilestones();
      }
    } catch (e) {
      debugPrint('Error parsing roadmap data: $e');
      _createDefaultRoadmap();
    }
  }
  
  void _createDefaultRoadmap() {
    _createDefaultPhases();
    _createDefaultMilestones();
  }
  
  void _createDefaultPhases() {
    _roadmapPhases = [
      {
        'title': 'Planning & Research',
        'duration': '2-3 weeks',
        'description': 'Define project scope, research target market, and gather requirements.',
        'tasks': [
          'Conduct market analysis',
          'Define target user personas',
          'Create initial wireframes',
          'Outline technical requirements',
          'Establish project timeline',
        ],
      },
      {
        'title': 'Design & Prototype',
        'duration': '3-4 weeks',
        'description': 'Create user interface designs and build interactive prototypes for testing.',
        'tasks': [
          'Develop UI/UX design system',
          'Create high-fidelity mockups',
          'Build interactive prototype',
          'Conduct user testing',
          'Iterate based on feedback',
        ],
      },
      {
        'title': 'MVP Development',
        'duration': '6-8 weeks',
        'description': 'Build the core functionality of the product with essential features only.',
        'tasks': [
          'Set up development environment',
          'Implement core functionality',
          'Integrate essential features',
          'Perform internal QA testing',
          'Fix critical bugs and issues',
        ],
      },
      {
        'title': 'Testing & Launch',
        'duration': '3-4 weeks',
        'description': 'Conduct thorough testing and prepare for product launch.',
        'tasks': [
          'Conduct user acceptance testing',
          'Finalize product documentation',
          'Prepare marketing materials',
          'Set up analytics tracking',
          'Launch MVP to early adopters',
        ],
      },
    ];
  }
  
  void _createDefaultMilestones() {
    _milestones = [
      {
        'title': 'Market Research Complete',
        'dueDate': DateTime.now().add(const Duration(days: 14)),
        'description': 'Complete comprehensive market research and competitor analysis.',
        'completed': false,
      },
      {
        'title': 'Prototype Approved',
        'dueDate': DateTime.now().add(const Duration(days: 30)),
        'description': 'Interactive prototype approved by stakeholders.',
        'completed': false,
      },
      {
        'title': 'Core Features Implemented',
        'dueDate': DateTime.now().add(const Duration(days: 60)),
        'description': 'All essential features implemented and functioning.',
        'completed': false,
      },
      {
        'title': 'MVP Public Launch',
        'dueDate': DateTime.now().add(const Duration(days: 90)),
        'description': 'Official public launch of the minimum viable product.',
        'completed': false,
      },
    ];
  }

  @override
  void dispose() {
    _particlesController.dispose();
    _generateController.dispose();
    _resultsController.dispose();
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
          child: Text(
            _isGenerating ? 'Generating Roadmap' : 'MVP Roadmap',
            style: const TextStyle(
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
                child: _isGenerating
                    ? _buildGeneratingContent()
                    : _buildRoadmapContent(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showResults
          ? GlassmorphicButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _navigateToMilestones();
              },
              gradient: AppTheme.secondaryButtonGradient,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Track Milestones',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.flag,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            )
          : null,
    );
  }
  
  void _navigateToMilestones() {
    // Combine all data
    final completeData = {
      ...widget.idea,
      'roadmap': _roadmapPhases,
      'milestones': _milestones,
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MilestonesPage(ideaData: completeData),
      ),
    );
  }
  
  Widget _buildGeneratingContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Roadmap generation animation
        AnimatedBuilder(
          animation: _generateController,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryGradient[1].withOpacity(0.8),
                    AppTheme.primaryGradient[2].withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  center: Alignment.center,
                  radius: 0.8 + (_generateController.value * 0.2),
                ),
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppTheme.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.route,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 40),
        
        // Status text
        Text(
          'Creating MVP Roadmap for "${widget.idea['title']}"',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        Text(
          _getGenerationStatusText(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Progress bar
        GlassmorphicContainer(
          width: double.infinity,
          height: 12,
          borderRadius: 8,
          blur: 5,
          border: 0.5,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * _generationProgress - 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGradient[1],
                          AppTheme.primaryGradient[2],
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          '${(_generationProgress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  
  String _getGenerationStatusText() {
    if (_generationProgress < 0.3) {
      return 'Analyzing project requirements...';
    } else if (_generationProgress < 0.6) {
      return 'Creating development phases and timeline...';
    } else if (_generationProgress < 0.9) {
      return 'Defining key milestones and deliverables...';
    } else {
      return 'Finalizing MVP roadmap and resource allocation...';
    }
  }
  
  Widget _buildRoadmapContent() {
    return AnimatedBuilder(
      animation: _resultsController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _resultsController,
              child: SlideTransition(
                position: AnimationUtils.createSlideInAnimation(
                  controller: _resultsController,
                  begin: const Offset(0.0, -0.2),
                  end: Offset.zero,
                ),
                child: _buildRoadmapHeader(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: AnimationUtils.staggeredList(
                context: context,
                controller: _resultsController,
                itemOffsetInterval: 0.1,
                children: [
                  ...List.generate(
                    _roadmapPhases.length,
                    (index) => _buildPhaseCard(index),
                  ),
                  
                  const SizedBox(height: 60), // Space for FAB
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildRoadmapHeader() {
    return GlassmorphicCard(
      highlightGradient: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGradient[1],
                      AppTheme.primaryGradient[2],
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.speed,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.idea['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Minimum Viable Product Roadmap',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Estimated Timeline: 3-4 months',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This roadmap outlines the key phases and milestones required to develop a minimum viable product for your idea. Follow these steps to turn your concept into reality.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPhaseCard(int index) {
    final phase = _roadmapPhases[index];
    final isLastPhase = index == _roadmapPhases.length - 1;
    
    return Column(
      children: [
        GlassmorphicCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with phase number and title
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGradient[0],
                          AppTheme.primaryGradient[1],
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          phase['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${phase['duration']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryGradient[0],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                phase['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tasks list
              const Text(
                'Key Tasks:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                (phase['tasks'] as List<dynamic>).length,
                (taskIndex) {
                  final task = phase['tasks'][taskIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: AppTheme.primaryGradient[0].withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        // Connector line between phases
        if (!isLastPhase)
          Container(
            width: 2,
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryGradient[0],
                  AppTheme.primaryGradient[1],
                ],
              ),
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