import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/glassmorphic_container.dart'; // Assuming this exists and is correct
// Need to potentially add import for GlassmorphicButton later
import '../services/gemini_service.dart';
import '../main.dart' show geminiService;
import 'roadmap_page.dart';

/// Idea analysis page that displays AI-generated insights about the idea
class IdeaAnalysisPage extends StatefulWidget {
  /// Creates an idea analysis page
  const IdeaAnalysisPage({
    super.key,
    required this.idea,
  });

  /// The idea to analyze
  final Map<String, dynamic> idea;

  @override
  State<IdeaAnalysisPage> createState() => _IdeaAnalysisPageState();
}

class _IdeaAnalysisPageState extends State<IdeaAnalysisPage> with TickerProviderStateMixin {
  late final AnimationController _particlesController;
  late final AnimationController _analyzeController;
  late final AnimationController _resultsController;

  List<Particle> _particles = [];
  bool _isAnalyzing = true;
  bool _showResults = false;
  double _analysisProgress = 0.0;
  // Initialize _analysisResults to null or a default map to avoid late initialization errors before generation
  Map<String, dynamic>? _analysisResults;


  @override
  void initState() {
    super.initState();

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    )..repeat();

    _analyzeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Generate particles after the first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateParticles();
      // Start analysis simulation after particles are generated
      _simulateAnalysis();
    });
  }

  void _generateParticles() {
    final random = Random();
    // Ensure context is available before using MediaQuery
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    _particles = List.generate(
      20,
      (index) => Particle(
        position: Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        size: random.nextDouble() * 4 + 1,
        // Access colors list from the gradient object and use withAlpha
        // Already corrected in previous step, ensure it remains correct
        color: AppTheme.primaryGradient.colors[random.nextInt(AppTheme.primaryGradient.colors.length)]
            .withAlpha(((0.3 + random.nextDouble() * 0.2) * 255).round().clamp(0, 255)),
        speed: random.nextDouble() * 0.5 + 0.2,
        angle: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.02,
        amplitude: random.nextDouble() * 20 + 10,
        phase: random.nextDouble() * 2 * pi,
      ),
    );
    // Trigger a rebuild if particles are generated after initial build
    if (mounted) {
      setState(() {});
    }
  }


  void _simulateAnalysis() {
    // Show progressive loading with realistic timing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _analysisProgress = 0.2;
      });

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _analysisProgress = 0.4;
        });

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            _analysisProgress = 0.7;
          });

          Future.delayed(const Duration(milliseconds: 1000), () {
            if (!mounted) return;
            setState(() {
              _analysisProgress = 0.9;
            });

            // Actual API call to Gemini
            Future.delayed(const Duration(milliseconds: 1000), () async {
              // Call the async method to get real analysis
              await _generateAnalysisResults();

              // Update UI once analysis is complete
              if (mounted) {
                setState(() {
                  _analysisProgress = 1.0;
                  _isAnalyzing = false;
                });

                // Only show results if analysis didn't result in an error state (check _analysisResults)
                if (_analysisResults != null && !(_analysisResults!['summary'] as String).contains('error')) {
                   Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      setState(() {
                        _showResults = true;
                      });
                      _resultsController.forward();
                    }
                  });
                } else {
                   // Handle case where analysis failed but we still want to stop analyzing state
                   setState(() {
                     _showResults = true; // Or maybe keep it false and show error differently
                   });
                   // Optionally forward results controller to show error state animation
                   _resultsController.forward();
                }
              }
            });
          });
        });
      });
    });
  }

  Future<void> _generateAnalysisResults() async {
    Map<String, dynamic> results;
    try {
      // Get idea details to analyze
      final ideaTitle = widget.idea['title'] ?? '';
      final ideaDescription = widget.idea['description'] ?? '';
      final ideaCategory = widget.idea['category'] ?? '';

      // Combine idea details for analysis
      final ideaText = 'Title: $ideaTitle\nDescription: $ideaDescription\nCategory: $ideaCategory';

      // Call Gemini API for analysis
      final response = await geminiService.analyzeIdea(ideaText);

      // Check if we got valid response
      if (response.containsKey('error') && response['error'] == true) {
        // Handle error - fallback to default values
        results = const {
          'score': 0.75,
          'strengths': [
            'Unique concept with potential',
            'Addresses user needs',
          ],
          'weaknesses': [
            'Further validation needed',
          ],
          'opportunities': [
            'Growing market',
            'Technology advancement',
          ],
          'risks': [
            'Market competition',
            'Implementation challenges',
          ],
          'marketPotential': 0.7,
          'feasibility': 0.65,
          'innovation': 0.8,
          'tags': ['Potential', 'Innovative'],
          'summary': 'Error during analysis. Using fallback data.', // Added summary for error case
        };
        debugPrint('Error from Gemini API: ${response['message']}');
      } else {
        // Successfully got analysis from Gemini
        // Map the response to our UI model
         final rating = (response['rating'] is num) // Check if it's a number (int or double)
            ? response['rating'].toDouble() / 10.0
            : ((response['rating'] is String)
                ? (double.tryParse(response['rating'].toString()) ?? 7.5) / 10.0 // Assume scale 1-10 if string
                : 0.75); // Default fallback

        results = {
          'score': rating.clamp(0.0, 1.0), // Ensure score is between 0 and 1
          'strengths': List<String>.from(response['strengths'] ?? []),
          'weaknesses': List<String>.from(response['weaknesses'] ?? []),
          'opportunities': List<String>.from(response['opportunities'] ?? []),
          'risks': List<String>.from(response['risks'] ?? []),
          // Use specific values if available, otherwise derive from rating
          'marketPotential': (response['marketPotential'] is num ? response['marketPotential'].toDouble() : rating * 0.9).clamp(0.0, 1.0),
          'feasibility': (response['feasibility'] is num ? response['feasibility'].toDouble() : rating * 0.8).clamp(0.0, 1.0),
          'innovation': (response['innovation'] is num ? response['innovation'].toDouble() : rating * 1.1).clamp(0.0, 1.0),
          'tags': List<String>.from(response['tags'] ?? const ['AI-Analyzed', 'Gemini-Powered']),
          'summary': response['summary'] ?? 'Analysis completed successfully.',
        };
      }
    } catch (e) {
      // Handle any exceptions
      debugPrint('Exception during idea analysis: $e');
      results = const {
        'score': 0.7,
        'strengths': ['Concept has potential'],
        'weaknesses': ['More details needed for comprehensive analysis'],
        'opportunities': ['Market exploration recommended'],
        'risks': ['Research competition'],
        'marketPotential': 0.65,
        'feasibility': 0.6,
        'innovation': 0.75,
        'tags': ['Initial Analysis'],
        'summary': 'Basic analysis completed due to an error. Consider adding more details.',
      };
    }
     // Ensure UI updates after results are generated, even in error cases
    if (mounted) {
      setState(() {
         _analysisResults = results; // Update state variable
      });
    }
  }


  @override
  void dispose() {
    _particlesController.dispose();
    _analyzeController.dispose();
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
          shaderCallback: (bounds) => LinearGradient( // Cannot be const if colors aren't const list
            // Already corrected
            colors: AppTheme.primaryGradient.colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            _isAnalyzing ? 'Analyzing Your Idea' : 'Analysis Results',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text color needs to be opaque for ShaderMask
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
        decoration: const BoxDecoration( // Can be const as AppTheme.backgroundGradient is const
          gradient: AppTheme.backgroundGradient, // Use defined gradient
        ),
        child: Stack(
          children: [
            // Background particles animation
            AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size, // Use MediaQuery.size directly
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
                child: _isAnalyzing
                    ? _buildAnalyzingContent()
                    // Check if results are ready and not null
                    : (_showResults && _analysisResults != null
                        ? _buildAnalysisResults()
                        : _buildErrorState()), // Show error or loading if not ready
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showResults && _analysisResults != null
          ? InkWell( // Using InkWell for tap handling
              onTap: () {
                HapticFeedback.mediumImpact();
                _navigateToRoadmap();
              },
              // Replace GlassmorphicButton with GlassmorphicContainer
              child: GlassmorphicContainer(
                width: 220, // Provide required width
                height: 50, // Provide required height
                borderRadius: 30,
                blur: 10,
                border: Border.all(width: 1, color: Colors.white.withAlpha(50)),
                gradient: AppTheme.secondaryButtonGradient,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center, // Center content
                  children: [
                    Text(
                      'Generate Roadmap',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.route,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // Added error state widget
  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
          SizedBox(height: 16),
          Text(
            'Failed to load analysis results.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  void _navigateToRoadmap() {
     // Ensure results are available before navigating
    if (_analysisResults == null) {
       debugPrint("Analysis results not available to generate roadmap.");
       // Optionally show a message to the user
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Analysis results are not ready yet."))
         );
       }
       return;
    }
    // Combine the original idea with the analysis results
    final enhancedIdea = {
      ...widget.idea,
      'analysis': _analysisResults!, // Use null assertion after check
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoadmapPage(idea: enhancedIdea),
      ),
    );
  }

  Widget _buildAnalyzingContent() {
    // Ensure context is available before using MediaQuery
    if (!mounted) return const SizedBox.shrink();
    final mediaQuerySize = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brain animation
        AnimatedBuilder(
          animation: _analyzeController,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    // Access colors list and use withAlpha
                    // Already corrected
                    AppTheme.primaryGradient.colors[0].withAlpha((0.8 * 255).round()),
                    AppTheme.primaryGradient.colors[1].withAlpha((0.5 * 255).round()),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  center: Alignment.center,
                  radius: 0.8 + (_analyzeController.value * 0.2),
                ),
              ),
              child: Center(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient( // Cannot be const
                    // Already corrected
                    colors: AppTheme.primaryGradient.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.psychology,
                    size: 80,
                    color: Colors.white, // Text color needs to be opaque for ShaderMask
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Status text
        Text(
          // Use null-aware operator for safety
          'Analyzing "${widget.idea['title'] ?? 'Your Idea'}"',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),


        const SizedBox(height: 12),

        Text(
          _getAnalysisStatusText(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Progress bar
        // NOTE: GlassmorphicContainer usage might need fixing later
        GlassmorphicContainer(
          width: double.infinity,
          height: 12,
          borderRadius: 8,
          blur: 5,
          border: Border.all(width: 0.5, color: Colors.white.withAlpha(50)),
          gradient: LinearGradient(
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
                    // Ensure width calculation doesn't result in negative value
                    width: max(0, mediaQuerySize.width * _analysisProgress - 36),
                    decoration: BoxDecoration( // Cannot be const
                      gradient: LinearGradient( // Cannot be const
                        // Access colors list
                        // Already corrected
                        colors: AppTheme.primaryGradient.colors,
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
          '${(_analysisProgress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getAnalysisStatusText() {
     if (_analysisProgress < 0.3) {
      return 'Evaluating market potential and innovation level...';
    } else if (_analysisProgress < 0.6) {
      return 'Identifying strengths, weaknesses, and opportunities...';
    } else if (_analysisProgress < 0.9) {
      return 'Assessing feasibility and potential risks...';
    } else if (_analysisProgress < 1.0) {
       return 'Finalizing analysis and preparing recommendations...';
    } else {
      return 'Analysis complete!';
    }
  }


  Widget _buildAnalysisResults() {
    // Ensure context and results are available before building
    if (!mounted || _analysisResults == null) {
      // Show a loading indicator or an error message if results are null
      return const Center(child: CircularProgressIndicator());
    }


    return AnimatedBuilder(
      animation: _resultsController,
      builder: (context, child) {
        // Use ListView for potentially long content
        return ListView(
          padding: EdgeInsets.zero, // Remove default ListView padding
          // Wrap children in a List literal for staggeredList
          // Pass the list returned by staggeredList directly to children
          children: AnimationUtils.staggeredList(
                context: context,
                controller: _resultsController,
                itemOffsetInterval: 0.1,
                children: [
                  // Idea score card
                  _buildScoreCard(),

                  const SizedBox(height: 24),

                  // SWOT analysis
                  const Text(
                    'SWOT Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Strengths & Weaknesses
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align cards top
                    children: [
                      Expanded(
                        child: _buildSwotCard(
                          title: 'Strengths',
                          icon: Icons.trending_up,
                          color: Colors.greenAccent,
                          items: _analysisResults!['strengths'] ?? [], // Handle null
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSwotCard(
                          title: 'Weaknesses',
                          icon: Icons.trending_down,
                          color: Colors.redAccent,
                          items: _analysisResults!['weaknesses'] ?? [], // Handle null
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Opportunities & Risks
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align cards top
                    children: [
                      Expanded(
                        child: _buildSwotCard(
                          title: 'Opportunities',
                          icon: Icons.lightbulb_outline,
                          color: Colors.amberAccent,
                          items: _analysisResults!['opportunities'] ?? [], // Handle null
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSwotCard(
                          title: 'Risks',
                          icon: Icons.warning_amber_outlined,
                          color: Colors.orangeAccent,
                          items: _analysisResults!['risks'] ?? [], // Handle null
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Metrics
                  const Text(
                    'Key Metrics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildMetricsCard(),

                  const SizedBox(height: 80), // Increased space for FAB
                ],
             ),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    // Ensure results are available
    if (_analysisResults == null) return const SizedBox.shrink();

    final score = (_analysisResults!['score'] as num?)?.toDouble() ?? 0.0; // Handle null and cast safely
    final color = score > 0.8
        ? Colors.greenAccent
        : score > 0.6
            ? Colors.amberAccent
            : Colors.redAccent;
    final tags = List<String>.from(_analysisResults!['tags'] ?? []); // Handle null

    // Use GlassmorphicContainer directly as GlassmorphicCard is undefined
    // NOTE: GlassmorphicContainer usage might need fixing later
    return GlassmorphicContainer(
      width: double.infinity,
      height: 150,
      borderRadius: 16,
      blur: 10,
      border: Border.all(width: 1, color: Colors.white.withAlpha(50)),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      // Removed invalid borderGradient parameter
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withAlpha((0.8 * 255).round()), // Use withAlpha
                      color.withAlpha((0.3 * 255).round()), // Use withAlpha
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '${(score * 100).toInt()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Idea Score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score > 0.8
                          ? 'Excellent idea with high potential!'
                          : score > 0.6
                                ? 'Good idea with some potential'
                                : 'Needs improvement',
                      style: const TextStyle(
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map<Widget>((tag) { // Use safe tags list
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.1 * 255).round()), // Use withAlpha
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withAlpha((0.2 * 255).round()), // Use withAlpha
                    width: 1,
                  ),
                ),
                child: Text(
                  tag, // Already string
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  Widget _buildSwotCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> items,
  }) {
    // Use GlassmorphicContainer directly
    // NOTE: GlassmorphicContainer usage might need fixing later
    return GlassmorphicContainer(
      width: double.infinity,
      borderRadius: 16,
      blur: 10,
      border: Border.all(width: 1, color: Colors.white.withAlpha(50)), // Use Border object
      gradient: LinearGradient( // Use correct 'gradient' parameter
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      // Removed invalid borderGradient parameter
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Make column height fit content
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text(
              'None identified',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            )
          else
            ...items.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.toString(), // Ensure item is string
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricsCard() {
    // Ensure results are available
    if (_analysisResults == null) return const SizedBox.shrink();

    // Use GlassmorphicContainer directly
    // NOTE: GlassmorphicContainer usage might need fixing later
    return GlassmorphicContainer(
      width: double.infinity,
      borderRadius: 16,
      blur: 10,
      border: Border.all(width: 1, color: Colors.white.withAlpha(50)), // Use Border object
      gradient: LinearGradient( // Use correct 'gradient' parameter
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      ),
      // Removed invalid borderGradient parameter
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Make column height fit content
        children: [
          _buildMetricItem(
            title: 'Market Potential',
            value: (_analysisResults!['marketPotential'] as num?)?.toDouble() ?? 0.0, // Safe cast
            // NOTE: Gradient usage might need fixing later
            color: AppTheme.primaryGradient.colors[0], // Access colors list
          ),
          const SizedBox(height: 20),
          _buildMetricItem(
            title: 'Feasibility',
            value: (_analysisResults!['feasibility'] as num?)?.toDouble() ?? 0.0, // Safe cast
            color: AppTheme.primaryGradient.colors[1], // Access colors list
          ),
          const SizedBox(height: 20),
          _buildMetricItem(
            title: 'Innovation',
            value: (_analysisResults!['innovation'] as num?)?.toDouble() ?? 0.0, // Safe cast
            color: AppTheme.primaryGradient.colors[2], // Access colors list
          ),
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
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0), // Ensure value is clamped
            backgroundColor: Colors.white.withAlpha((0.1 * 255).round()), // Use withAlpha
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Particle class for the animated particles
class Particle {
  /// Creates a particle with the given properties
  Particle({ // Removed const
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
  Offset position; // Made non-final

  /// The size of the particle
  double size; // Made non-final

  /// The color of the particle
  Color color; // Made non-final

  /// The speed of the particle
  double speed; // Made non-final

  /// The angle of movement
  double angle; // Made non-final

  /// The rotation speed of the particle
  double rotationSpeed; // Made non-final

  /// The amplitude of the sine wave motion
  double amplitude; // Made non-final

  /// The phase of the sine wave motion
  double phase; // Made non-final
}

/// Custom painter for particles
class ParticlesPainter extends CustomPainter {
  /// Creates a particles painter
  ParticlesPainter({ // Removed const
    required this.particles,
    required this.animation,
  });

  /// The list of particles
  final List<Particle> particles;

  /// The animation value (expected to be from a repeating controller, 0.0 to 1.0)
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    for (var particle in particles) {
      // Update particle position based on its angle and speed
      // This simulates continuous movement; adjust logic as needed
      particle.position += Offset(cos(particle.angle), sin(particle.angle)) * particle.speed;

      // Apply sine wave motion based on the global animation value
      final waveOffset = Offset(
        sin(particle.phase + animation * 2 * pi) * particle.amplitude,
        cos(particle.phase + animation * 2 * pi) * particle.amplitude,
      );
      // The final drawing position includes the base position, linear movement, and wave motion
      final currentPosition = particle.position + waveOffset;


      // Wrap particles around screen edges
      // Adjust position if particle goes off-screen
      if (currentPosition.dx < -particle.size) {
         // Went off left edge, wrap to right edge with random y
        particle.position = Offset(size.width + particle.size, random.nextDouble() * size.height);
      } else if (currentPosition.dx > size.width + particle.size) {
        // Went off right edge, wrap to left edge with random y
        particle.position = Offset(-particle.size, random.nextDouble() * size.height);
      }

      if (currentPosition.dy < -particle.size) {
        // Went off top edge, wrap to bottom edge with random x
        particle.position = Offset(random.nextDouble() * size.width, size.height + particle.size);
      } else if (currentPosition.dy > size.height + particle.size) {
        // Went off bottom edge, wrap to top edge with random x
         particle.position = Offset(random.nextDouble() * size.width, -particle.size);
      }


      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // Keep blur

      // Draw the particle at its calculated current position
      canvas.drawCircle(currentPosition, particle.size, paint);
    }
  }


  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    // Repaint whenever animation value changes to update particle positions
    return animation != oldDelegate.animation;
  }
}
