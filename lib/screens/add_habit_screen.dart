import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit_model.dart';
import '../services/hive_service.dart';
import '../utils/constants.dart';

/// Screen for adding new eco-friendly habits
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = HabitCategory.general;
  int _selectedPoints = 10;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Plant New Habit'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
            child: const Text(
              '🌱 Plant',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Title',
                  hintText: 'e.g., Use reusable water bottle',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.mediumPadding),

              // Description Input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add more details about this habit',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: AppConstants.mediumPadding),

              // Category Selection
              Text(
                'Category',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Wrap(
                spacing: AppConstants.smallPadding,
                runSpacing: AppConstants.smallPadding,
                children: HabitCategory.all.map((category) {
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(HabitCategory.icons[category] ?? '🌱'),
                        const SizedBox(width: AppConstants.smallPadding),
                        Text(category),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: _getCategoryColor(category).withOpacity(0.2),
                    checkmarkColor: _getCategoryColor(category),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppConstants.mediumPadding),

              // Points Selection
              Text(
                'Points',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Slider(
                value: _selectedPoints.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: '$_selectedPoints points',
                onChanged: (value) {
                  setState(() {
                    _selectedPoints = value.round();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('5 pts'),
                  Text('50 pts'),
                ],
              ),

              const SizedBox(height: AppConstants.mediumPadding),

              // Date Selection
              Text(
                'Date',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.mediumPadding),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: AppConstants.mediumPadding),
                      Text(_formatDate(_selectedDate)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Preview Card
              _buildPreviewCard(),

              const SizedBox(height: AppConstants.largePadding),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  child: const Text('🌱 Plant Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Row(
              children: [
                Text(HabitCategory.icons[_selectedCategory] ?? '🌱'),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    _titleController.text.isEmpty 
                        ? 'Habit Title' 
                        : _titleController.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.smallPadding,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$_selectedPoints',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_descriptionController.text.isNotEmpty) ...[
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                _descriptionController.text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.smallPadding,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_selectedCategory).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selectedCategory,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getCategoryColor(_selectedCategory),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(_selectedDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final hiveService = Provider.of<HiveService>(context, listen: false);
    
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      points: _selectedPoints,
      date: _selectedDate,
      isCompleted: false,
      userId: 'default_user', // Since we're using local storage
    );

    final success = await hiveService.addHabit(habit);
    
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case HabitCategory.water:
        return AppColors.waterColor;
      case HabitCategory.energy:
        return AppColors.energyColor;
      case HabitCategory.waste:
        return AppColors.wasteColor;
      case HabitCategory.transport:
        return AppColors.transportColor;
      case HabitCategory.food:
        return AppColors.foodColor;
      default:
        return AppColors.generalColor;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final habitDate = DateTime(date.year, date.month, date.day);

    if (habitDate == today) {
      return 'Today';
    } else if (habitDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
