import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/glassmorphic_container.dart';
import 'idea_analysis_page.dart';

/// Idea capture page where users can input new ideas
class IdeaCapturePage extends StatefulWidget {
  /// Creates an idea capture page
  const IdeaCapturePage({Key? key}) : super(key: key);

  @override
  State<IdeaCapturePage> createState() => _IdeaCapturePageState();
}

class _IdeaCapturePageState extends State<IdeaCapturePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  
  late AnimationController _slideController;
  late AnimationController _particlesController;
  List<Particle> _particles = [];
  
  int _currentStep = 0;
  final int _totalSteps = 4;
  
  bool _isAudioRecording = false;
  bool _isSpeechToTextActive = false;
  
  final List<String> _steps = [
    'Title & Description',
    'Problem Statement',
    'Solution Approach',
    'Target Audience',
  ];

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    )..repeat();
    
    // Generate particles
    _generateParticles();
  }
  
  void _generateParticles() {
    final random = Random();
    _particles = List.generate(
      10,
      (index) => Particle(
        position: Offset(
          random.nextDouble() * MediaQuery.of(context).size.width,
          random.nextDouble() * MediaQuery.of(context).size.height,
        ),
        size: random.nextDouble() * 3 + 1,
        color: AppTheme.primaryGradient.colors[random.nextInt(AppTheme.primaryGradient.colors.length)]
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
    _titleController.dispose();
    _descriptionController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _targetAudienceController.dispose();
    _slideController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _slideController.reset();
      _slideController.forward();
      HapticFeedback.selectionClick();
    } else {
      _submitIdea();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _slideController.reset();
      _slideController.forward();
      HapticFeedback.selectionClick();
    }
  }

  void _submitIdea() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      
      // Create idea object
      final idea = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'description': _descriptionController.text,
        'problem': _problemController.text,
        'solution': _solutionController.text,
        'targetAudience': _targetAudienceController.text,
        'createdAt': DateTime.now(),
        'progress': 0.0,
      };
      
      // Navigate to analysis page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IdeaAnalysisPage(idea: idea),
        ),
      );
    }
  }

  void _toggleMicRecording() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isAudioRecording = !_isAudioRecording;
    });
    // TODO: Implement actual audio recording functionality
  }

  void _toggleSpeechToText() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSpeechToTextActive = !_isSpeechToTextActive;
    });
    // TODO: Implement actual speech to text functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: AppTheme.primaryGradient.colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: const Text(
            'Capture Your Idea',
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
          gradient: AppTheme.primaryGradient,
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      
                      // Progress indicator
                      Row(
                        children: [
                          for (int i = 0; i < _totalSteps; i++)
                            Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: i <= _currentStep
                                      ? AppTheme.primaryGradient
                                      : LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.1),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Step title
                      Text(
                        'Step ${_currentStep + 1}: ${_steps[_currentStep]}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Form fields based on current step
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _slideController,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _slideController,
                              child: SlideTransition(
                                position: AnimationUtils.createSlideInAnimation(
                                  controller: _slideController,
                                  begin: const Offset(0.1, 0.0),
                                  end: Offset.zero,
                                ),
                                child: _buildCurrentStepContent(),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentStep > 0)
                            TextButton.icon(
                              onPressed: _prevStep,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                              ),
                            )
                          else
                            const SizedBox(),
                          
                          InkWell(
                            onTap: _nextStep,
                            child: GlassmorphicContainer(
                              width: _currentStep < _totalSteps - 1 ? 100 : 120, // Adjust width as needed
                              height: 50, // Adjust height as needed
                              gradient: _currentStep < _totalSteps - 1
                                  ? AppTheme.primaryGradient // Default gradient for "Next"
                                  : AppTheme.secondaryGradient,
                              borderRadius: 25,
                              blur: 10,
                              border: Border.all(width: 1, color: Colors.white.withOpacity(0.2)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Text(
                                  _currentStep < _totalSteps - 1 ? 'Next' : 'Analyze',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep < _totalSteps - 1
                                      ? Icons.arrow_forward
                                      : Icons.psychology,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildTitleDescriptionStep();
      case 1:
        return _buildProblemStep();
      case 2:
        return _buildSolutionStep();
      case 3:
        return _buildTargetAudienceStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTitleDescriptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title field
        GlassmorphicContainer(
          width: double.infinity,
          height: 70, // Added height
          blur: 10,
          borderRadius: 16,
          border: Border.all(width: 0.5, color: Colors.white.withOpacity(0.2)), // Corrected border
          gradient: LinearGradient( 
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Idea Title',
              labelStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title for your idea';
              }
              return null;
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Description field
        Expanded(
          child: GlassmorphicContainer(
            width: double.infinity,
            height: double.infinity, // Height will be managed by Expanded
            blur: 10,
            borderRadius: 16,
            border: Border.all(width: 0.5, color: Colors.white.withOpacity(0.2)), // Corrected border
            gradient: LinearGradient( 
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Stack(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Describe your idea in detail',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your idea';
                    }
                    return null;
                  },
                ),
                
                // Voice input buttons
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _isSpeechToTextActive
                            ? AppTheme.primaryGradient.colors[0]
                            : Colors.white.withOpacity(0.1),
                        child: IconButton(
                          icon: Icon(
                            _isSpeechToTextActive ? Icons.mic : Icons.mic_none,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: _toggleSpeechToText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _isAudioRecording
                            ? AppTheme.primaryGradient.colors[1]
                            : Colors.white.withOpacity(0.1),
                        child: IconButton(
                          icon: Icon(
                            _isAudioRecording ? Icons.stop : Icons.fiber_manual_record,
                            color: _isAudioRecording ? Colors.white : Colors.red,
                            size: 18,
                          ),
                          onPressed: _toggleMicRecording,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProblemStep() {
    final Gradient stepGradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Expanded( 
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity, 
        blur: 10,
        borderRadius: 16,
        border: Border.all(width: 0.5, color: Colors.white.withOpacity(0.2)), 
        // gradient: stepGradient, // Gradient removed for testing
      child: Stack(
        children: [
          TextFormField(
            controller: _problemController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'What problem does your idea solve?',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Describe the pain points or challenges your idea addresses',
              hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe the problem your idea solves';
              }
              return null;
            },
          ),
          
          // Voice input buttons
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isSpeechToTextActive
                      ? AppTheme.primaryGradient.colors[0]
                      : Colors.white.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      _isSpeechToTextActive ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _toggleSpeechToText,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isAudioRecording
                      ? AppTheme.primaryGradient.colors[1]
                      : Colors.white.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      _isAudioRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: _isAudioRecording ? Colors.white : Colors.red,
                      size: 18,
                    ),
                    onPressed: _toggleMicRecording,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionStep() {
    final Gradient stepGradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Expanded( 
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity, 
        blur: 10,
        borderRadius: 16,
        border: Border.all(width: 0.5, color: Colors.white.withOpacity(0.2)), 
        gradient: stepGradient,
      child: Stack(
        children: [
          TextFormField(
            controller: _solutionController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'How does your idea solve the problem?',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Explain your approach and what makes it unique',
              hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe how your idea solves the problem';
              }
              return null;
            },
          ),
          
          // Voice input buttons
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isSpeechToTextActive
                      ? AppTheme.primaryGradient.colors[0]
                      : Colors.white.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      _isSpeechToTextActive ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _toggleSpeechToText,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isAudioRecording
                      ? AppTheme.primaryGradient.colors[1]
                      : Colors.white.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      _isAudioRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: _isAudioRecording ? Colors.white : Colors.red,
                      size: 18,
                    ),
                    onPressed: _toggleMicRecording,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAudienceStep() {
    final Gradient stepGradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Expanded( 
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity, 
        blur: 10,
        borderRadius: 16,
        border: Border.all(width: 0.5, color: Colors.white.withOpacity(0.2)), 
        gradient: stepGradient,
      child: Stack(
        children: [
          TextFormField(
            controller: _targetAudienceController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Who is your target audience?',
              labelStyle: TextStyle(color: Colors.white70),
              hintText: 'Describe the customers or users who would benefit from your idea',
              hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe your target audience';
              }
              return null;
            },
          ),
          
          // Voice input buttons
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isSpeechToTextActive
                      ? AppTheme.primaryGradient.colors[0]
                      : Colors.white.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      _isSpeechToTextActive ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _toggleSpeechToText,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isAudioRecording
                      ? AppTheme.primaryGradient.colors[1]
                      : Colors.white.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      _isAudioRecording ? Icons.stop : Icons.fiber_manual_record,
                      color: _isAudioRecording ? Colors.white : Colors.red,
                      size: 18,
                    ),
                    onPressed: _toggleMicRecording,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
