import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../models/period_type.dart';

/// A widget that displays budget summary information with TikTok-inspired design
class BudgetSummaryCard extends ConsumerStatefulWidget {
  /// The period type (weekly, monthly)
  final PeriodType periodType;

  /// Budget data from the period_budgets table
  final Map<String, dynamic>? budgetData;

  /// Transaction summary data from the transaction provider
  final AsyncValue<Map<String, double>>? transactionSummary;

  /// Creates a modern budget summary card with animations
  const BudgetSummaryCard({
    Key? key,
    required this.periodType,
    this.budgetData,
    this.transactionSummary,
  }) : super(key: key);
  
  @override
  ConsumerState<BudgetSummaryCard> createState() => _BudgetSummaryCardState();
}

class _BudgetSummaryCardState extends ConsumerState<BudgetSummaryCard> 
    with SingleTickerProviderStateMixin {
  /// Currency formatter
  final NumberFormat _currencyFormat =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);
      
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _opacityAnimation;
  
  // Previous values for animated transitions
  double _prevBudget = 0.0;
  double _prevSpent = 0.0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void didUpdateWidget(BudgetSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Determine if budget data has changed
    final double newBudget = widget.budgetData != null
        ? double.parse(widget.budgetData!['budgeted_amount'].toString())
        : 0.0;
        
    // Get actual spending from transaction summary
    double newSpent = 0.0;
    if (widget.transactionSummary is AsyncData) {
      final data = (widget.transactionSummary as AsyncData).value;
      // Expense is negative, so we use abs to get positive spending amount
      newSpent = data['expense'] != null ? (data['expense']! * -1) : 0.0;
    }
    
    // If values have changed significantly, animate again
    if ((newBudget - _prevBudget).abs() > 0.01 || (newSpent - _prevSpent).abs() > 0.01) {
      _prevBudget = newBudget;
      _prevSpent = newSpent;
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Get budget totals and progress
    final double budgetedAmount = widget.budgetData != null
        ? double.parse(widget.budgetData!['budgeted_amount'].toString())
        : 0.0;

    // Get actual spending from transaction summary
    double actualSpending = 0.0;
    if (widget.transactionSummary is AsyncData) {
      final data = (widget.transactionSummary as AsyncData).value;
      // Expense is negative, so we use abs to get positive spending amount
      actualSpending = data['expense'] != null ? (data['expense']! * -1) : 0.0;
    }

    // Calculate the percentage spent
    final double percentSpent =
        budgetedAmount > 0 ? (actualSpending / budgetedAmount) : 0.0;

    final bool isOverBudget = percentSpent > 1.0;
    final String periodLabel = widget.periodType == PeriodType.weekly ? 'Weekly' : 'Monthly';
    
    // Determine color based on budget status
    final Color progressColor = isOverBudget
        ? colorScheme.error
        : percentSpent > 0.8
            ? Colors.orange
            : colorScheme.secondary;
            
    // Calculate how much is left
    final double remaining = budgetedAmount - actualSpending;
    final bool hasRemaining = remaining > 0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Apply animation to the percentage for progress indicator
        final animatedPercent = percentSpent * _progressAnimation.value;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceVariant,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Card content
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with budget title and details button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: colorScheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$periodLabel Budget',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          if (widget.budgetData != null)
                            GestureDetector(
                              onTap: () {
                                // Add haptic feedback
                                HapticFeedback.selectionClick();
                                // Navigate to budget details screen
                                // This would be implemented later
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Details',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Circular progress with percentage
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circle
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: CustomPaint(
                                painter: _CircularProgressPainter(
                                  backgroundCircleColor: colorScheme.surfaceVariant,
                                  progressCircleColor: progressColor,
                                  percentage: animatedPercent.clamp(0.0, 1.0),
                                  strokeWidth: 12,
                                ),
                              ),
                            ),
                            // Text in center showing percentage
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FadeTransition(
                                  opacity: _opacityAnimation,
                                  child: Text(
                                    '${(percentSpent * 100 * _progressAnimation.value).toInt()}%',
                                    style: textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isOverBudget 
                                        ? colorScheme.error 
                                        : colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Used',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Spending vs Budget row with animated counters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Spent amount
                          _buildAmountDisplay(
                            context: context,
                            label: 'Spent',
                            amount: actualSpending * _progressAnimation.value,
                            amountColor: isOverBudget ? colorScheme.error : colorScheme.onSurface,
                            icon: Icons.shopping_bag_outlined,
                            iconColor: isOverBudget ? colorScheme.error : colorScheme.primary,
                          ),
                          
                          // Budget amount
                          _buildAmountDisplay(
                            context: context,
                            label: 'Budget',
                            amount: budgetedAmount * _progressAnimation.value,
                            amountColor: colorScheme.onSurface,
                            icon: Icons.account_balance_outlined,
                            iconColor: colorScheme.secondary,
                            alignment: CrossAxisAlignment.end,
                          ),
                        ],
                      ),
                      
                      // Show feedback based on budget status
                      if (isOverBudget) ...[  
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Over budget by ${_currencyFormat.format(actualSpending - budgetedAmount)}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (hasRemaining) ...[  
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Remaining: ${_currencyFormat.format(remaining)}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (widget.budgetData == null) ...[  
                        const SizedBox(height: 20),
                        Center(
                          child: _buildStyledButton(
                            context: context,
                            label: 'Create Budget',
                            onTap: () {
                              // Navigate to create budget screen
                              // This would be implemented later
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Add subtle decorative elements
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.secondary.withOpacity(0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Helper widget to display an amount with a label and icon
  Widget _buildAmountDisplay({
    required BuildContext context,
    required String label,
    required double amount,
    required Color amountColor,
    required IconData icon,
    required Color iconColor,
    CrossAxisAlignment alignment = CrossAxisAlignment.start,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Label with icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Animated amount
        Text(
          _currencyFormat.format(amount),
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
  
  /// TikTok-style button with gradient and animation
  Widget _buildStyledButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final Color backgroundCircleColor;
  final Color progressCircleColor;
  final double percentage;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.backgroundCircleColor,
    required this.progressCircleColor,
    required this.percentage,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundCircleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressCircleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double sweepAngle = 2 * math.pi * percentage;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from the top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.backgroundCircleColor != backgroundCircleColor ||
        oldDelegate.progressCircleColor != progressCircleColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
