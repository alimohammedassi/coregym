import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Dummy MuscleTrainingPage for navigation (replace with your actual implementation or import)
class MuscleTrainingPage extends StatelessWidget {
  final String muscleGroup;
  const MuscleTrainingPage({super.key, required this.muscleGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$muscleGroup Training')),
      body: Center(
        child: Text(
          'Welcome to $muscleGroup training!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// ProfilePage with logout functionality
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C5CE7),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF424242)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF6C5CE7),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? user?.email ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      user!.email!,
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Profile Options
            _buildProfileOption(
              context,
              Icons.person_outline,
              'Edit Profile',
              () {
                // TODO: Navigate to edit profile page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile coming soon!')),
                );
              },
            ),

            _buildProfileOption(
              context,
              Icons.settings_outlined,
              'Settings',
              () {
                // TODO: Navigate to settings page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),

            _buildProfileOption(
              context,
              Icons.help_outline,
              'Help & Support',
              () {
                // TODO: Navigate to help page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),

            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF424242)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6C5CE7), size: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const FitnessHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// **FitnessHomePage - Main Fitness Home Page**
///
/// This is the main interface of the app. It's a `StatefulWidget` because it needs to manage
/// the selection state in the bottom navigation bar and control animations.
class FitnessHomePage extends StatefulWidget {
  const FitnessHomePage({super.key});

  @override
  State<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends State<FitnessHomePage>
    with TickerProviderStateMixin {
  // Animation controllers for managing entrance effects.
  late AnimationController _fadeController; // For controlling fade effect
  late AnimationController _slideController; // For controlling slide effect

  // Animations to provide smooth entrance effects.
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Variable to track the currently selected item in the bottom navigation bar.
  int _selectedNavIndex = 1; // Start with Home selected

  @override
  void initState() {
    super.initState();
    // --- Animation Initialization ---
    // Initialize controllers and set animation duration.
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Define animation type (0 to 1 for opacity, bottom to top for position).
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animation when page loads.
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    // --- Dispose Controllers ---
    // It's essential to dispose controllers when closing the page to free resources and prevent memory leaks.
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// **_navigateToMuscleTraining - Navigation function for muscle training pages**
  ///
  /// This function is responsible for navigating to the specified muscle training page.
  void _navigateToMuscleTraining(String muscleGroup) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MuscleTrainingPage(muscleGroup: muscleGroup),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Build Main Interface ---
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Main background color
      body: SafeArea(
        // Ensures content doesn't overlap with system areas (like status bar).
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              // Allows scrolling if content is longer than screen.
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(), // Build header section
                  const SizedBox(height: 32),
                  _buildStatsOverview(), // Build stats card
                  const SizedBox(height: 32),
                  _buildCaloriesCard(), // Build calories card
                  const SizedBox(height: 32),
                  _buildFeaturedPlans(), // Build featured plans section
                  const SizedBox(height: 32),
                  _buildWorkoutPrograms(), // Build workout programs section
                  const SizedBox(
                    height: 120,
                  ), // Extra space for floating bottom bar
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigation(), // Build bottom navigation bar
    );
  }

  /// **_buildHeader - Build Header Section**
  ///
  /// This section displays welcome message, date, and notification icon.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Friday, May 20',
                    style: TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text(
                      'Good Morning',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('🔥', style: TextStyle(fontSize: 32)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready for your workout?',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.8),
                  const Color(0xFFA29BFE).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications'),
                      backgroundColor: Colors.blueAccent,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **_buildStatsOverview - Build Stats Overview Card**
  ///
  /// This card displays a summary of key statistics like calories burned,
  /// step count, and active time.
  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.9),
            const Color(0xFFA29BFE).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStatItem(
                  '2,847',
                  'Calories',
                  Icons.local_fire_department,
                ),
              ),
              Container(
                width: 1,
                height: 70,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildStatItem(
                  '12.5k',
                  'Steps Today',
                  Icons.directions_walk,
                ),
              ),
              Container(
                width: 1,
                height: 70,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildStatItem('45m', 'Active Time', Icons.timer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// **_buildStatItem - Build Single Stat Item**
  ///
  /// Helper widget to create an individual stat item containing icon, value, and label.
  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// **_buildCaloriesCard - Build Weekly Activity Card (Calories)**
  ///
  /// This card contains a bar chart showing weekly activity.
  Widget _buildCaloriesCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF424242), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00D4AA),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Weekly Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4AA).withOpacity(0.2),
                      const Color(0xFF00B894).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00D4AA).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: const Color(0xFF00D4AA),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '+12%',
                      style: TextStyle(
                        color: Color(0xFF00D4AA),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(height: 220, child: _buildCaloriesChart()),
        ],
      ),
    );
  }

  /// **_buildCaloriesChart - Build Calories Chart**
  ///
  /// Uses `fl_chart` library to create an interactive bar chart.
  Widget _buildCaloriesChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 12,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}%',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _generateBarGroups(),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  /// **_generateBarGroups - Generate Chart Data**
  ///
  /// Helper function to create dummy data for the weekly chart.
  List<BarChartGroupData> _generateBarGroups() {
    final List<double> weekData = [30, 45, 35, 50, 40, 60, 55];
    final List<double> goalData = [80, 90, 75, 85, 95, 70, 88];

    return List.generate(weekData.length, (index) {
      return BarChartGroupData(
        x: index,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: weekData[index],
            gradient: const LinearGradient(
              colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 14,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          BarChartRodData(
            toY: goalData[index],
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C5CE7).withOpacity(0.4),
                const Color(0xFFA29BFE).withOpacity(0.4),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 14,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
        ],
      );
    });
  }

  /// **_buildFeaturedPlans - Build Featured Plans Section**
  ///
  /// Displays a horizontal list of featured workout plan cards.
  Widget _buildFeaturedPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Featured Plans',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Handpicked workouts for you',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: () => debugPrint('View all plans tapped'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF6C5CE7),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _buildFeaturedPlanCard(
                'Lower Body Workout',
                '15 exercises • 45 min',
                'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
                const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                ),
                'legs',
              ),
              const SizedBox(width: 20),
              _buildFeaturedPlanCard(
                'Upper Body Strength',
                '12 exercises • 35 min',
                'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
                const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                'chest',
              ),
              const SizedBox(width: 20),
              _buildFeaturedPlanCard(
                'Core Power',
                '10 exercises • 25 min',
                'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
                const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                'core',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// **_buildFeaturedPlanCard - Build Featured Plan Card**
  ///
  /// Helper widget to create a single workout plan card with image and details.
  Widget _buildFeaturedPlanCard(
    String title,
    String subtitle,
    String imageUrl,
    Gradient gradient,
    String muscleGroup,
  ) {
    return GestureDetector(
      onTap: () => _navigateToMuscleTraining(muscleGroup),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: 320,
                height: 240,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : Container(
                          width: 320,
                          height: 240,
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6C5CE7),
                            ),
                          ),
                        );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 320,
                    height: 240,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 320,
                height: 240,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Start Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutPrograms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout Programs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your focus area',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.0,
          children: [
            _buildWorkoutProgramCard(
              'Chest',
              'Build upper body strength',
              'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400',
              const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
              ),
              Icons.fitness_center,
            ),
            _buildWorkoutProgramCard(
              'Arms',
              'Sculpt powerful arms',
              'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400',
              const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              Icons.sports_gymnastics,
            ),
            _buildWorkoutProgramCard(
              'Legs',
              'Strong foundation',
              'https://images.unsplash.com/photo-1434682772747-f16d3ea162c3?w=400',
              const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              Icons.directions_run,
            ),
            _buildWorkoutProgramCard(
              'Core',
              'Strengthen your core',
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
              const LinearGradient(
                colors: [Color(0xFFFD79A8), Color(0xFFE84393)],
              ),
              Icons.self_improvement,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutProgramCard(
    String title,
    String subtitle,
    String imageUrl,
    Gradient gradient,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _navigateToMuscleTraining(title.toLowerCase()),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -3,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6C5CE7),
                            ),
                          ),
                        );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    splashColor: Colors.white.withOpacity(0.1),
                    highlightColor: Colors.white.withOpacity(0.05),
                    onTap: () => _navigateToMuscleTraining(title.toLowerCase()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 88,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 34),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // --- Main Glass Bar ---
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                  spreadRadius: -8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-1.2, -1.2),
                    end: const Alignment(1.2, 1.2),
                    stops: const [0.0, 0.3, 0.7, 1.0],
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUltraGlassNavItem(
                      Icons.analytics_outlined,
                      0,
                      onTap: () {
                        setState(() {
                          _selectedNavIndex = 0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Analytics page coming soon!'),
                              ],
                            ),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 75), // Empty space for center button
                    _buildUltraGlassNavItem(
                      Icons.person_rounded,
                      2,
                      onTap: () {
                        setState(() {
                          _selectedNavIndex = 2;
                        });
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const ProfilePage(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOutCubic;
                                  var tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- Floating Center Button (Home) ---
          Positioned(
            top: -32,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _selectedNavIndex == 1
                    ? const LinearGradient(
                        colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: _selectedNavIndex == 1
                      ? Colors.white.withOpacity(0.5)
                      : Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _selectedNavIndex == 1
                        ? const Color(0xFF6C5CE7).withOpacity(0.4)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: _selectedNavIndex == 1 ? 20 : 50,
                    offset: const Offset(0, 25),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(37.5),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      _selectedNavIndex = 1;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.home, color: Colors.white),
                            SizedBox(width: 8),
                            Text('You\'re already on Home page!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Center(
                    child: Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraGlassNavItem(
    IconData icon,
    int index, {
    required VoidCallback onTap,
  }) {
    final bool isSelected = _selectedNavIndex == index;

    return Expanded(
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(44),
          gradient: isSelected
              ? RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 2.5,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(44),
            splashColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.white.withOpacity(0.08),
            onTap: onTap,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.6),
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
