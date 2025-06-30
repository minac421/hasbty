import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/user_plan.dart';
import '../providers/user_provider.dart';
import '../services/feature_manager_service.dart';
import '../services/screen_manager.dart';

class CustomBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPlan = ref.watch(userPlanProvider);
    final currentUserType = userPlan?.userType ?? UserType.individual;
    
    // تحديد العناصر المتاحة حسب نوع المستخدم
    final availableItems = _getAvailableItems(currentUserType);
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: availableItems.map((item) {
          final isSelected = currentIndex == item['index'];
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(item['index']),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'],
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableItems(UserType userType) {
    return ScreenManager.getBottomNavItems(userType);
  }
} 