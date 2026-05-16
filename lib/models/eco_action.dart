import 'package:hive/hive.dart';

part 'eco_action.g.dart';

/// Model class for EcoAction.
/// 
/// This class represents an action taken by the user that needs to be synced to the server.
/// It includes a priority level to support context-aware syncing.
@HiveType(typeId: 3)
class EcoAction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String actionType;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  bool isSynced;

  /// Priority levels:
  /// 1 = Critical/High (Sync on Mobile Data & WiFi)
  /// 2 = Passive/Low (Sync only on WiFi)
  @HiveField(4)
  final int priority;

  @HiveField(5)
  final String? payload; // Content (text or image path)

  @HiveField(6)
  final String? relatedId; // To link Text + Image parts of the same post

  EcoAction({
    required this.id,
    required this.actionType,
    required this.timestamp,
    this.isSynced = false,
    required this.priority,
    this.payload,
    this.relatedId,
  });
}
