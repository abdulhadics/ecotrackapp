import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hive_service.dart';
import '../utils/constants.dart';
import '../widgets/habit_card.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';

/// Screen displaying all habits with filtering options
class HabitListScreen extends StatefulWidget {
  const HabitListScreen({super.key});

  @override
  State<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌿 My Eco Habits'),
        actions: [
          IconButton(
            icon: const Text('🌱', style: TextStyle(fontSize: 24)),
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
                            child: HabitCard(habit: habits[index]),
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
                          label: Text(category),
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
              const Icon(Icons.check_circle, size: 20),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Status:'),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Completed', 'Pending'].map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: AppConstants.smallPadding),
                        child: FilterChip(
                          label: Text(status),
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
          Text(
            '🌱',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            'No habits found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Plant your first eco-friendly habit! 🌱',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddHabitScreen()),
            ),
            icon: const Text('🌱'),
            label: const Text('Plant New Habit'),
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
