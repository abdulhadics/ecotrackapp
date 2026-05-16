import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/hive_service.dart';
import '../models/eco_action.dart';
import 'eco_snap_screen.dart';
import '../widgets/AlgorithmicsCard.dart';

class ResearchDashboard extends StatefulWidget {
  const ResearchDashboard({super.key});

  @override
  State<ResearchDashboard> createState() => _ResearchDashboardState();
}

class _ResearchDashboardState extends State<ResearchDashboard> {
  final List<String> _logs = [];
  String _networkStatus = "Checking...";

  @override
  void initState() {
    super.initState();
    // Listen to logs and status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncService = Provider.of<HiveService>(context, listen: false).syncService;
      
      syncService.logs.listen((log) {
        if (mounted) {
          setState(() {
            _logs.insert(0, log); // Add new logs to the top
          });
        }
      });

      syncService.status.listen((status) {
        if (mounted) {
          setState(() {
            _networkStatus = status;
          });
        }
      });
    });
  }

  Future<void> _createAction(int priority) async {
    final box = Hive.box<EcoAction>('eco_actions');
    final action = EcoAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      actionType: priority == 1 ? "CRITICAL_UPDATE" : "PASSIVE_LOG",
      timestamp: DateTime.now(),
      priority: priority,
      isSynced: false,
    );
    
    await box.add(action);
    
    // Trigger sync check manually (optional, but good for demo)
    // In a real app, the service might listen to box changes or be triggered periodically
    // For this demo, we rely on the network change or manual trigger if we added one.
    // Let's just show a toast or log that we added it.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Created ${priority == 1 ? 'Critical' : 'Passive'} Action")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Research Dashboard"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 1. Network Status Panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                const Icon(Icons.wifi_tethering, size: 32, color: Colors.teal),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Network Status", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_networkStatus, style: const TextStyle(fontSize: 18, color: Colors.teal)),
                  ],
                ),
              ],
            ),
          ),

          // 2. Action Generators
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createAction(1),
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text("Gen Critical (P1)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createAction(2),
                    icon: const Icon(Icons.eco),
                    label: const Text("Gen Passive (P2)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Link to Eco-Snap Feed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EcoSnapScreen()),
                  );
                },
                icon: const Icon(Icons.photo_camera_back),
                label: const Text("Open Eco-Snap Feed (User View)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Algorithmics Performance Card
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: AlgorithmicsCard(),
          ),
          const SizedBox(height: 24),

          // 3. Data Visualization (Hive Box)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Local Data Queue (Hive)", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            flex: 2,
            child: ValueListenableBuilder(
              valueListenable: Hive.box<EcoAction>('eco_actions').listenable(),
              builder: (context, Box<EcoAction> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text("No pending actions."));
                }
                
                // Show unsynced items first
                final items = box.values.toList().reversed.toList();
                
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.priority == 1 ? Colors.red.shade100 : Colors.green.shade100,
                          child: Text(item.priority.toString()),
                        ),
                        title: Text(item.actionType),
                        subtitle: Text(item.timestamp.toString().split('.').first),
                        trailing: item.isSynced
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 4. Live Console
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Sync Algorithm Logs", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
