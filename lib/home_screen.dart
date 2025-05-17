import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/period_type.dart';
import 'providers/transaction_providers.dart';
import 'providers/budget_providers.dart';
import 'providers/category_providers.dart';
import 'providers/user_providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/categories_screen.dart';

/// Home screen of the application which serves as the main navigation hub
/// for accessing different screens in the budget app
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Current selected navigation index
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize data on app start
    Future.microtask(() {
      // Load user data
      ref.read(userProvider.notifier).fetchCurrentUser();

      // Load categories
      ref.read(categoriesProvider.notifier).fetchCategories();

      // Load transactions and budgets for the current period
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1); // Current month start

      ref.read(transactionsProvider.notifier).fetchTransactions(
            startDate: startDate,
            endDate: now,
          );

      ref.read(budgetProvider.notifier).fetchBudget(
            periodType: PeriodType.monthly,
          );
    });
  }

  /// Get the title for the current screen
  Widget _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text('Dashboard');
      case 1:
        return const Text('Transactions');
      case 2:
        return const Text('Budget');
      case 3:
        return const Text('Categories');
      default:
        return const Text('Simple Budget');
    }
  }

  /// Build the main body based on the selected navigation index
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const TransactionsScreen();
      case 2:
        return const BudgetScreen();
      case 3:
        return const CategoriesScreen();
      default:
        return const DashboardScreen();
    }
  }

  /// Build the bottom navigation bar with TikTok-style animations
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        // Add subtle shadow/glow effect at the top of the navigation bar
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        onTap: (index) {
          // Add haptic feedback for better tactile response
          HapticFeedback.lightImpact();
          
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _selectedIndex == 0 
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.dashboard_outlined),
            ),
            activeIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.dashboard),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _selectedIndex == 1 
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_long_outlined),
            ),
            activeIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.receipt_long),
            ),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _selectedIndex == 2 
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.pie_chart_outline),
            ),
            activeIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.pie_chart),
            ),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _selectedIndex == 3 
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.category_outlined),
            ),
            activeIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.category),
            ),
            label: 'Categories',
          ),
        ],
      ),
    );
  }

  /// Build floating action button based on current screen with TikTok-inspired design
  Widget? _buildFloatingActionButton() {
    final colorScheme = Theme.of(context).colorScheme;
    
    // No FAB for Dashboard and Budget screens
    if (_selectedIndex != 1 && _selectedIndex != 3) return null;
    
    // Determine action based on the active screen
    VoidCallback onPressed = _selectedIndex == 1 
        ? () => _showAddTransactionDialog() 
        : () => _showAddCategoryDialog();
    
    // Create a visually appealing FAB with gradient and animation
    return Container(
      decoration: BoxDecoration(
        // Add a subtle shadow around the FAB
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        // Add a gradient or solid background based on theme
        gradient: LinearGradient(
          colors: [
            colorScheme.secondary,
            Color.lerp(colorScheme.secondary, colorScheme.primary, 0.6) ?? colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 56,
      width: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.mediumImpact(); // Add haptic feedback for better UX
            onPressed();
          },
          child: Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build the floating action button location to position it properly
  FloatingActionButtonLocation get _fabLocation {
    return FloatingActionButtonLocation.endFloat;
  }

  /// Show dialog to add a transaction
  Future<void> _showAddTransactionDialog() async {
    // Transaction form would go here
    // For now we'll show a simple dialog to add a transaction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Add transaction functionality coming soon')),
    );
  }

  /// Show dialog to add a category
  Future<void> _showAddCategoryDialog() async {
    // Category form would go here
    // For now we'll show a simple dialog to add a category
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add category functionality coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get color scheme for consistent styling
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      // Enhanced app bar with dynamic TikTok-inspired look
      appBar: AppBar(
        // Use Container with gradient decoration for vibrant look
        flexibleSpace: Container(
          decoration: BoxDecoration(
            // Enhanced gradient with more depth and visual interest
            gradient: LinearGradient(
              colors: [
                colorScheme.brightness == Brightness.dark
                    ? colorScheme.surface
                    : colorScheme.primaryContainer.withOpacity(0.8),
                colorScheme.brightness == Brightness.dark
                    ? colorScheme.surfaceVariant
                    : colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // Add subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // Remove default elevation and add custom shadow in flexibleSpace
        elevation: 0,
        centerTitle: true, // Center-aligned title like TikTok
        title: AnimatedSwitcher(
          // Animate title changes when switching between tabs
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: _getScreenTitle(),
        ),
        actions: <Widget>[
          // Enhanced notification button with TikTok-inspired styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Container with subtle background for the button
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.brightness == Brightness.dark
                        ? colorScheme.surfaceVariant.withOpacity(0.3)
                        : colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    onPressed: () {
                      // Add haptic feedback for interaction
                      HapticFeedback.mediumImpact();
                      // Notification functionality would go here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications feature coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
                // Notification badge with animated glow effect
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.secondary.withOpacity(0.6),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Profile menu with enhanced TikTok-inspired styling
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.brightness == Brightness.dark
                      ? colorScheme.surfaceVariant.withOpacity(0.3)
                      : colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: colorScheme.primary,
                  size: 22,
                ),
              ),
              onSelected: (value) async {
                if (value == 'signout') {
                  // Add haptic feedback
                  HapticFeedback.mediumImpact();
                  
                  try {
                    // Sign out logic
                    await Supabase.instance.client.auth.signOut();
                    ref.read(userProvider.notifier).clearUser();

                    // Navigate to login screen
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  } catch (e) {
                    // Handle error
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign out failed: $e')),
                      );
                    }
                  }
                }
              },
              // TikTok-inspired popup styling
              color: colorScheme.surface,
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              itemBuilder: (context) => <PopupMenuEntry<String>>[
                // Sign out option with enhanced styling
                PopupMenuItem<String>(
                  value: 'signout',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: <Widget>[
                        // Icon with container background for visual interest
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.logout_rounded, 
                            size: 18, 
                            color: colorScheme.error,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Add padding at the end
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: _fabLocation,
    );
  }
}
