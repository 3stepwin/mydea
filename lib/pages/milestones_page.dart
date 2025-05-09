import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../utils/animation_utils.dart';
import '../widgets/glassmorphic_container.dart';

/// Milestones page for tracking project progress
class MilestonesPage extends StatefulWidget {
  /// Creates a milestones page
  const MilestonesPage({
    Key? key,
    this.ideaData,
  }) : super(key: key);

  /// The complete idea data with roadmap and milestones
  final Map<String, dynamic>? ideaData;

  @override
  State<MilestonesPage> createState() => _MilestonesPageState();
}

class _MilestonesPageState extends State<MilestonesPage> with TickerProviderStateMixin {
  late AnimationController _particlesController;
  late AnimationController _slideController;
  late AnimationController _celebrationController;
  
  List<Particle> _particles = [];
  List<CelebrationParticle> _celebrationParticles = [];
  bool _isCelebrating = false;
  bool _isAddingMilestone = false;
  
  late TextEditingController _newMilestoneController;
  late TextEditingController _milestoneDateController;
  late TextEditingController _milestoneDescriptionController;
  
  // Mock data if not provided
  List<Map<String, dynamic>> _milestones = [];
  Map<String, dynamic>? _selectedIdea;

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
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _newMilestoneController = TextEditingController();
    _milestoneDateController = TextEditingController();
    _milestoneDescriptionController = TextEditingController();
    
    // Generate background particles
    _generateParticles();
    
    // Initialize with provided data or mock data
    _initializeData();
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
  
