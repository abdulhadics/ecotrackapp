import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../widgets/habit_card.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';

/// Screen displaying all logged ESG activities with filtering options
class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  String _getCategoryShortName(String category) {
    switch (category) {
      case HabitCategory.water:
        return "Water";
      case HabitCategory.energy:
        return "Energy";
      case HabitCategory.waste:
        return "Waste";
      case HabitCategory.transport:
        return "Transport";
      case HabitCategory.food:
        return "Supply Chain";
      default:
        return "General";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 ESG Compliance Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Log New ESG Activity',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddHabitScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<HiveService>(
        builder: (context, hiveService, child) {
          if (hiveService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final habits = _filterHabits(hiveService.habits);

          return Column(
            children: [
              // Filter Section
              _buildFilterSection(),
              
              // Habits List
              Expanded(
                child: habits.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.mediumPadding),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                            child: Dismissible(
                              key: Key('list_dismiss_${habits[index].id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Habit?'),
                                    content: const Text('Are you sure you want to delete this habit?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) {
                                hiveService.deleteHabit(habits[index], context);
                              },
                              child: HabitCard(habit: habits[index]),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category Filter
          Row(
            children: [
              const Icon(Icons.category, size: 20),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Category:'),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', ...HabitCategory.all].map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppConstants.smallPadding),
                        child: FilterChip(
                          label: Text(category == 'All' ? 'All Categories' : _getCategoryShortName(category)),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          // Status Filter
          Row(
            children: [
              const Icon(Icons.verified_user, size: 20),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Status:'),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Completed', 'Pending'].map((status) {
                      String label = 'All Entries';
                      if (status == 'Completed') label = 'Audited';
                      if (status == 'Pending') label = 'Pending';
                      return Padding(
                        padding: const EdgeInsets.only(right: AppConstants.smallPadding),
                        child: FilterChip(
                          label: Text(label),
                          selected: _selectedStatus == status,
                          onSelected: (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            'No ESG Logs Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Log your first ESG activity to the secure ledger! 📋',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddHabitScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Log New ESG Activity'),
          ),
        ],
      ),
    );
  }

  List _filterHabits(List habits) {
    return habits.where((habit) {
      // Category filter
      if (_selectedCategory != 'All' && habit.category != _selectedCategory) {
        return false;
      }
      
      // Status filter
      if (_selectedStatus == 'Completed' && !habit.isCompleted) {
        return false;
      }
      if (_selectedStatus == 'Pending' && habit.isCompleted) {
        return false;
      }
      
      return true;
    }).toList();
  }
}
