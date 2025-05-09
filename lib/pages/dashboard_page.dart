import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';
import 'welcome_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String username = 'Innovator';
  List<Map<String, dynamic>> recentIdeas = [];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMockIdeas(); // This would be replaced with actual data fetching
  }
  
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Innovator';
    });
  }
  
  // This is just for demo purposes - would be replaced with actual data fetching
  void _loadMockIdeas() {
    recentIdeas = [
      {
        'id': '1',
        'title': 'Smart Home Assistant',
        'description': 'AI-powered home assistant that learns user preferences and automates routine tasks.',
        'progress': 65,
        'tags': ['AI', 'IoT'],
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '2',
        'title': 'AR Shopping Experience',
        'description': 'Augmented reality app that allows users to visualize products in their home before purchasing.',
        'progress': 40,
        'tags': ['AR', 'Retail'],
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];
  }
  
  void _navigateToNewIdea() {
    // This would navigate to the Idea Capture page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New idea capture feature coming soon!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard header
                FadeInAnimation(
                  delay: 0,
                  child: SlideInAnimation(
                    direction: SlideDirection.down,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $username!',
                              style: AppTheme.subheadingStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ready to bring your ideas to life?',
                              style: AppTheme.subtitleStyle,
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick actions
                FadeInAnimation(
                  delay: 200,
                  child: Text(
                    'Quick Actions',
                    style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Quick action cards
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildQuickActionCard(
                        title: 'New Idea',
                        icon: Icons.lightbulb_outline,
                        color: AppTheme.primaryColor,
                        onTap: _navigateToNewIdea,
                        delay: 0,
                      ),
                      _buildQuickActionCard(
                        title: 'Milestones',
                        icon: Icons.flag_outlined,
                        color: AppTheme.secondaryColor,
                        onTap: () {},
                        delay: 100,
                      ),
                      _buildQuickActionCard(
                        title: 'Analytics',
                        icon: Icons.analytics_outlined,
                        color: AppTheme.tertiaryColor,
                        onTap: () {},
                        delay: 200,
                      ),
                      _buildQuickActionCard(
                        title: 'Compare',
                        icon: Icons.compare_arrows,
                        color: const Color(0xFFFF66CC),
                        onTap: () {},
                        delay: 300,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recent ideas
                FadeInAnimation(
                  delay: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Ideas',
                        style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View All',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Idea cards
                Expanded(
                  child: ListView.builder(
                    itemCount: recentIdeas.length,
                    itemBuilder: (context, index) {
                      final idea = recentIdeas[index];
                      return _buildIdeaCard(
                        idea: idea,
                        delay: 500 + (index * 100),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewIdea,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: AppTheme.glowShadow(
              color: AppTheme.primaryColor,
              intensity: 0.5,
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return FadeInAnimation(
      delay: delay,
      child: GlassmorphicContainer(
        margin: const EdgeInsets.only(right: 15),
        width: 100,
        height: 100,
        borderRadius: 15,
        blur: 8,
        opacity: 0.1,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color.withOpacity(0.4),
          ],
        ),
        border: Border.all(
          width: 1.5,
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            splashColor: color.withOpacity(0.2),
            highlightColor: color.withOpacity(0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildIdeaCard({
    required Map<String, dynamic> idea,
    required int delay,
  }) {
    return FadeInAnimation(
      delay: delay,
      child: GlassmorphicContainer(
        margin: const EdgeInsets.only(bottom: 16),
        width: double.infinity,
        height: 135, // Reduced height slightly
        borderRadius: 15,
        blur: 8,
        opacity: 0.1,
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          width: 1,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {},
            splashColor: AppTheme.primaryColor.withOpacity(0.1),
            highlightColor: AppTheme.primaryColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(12), // Reduced padding slightly
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Important to prevent overflow
                children: [
                  // Title and progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          idea['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${idea['progress']}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6), // Reduced spacing
                  
                  // Description
                  Text(
                    idea['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8), // Reduced spacing
                  
                  // Tags and date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            for (final tag in idea['tags'])
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        _formatTimeAgo(idea['createdAt']),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8), // Reduced spacing
                  
                  // Progress bar - Fixed calculation to use parent container width
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: (idea['progress'] / 100) * constraints.maxWidth,
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(3),
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
          ),
        ),
      ),
    );
  }
}