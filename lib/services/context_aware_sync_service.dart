import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../models/eco_action.dart';

/// Service responsible for handling context-aware data synchronization.
///
/// It monitors network connectivity and decides which data to sync based on
/// the connection type (WiFi vs Mobile Data) and data priority.
class ContextAwareSyncService {
  final Connectivity _connectivity = Connectivity();
  final Box<EcoAction> _box;
  StreamSubscription? _subscription;
  
  // Stream controllers for UI visualization
  final _logController = StreamController<String>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  
  Stream<String> get logs => _logController.stream;
  Stream<String> get status => _statusController.stream;

  ContextAwareSyncService(this._box);

  /// Initializes the sync service by listening to connectivity changes.
  void init() {
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _handleConnectivityChange(results);
    });
    
    // Check initial state
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  void dispose() {
    _subscription?.cancel();
    _logController.close();
    _statusController.close();
  }

  void _log(String message) {
    print(message);
    _logController.add("${DateTime.now().toString().split('.').first}: $message");
  }

  /// Handles connectivity changes and triggers the appropriate sync logic.
  /// 
  /// Logic Rule:
  /// - IF WiFi: Sync ALL unsynced items (Priority 1 & 2).
  /// - IF Mobile Data: Sync ONLY Priority 1 (Critical) items.
  /// - IF None: Do nothing.
  Future<void> _handleConnectivityChange(List<ConnectivityResult> results) async {
    _log("Network changed: $results");
    
    // Check for WiFi first as it's the preferred connection for heavy syncing
    if (results.contains(ConnectivityResult.wifi)) {
      _log("📶 WiFi detected. Syncing ALL items (Priority 1 & 2)...");
      _statusController.add("Connected: WiFi");
      await _syncItems(priorityLevel: null); // null means all
    } 
    // If no WiFi, check for Mobile Data
    else if (results.contains(ConnectivityResult.mobile)) {
      _log("📶 Mobile Data detected. Syncing ONLY Critical items (Priority 1)...");
      _statusController.add("Connected: Mobile Data");
      await _syncItems(priorityLevel: 1);
    } 
    // No active connection
    else {
      _log("❌ No suitable connection. Sync paused.");
      _statusController.add("Offline");
    }
  }

  /// Syncs items based on the priority level.
  /// If [priorityLevel] is null, it syncs all unsynced items.
  Future<void> _syncItems({int? priorityLevel}) async {
    // Filter unsynced items from the Hive box
    // We create a list copy to avoid concurrent modification issues during iteration if needed
    final unsyncedItems = _box.values.where((item) => !item.isSynced).toList();

    if (unsyncedItems.isEmpty) {
      _log("✅ No items pending sync.");
      return;
    }

    _log("🔍 Found ${unsyncedItems.length} unsynced items. Filtering for priority: ${priorityLevel ?? 'ALL'}");

    for (var item in unsyncedItems) {
      // Apply priority filter if specified
      // If priorityLevel is 1, we only sync items with priority 1.
      // If priorityLevel is null, we sync everything.
      if (priorityLevel != null && item.priority != priorityLevel) {
        continue;
      }

      try {
        // Perform the sync (Mocking the network call here)
        bool success = await _mockSyncToCloud(item);

        if (success) {
          item.isSynced = true;
          await item.save(); // Update Hive object directly
          _log("🚀 Synced item: ${item.actionType} (Priority: ${item.priority})");
        }
      } catch (e) {
        _log("⚠️ Failed to sync item ${item.id}: $e");
      }
    }
  }

  /// Mock function to simulate a network call.
  /// Replace this with your actual API call.
  Future<bool> _mockSyncToCloud(EcoAction item) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate latency
    // Return true to simulate successful sync
    return true;
  }
}
