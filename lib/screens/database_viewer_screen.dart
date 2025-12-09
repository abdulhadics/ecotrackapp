import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';
import '../models/badge_model.dart' as badge_model;

class DatabaseViewerScreen extends StatelessWidget {
  const DatabaseViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📦 Database Viewer'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'User'),
              Tab(icon: Icon(Icons.list), text: 'Habits'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Badges'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UserTab(),
            _HabitsTab(),
            _BadgesTab(),
          ],
        ),
      ),
    );
  }
}

class _UserTab extends StatelessWidget {
  const _UserTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveService>(
      builder: (context, hiveService, _) {
        final user = hiveService.currentUser;
        if (user == null) {
          return const Center(child: Text('No User Data Found'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard('User Profile', {
              'ID': user.id,
              'Name': user.name,
              'Email': user.email,
              'Points': user.totalPoints.toString(),
              'Streak': '${user.currentStreak} days',
              'Goal': user.ecoGoal,
            }),
          ],
        );
      },
    );
  }
}

class _HabitsTab extends StatelessWidget {
  const _HabitsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveService>(
      builder: (context, hiveService, _) {
        final habits = hiveService.habits;
        if (habits.isEmpty) {
          return const Center(child: Text('No Habits Found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(HabitCategory.icons[habit.category] ?? '🌱'),
                title: Text(habit.title),
                subtitle: Text('${habit.points} pts • ${habit.category}\nStatus: ${habit.isCompleted ? "✅ Completed" : "⏳ Pending"}'),
                isThreeLine: true,
                dense: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _BadgesTab extends StatelessWidget {
  const _BadgesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<HiveService>(
      builder: (context, hiveService, _) {
        final badges = hiveService.badges;
        if (badges.isEmpty) {
          return const Center(child: Text('No Badges Found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return Card(
              color: badge.isUnlocked ? Colors.green.shade50 : Colors.grey.shade100,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(badge.icon, style: const TextStyle(fontSize: 24)),
                title: Text(badge.name),
                subtitle: Text(badge.description),
                trailing: badge.isUnlocked 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.lock, color: Colors.grey.shade400),
              ),
            );
          },
        );
      },
    );
  }
}

Widget _buildInfoCard(String title, Map<String, String> data) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          ...data.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Expanded(child: Text(e.value)),
              ],
            ),
          )),
        ],
      ),
    ),
  );
}
