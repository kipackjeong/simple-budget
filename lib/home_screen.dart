import 'package:flutter/material.dart';
import 'package:spending_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:spending_tracker/core/widgets/balance_card.dart';
import 'package:spending_tracker/core/widgets/apple_pay_button.dart';
import 'package:spending_tracker/features/transactions/presentation/widgets/infinite_transaction_list.dart';
import 'package:spending_tracker/features/transactions/presentation/widgets/add_transaction_form.dart';
import 'package:spending_tracker/features/transactions/data/repositories/supabase_transaction_repository.dart';
import 'package:spending_tracker/features/transactions/presentation/widgets/insights_card.dart';
import 'package:spending_tracker/core/utils/feedback_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Home screen of the application
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Current selected navigation index
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncTx = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Spending Tracker',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.primary),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
            onSelected: (value) async {
              if (value == 'signout') {
                try {
                  // Sign out logic (Supabase example)
                  await Supabase.instance.client.auth.signOut();
                  // Navigate to login screen (replace route as needed)
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  }
                } catch (e) {
                  // Handle error (optional)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sign out failed: $e')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: asyncTx.when(
        data: (transactions) => _buildBody(transactions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<Transaction>(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: AddTransactionForm(
                onSubmit: (transaction) async {
                  try {
                    // Add to Supabase
                    await SupabaseTransactionRepository()
                        .addTransaction(transaction);
                    Navigator.of(context).pop(transaction);
                    FeedbackUtils.showSnackBar(
                      context,
                      message: 'Transaction added!',
                      type: SnackBarType.success,
                    );
                  } catch (err) {
                    FeedbackUtils.showSnackBar(
                      context,
                      message: 'Failed to add: $err',
                      type: SnackBarType.error,
                    );
                  }
                },
              ),
            ),
          );
          if (result != null) {
            // Refresh the transaction list after adding
            await ref.refresh(transactionsProvider.future);
          }
        },
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Build the main body of the home screen
  Widget _buildBody(List<Transaction> transactions) {
    final balance = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          BalanceCard(
            balance: balance,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
          ),

          // Apple Pay Button
          const CustomApplePayButton(),

          // Recent Transactions Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Personalized Insights Card
          InsightsCard(transactions: transactions),

          // Infinite Scrolling Transaction List
          SizedBox(
            height:
                500, // Fixed height to allow the ListView to scroll independently
            child: InfiniteTransactionList(
              transactions: transactions,
              onRefresh: () async {
                await ref.refresh(transactionsProvider.future);
                FeedbackUtils.showSnackBar(
                  context,
                  message: 'Transactions refreshed',
                  type: SnackBarType.success,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build the bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