  void _generateCelebrationParticles() {
    final random = Random();
    _celebrationParticles = List.generate(
      50,
      (index) => CelebrationParticle(
        position: Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2,
        ),
        size: random.nextDouble() * 8 + 4,
        color: AppTheme.primaryGradient[random.nextInt(AppTheme.primaryGradient.length)],
        velocity: Offset(
          (random.nextDouble() * 2 - 1) * 5,
          (random.nextDouble() * 2 - 1) * 5,
        ),
        decayRate: 0.96 + random.nextDouble() * 0.02,
        rotationSpeed: (random.nextDouble() - 0.5) * 0.2,
      ),
    );
  }
  
  void _initializeData() {
    if (widget.ideaData != null) {
      _selectedIdea = widget.ideaData;
      if (_selectedIdea!.containsKey('milestones')) {
        _milestones = List<Map<String, dynamic>>.from(_selectedIdea!['milestones']);
      } else {
        _generateMockMilestones();
      }
    } else {
      _generateMockIdea();
      _generateMockMilestones();
    }
  }
  
  void _generateMockIdea() {
    _selectedIdea = {
      'id': '1',
      'title': 'Smart Home Assistant',
      'description': 'AI-powered home assistant that learns user preferences and automates routine tasks.',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'progress': 0.35,
    };
  }
  
  void _generateMockMilestones() {
    _milestones = [
      {
        'id': '1',
        'title': 'Project Kickoff',
        'dueDate': DateTime.now().subtract(const Duration(days: 7)),
        'description': 'Initial project planning and team assignment',
        'completed': true,
      },
      {
        'id': '2',
        'title': 'Market Research',
        'dueDate': DateTime.now().add(const Duration(days: 7)),
        'description': 'Complete competitor analysis and target market research',
        'completed': false,
      },
      {
        'id': '3',
        'title': 'UI/UX Design',
        'dueDate': DateTime.now().add(const Duration(days: 21)),
        'description': 'Create high-fidelity mockups and design system',
        'completed': false,
      },
      {
        'id': '4',
        'title': 'MVP Development',
        'dueDate': DateTime.now().add(const Duration(days: 45)),
        'description': 'Complete development of core features',
        'completed': false,
      },
      {
        'id': '5',
        'title': 'Beta Testing',
        'dueDate': DateTime.now().add(const Duration(days: 60)),
        'description': 'Release beta version to selected users',
        'completed': false,
      },
    ];
  }

  @override
  void dispose() {
    _particlesController.dispose();
    _slideController.dispose();
    _celebrationController.dispose();
    _newMilestoneController.dispose();
    _milestoneDateController.dispose();
    _milestoneDescriptionController.dispose();
    super.dispose();
  }

  void _toggleMilestoneCompletion(int index) {
    final wasPreviouslyCompleted = _milestones[index]['completed'] as bool;
    
    setState(() {
      _milestones[index]['completed'] = !wasPreviouslyCompleted;
    });
    
    HapticFeedback.mediumImpact();
    
    // Only celebrate when completing a milestone, not when unchecking
    if (!wasPreviouslyCompleted) {
      _showCelebration();
      
      // Update progress on the idea
      if (_selectedIdea != null) {
        final completedCount = _milestones.where((m) => m['completed'] == true).length;
        _selectedIdea!['progress'] = completedCount / _milestones.length;
      }
    }
  }
  
  void _showCelebration() {
    setState(() {
      _isCelebrating = true;
    });
    
    _generateCelebrationParticles();
    _celebrationController.reset();
    _celebrationController.forward().whenComplete(() {
      setState(() {
        _isCelebrating = false;
      });
    });
  }
  
  void _toggleAddMilestone() {
    setState(() {
      _isAddingMilestone = !_isAddingMilestone;
    });
    
    if (_isAddingMilestone) {
      _newMilestoneController.clear();
      _milestoneDateController.clear();
      _milestoneDescriptionController.clear();
    }
  }
  
  void _addNewMilestone() {
    if (_newMilestoneController.text.isEmpty) {
      return;
    }
    
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateTime? dueDate;
    
    try {
      if (_milestoneDateController.text.isNotEmpty) {
        dueDate = dateFormat.parse(_milestoneDateController.text);
      } else {
        dueDate = DateTime.now().add(const Duration(days: 14)); // Default to 2 weeks
      }
    } catch (e) {
      // If date parsing fails, use default
      dueDate = DateTime.now().add(const Duration(days: 14));
    }
    
    final newMilestone = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _newMilestoneController.text,
      'dueDate': dueDate,
      'description': _milestoneDescriptionController.text.isEmpty
          ? 'No description provided'
          : _milestoneDescriptionController.text,
      'completed': false,
    };
    
    setState(() {
      _milestones.add(newMilestone);
      _isAddingMilestone = false;
    });
    
    HapticFeedback.mediumImpact();
    
    // Sort milestones by due date
    _milestones.sort((a, b) {
      final aDate = a['dueDate'] as DateTime;
      final bDate = b['dueDate'] as DateTime;
      return aDate.compareTo(bDate);
    });
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryGradient[0],
              onPrimary: Colors.white,
              surface: AppTheme.backgroundColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppTheme.backgroundColor,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _milestoneDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
            _selectedIdea != null ? 'Milestones: ${_selectedIdea!['title']}' : 'Milestones',
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
            
            // Celebration particles animation
            if (_isCelebrating)
              AnimatedBuilder(
                animation: _celebrationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: CelebrationPainter(
                      particles: _celebrationParticles,
                      animation: _celebrationController.value,
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
                    // Progress and stats
                    _buildProgressSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Milestones list
                    Expanded(
                      child: _buildMilestonesList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Add milestone form
            if (_isAddingMilestone)
              _buildAddMilestoneForm(),
          ],
        ),
      ),
      floatingActionButton: _isAddingMilestone
          ? null
          : GlassmorphicButton(
              onPressed: _toggleAddMilestone,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
    );
  }
  
  Widget _buildProgressSection() {
    if (_selectedIdea == null) {
      return const SizedBox.shrink();
    }
    
    final progress = _selectedIdea!['progress'] as double;
    final completedCount = _milestones.where((m) => m['completed'] == true).length;
    final totalCount = _milestones.length;
    
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              AppTheme.primaryGradient[1].withOpacity(0.8),
                              AppTheme.primaryGradient[1].withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
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
                            Text(
                              _selectedIdea!['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Progress: $completedCount of $totalCount milestones complete',
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
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        HSLColor.fromColor(AppTheme.primaryGradient[1])
                            .withLightness(0.6)
                            .toColor(),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Motivational text
                  Text(
                    _getMotivationalText(progress),
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  String _getMotivationalText(double progress) {
    if (progress < 0.25) {
      return 'Every journey begins with a single step. Keep going!';
    } else if (progress < 0.5) {
      return 'Great progress! You\'re building momentum.';
    } else if (progress < 0.75) {
      return 'You\'re more than halfway there. Keep up the great work!';
    } else if (progress < 1.0) {
      return 'Almost there! The finish line is in sight.';
    } else {
      return 'Congratulations! You\'ve completed all milestones!';
    }
  }
  
  Widget _buildMilestonesList() {
    if (_milestones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No milestones yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first milestone to start tracking progress',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Group milestones by completion status
    final completedMilestones = _milestones.where((m) => m['completed'] == true).toList();
    final pendingMilestones = _milestones.where((m) => m['completed'] == false).toList();
    
    // Sort by due date
    pendingMilestones.sort((a, b) {
      final aDate = a['dueDate'] as DateTime;
      final bDate = b['dueDate'] as DateTime;
      return aDate.compareTo(bDate);
    });
    
    completedMilestones.sort((a, b) {
      final aDate = a['dueDate'] as DateTime;
      final bDate = b['dueDate'] as DateTime;
      return bDate.compareTo(aDate); // Reverse sort for completed
    });
    
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _slideController,
          child: CustomScrollView(
            slivers: [
              // Pending milestones
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      const Text(
                        'Upcoming Milestones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${pendingMilestones.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= pendingMilestones.length) {
                      return null;
                    }
                    return _buildMilestoneItem(
                      pendingMilestones[index],
                      _milestones.indexOf(pendingMilestones[index]),
                    );
                  },
                ),
              ),
              
              // Divider
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Completed milestones
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      const Text(
                        'Completed Milestones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${completedMilestones.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= completedMilestones.length) {
                      return null;
                    }
                    return _buildMilestoneItem(
                      completedMilestones[index],
                      _milestones.indexOf(completedMilestones[index]),
                      isCompleted: true,
                    );
                  },
                ),
              ),
              
              // Space at the bottom
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMilestoneItem(Map<String, dynamic> milestone, int index, {bool isCompleted = false}) {
    final dueDate = milestone['dueDate'] as DateTime;
    final dateString = DateFormat('MMM d, yyyy').format(dueDate);
    final isOverdue = dueDate.isBefore(DateTime.now()) && !isCompleted;
    
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      blur: 10,
      border: 1.0,
      borderRadius: 16,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isCompleted
              ? const Color(0xFF00AA77).withOpacity(0.15)
              : isOverdue
                  ? const Color(0xFFDD5555).withOpacity(0.15)
                  : Colors.white.withOpacity(0.1),
          isCompleted
              ? const Color(0xFF008855).withOpacity(0.05)
              : isOverdue
                  ? const Color(0xFFBB3333).withOpacity(0.05)
                  : Colors.white.withOpacity(0.05),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => _toggleMilestoneCompletion(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF00AA77)
                    : isOverdue
                        ? const Color(0xFFDD5555).withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF00AA77)
                      : isOverdue
                          ? const Color(0xFFDD5555)
                          : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white30,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: isOverdue ? const Color(0xFFDD5555) : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateString,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? const Color(0xFFDD5555) : Colors.white54,
                      ),
                    ),
                    if (isOverdue && !isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'OVERDUE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDD5555),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  milestone['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.white38 : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddMilestoneForm() {
    return Container(
      color: Colors.black45,
      child: Center(
        child: GlassmorphicContainer(
          width: min(MediaQuery.of(context).size.width - 40, 400),
          blur: 20,
          borderRadius: 24,
          border: 1.5,
          linearGradient: LinearGradient(
            colors: [
              AppTheme.primaryGradient[1].withOpacity(0.2),
              AppTheme.primaryGradient[0].withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [
              AppTheme.primaryGradient[0].withOpacity(0.5),
              AppTheme.primaryGradient[1].withOpacity(0.5),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Milestone',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white70,
                      onPressed: _toggleAddMilestone,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Title field
                TextFormField(
                  controller: _newMilestoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Milestone Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00CCFF)),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Date field
                TextFormField(
                  controller: _milestoneDateController,
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    labelStyle: TextStyle(color: Colors.white70),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00CCFF)),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _milestoneDescriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white30),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00CCFF)),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _toggleAddMilestone,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    GlassmorphicButton(
                      onPressed: _addNewMilestone,
                      gradient: AppTheme.secondaryButtonGradient,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Add Milestone',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.add,
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

/// Celebration particle class
class CelebrationParticle {
  /// Creates a celebration particle
  CelebrationParticle({
    required this.position,
    required this.size,
    required this.color,
    required this.velocity,
    required this.decayRate,
    required this.rotationSpeed,
  });

  /// The position of the particle
  Offset position;
  
  /// The size of the particle
  double size;
  
  /// The color of the particle
  Color color;
  
  /// The velocity of the particle
  Offset velocity;
  
  /// The decay rate of the particle
  double decayRate;
  
  /// The rotation speed of the particle
  double rotationSpeed;
  
  /// The current rotation of the particle
  double rotation = 0;
}

/// Custom painter for celebration particles
class CelebrationPainter extends CustomPainter {
  /// Creates a celebration painter
  CelebrationPainter({
    required this.particles,
    required this.animation,
  });

  /// The list of celebration particles
  final List<CelebrationParticle> particles;
  
  /// The animation value
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update position based on velocity and animation
      particle.position += particle.velocity * animation * 20;
      
      // Apply gravity
      particle.velocity += const Offset(0, 0.01);
      
      // Decay velocity
      particle.velocity *= particle.decayRate;
      
      // Update rotation
      particle.rotation += particle.rotationSpeed * animation * 10;
      
      // Create gradient paint
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            particle.color,
            particle.color.withOpacity(0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(
            center: particle.position,
            radius: particle.size,
          ),
        );
      
      // Draw rotated particles
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);
      
      if (Random().nextBool()) {
        // Draw circle
        canvas.drawCircle(Offset.zero, particle.size * (1 - animation), paint);
      } else {
        // Draw star
        final path = Path();
        final outerRadius = particle.size * (1 - animation);
        final innerRadius = outerRadius * 0.4;
        final numPoints = 5;
        
        for (int i = 0; i < numPoints * 2; i++) {
          final radius = i.isEven ? outerRadius : innerRadius;
          final angle = i * pi / numPoints;
          final x = cos(angle) * radius;
          final y = sin(angle) * radius;
          
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        
        path.close();
        canvas.drawPath(path, paint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CelebrationPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}