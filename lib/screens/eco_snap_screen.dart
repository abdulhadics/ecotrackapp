import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/eco_action.dart';
import '../services/hive_service.dart';

class EcoSnapScreen extends StatefulWidget {
  const EcoSnapScreen({super.key});

  @override
  State<EcoSnapScreen> createState() => _EcoSnapScreenState();
}

class _EcoSnapScreenState extends State<EcoSnapScreen> {
  final TextEditingController _captionController = TextEditingController();

  void _postSnap() async {
    if (_captionController.text.isEmpty) return;

    final String caption = _captionController.text;
    final String postId = DateTime.now().millisecondsSinceEpoch.toString();
    final DateTime now = DateTime.now();
    final box = Hive.box<EcoAction>('eco_actions');

    // 1. Create Text Action (Critical - Priority 1)
    final textAction = EcoAction(
      id: "${postId}_text",
      actionType: "SNAP_TEXT",
      timestamp: now,
      priority: 1, // Critical
      payload: caption,
      relatedId: postId,
      isSynced: false,
    );

    // 2. Create Image Action (Passive - Priority 2)
    // We simulate an image path
    final imageAction = EcoAction(
      id: "${postId}_image",
      actionType: "SNAP_IMAGE",
      timestamp: now,
      priority: 2, // Passive
      payload: "assets/images/placeholder_tree.png", // Simulated path
      relatedId: postId,
      isSynced: false,
    );

    await box.add(textAction);
    await box.add(imageAction);

    _captionController.clear();
    if (mounted) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Snap Posted! Uploading based on context...")),
      );
    }
  }

  void _showAddSnapDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Post Eco-Snap"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: "What did you do today?",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _postSnap,
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eco-Snap Feed"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSnapDialog,
        icon: const Icon(Icons.camera),
        label: const Text("Snap"),
        backgroundColor: Colors.green,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<EcoAction>('eco_actions').listenable(),
        builder: (context, Box<EcoAction> box, _) {
          // Filter for TEXT actions only to build the feed list
          // We will look up the corresponding IMAGE action for each text
          final posts = box.values
              .where((a) => a.actionType == "SNAP_TEXT")
              .toList()
              .reversed
              .toList();

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 64, color: Colors.green.shade200),
                  const SizedBox(height: 16),
                  const Text("No snaps yet. Be the first!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final textAction = posts[index];
              // Find corresponding image action
              final imageAction = box.values.firstWhere(
                (a) => a.relatedId == textAction.relatedId && a.actionType == "SNAP_IMAGE",
                orElse: () => EcoAction(id: 'null', actionType: 'null', timestamp: DateTime.now(), priority: 0),
              );

              final bool isImageReal = imageAction.id != 'null';
              final bool isImageSynced = isImageReal && imageAction.isSynced;
              final bool isTextSynced = textAction.isSynced;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Stack(
                        children: [
                          const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
                          
                          // Overlay Status
                          if (!isImageSynced)
                            Container(
                              color: Colors.black54,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.cloud_upload, color: Colors.white),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Waiting for WiFi...",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      "(Saving Data)",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                          if (isImageSynced)
                             const Positioned(
                               top: 8,
                               right: 8,
                               child: Chip(
                                 label: Text("Uploaded", style: TextStyle(fontSize: 10)),
                                 backgroundColor: Colors.white,
                                 avatar: Icon(Icons.check_circle, color: Colors.green, size: 16),
                               ),
                             ),
                        ],
                      ),
                    ),
                    
                    // Caption Section
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                textAction.timestamp.toString().split('.')[0],
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              Icon(
                                isTextSynced ? Icons.check_circle : Icons.schedule,
                                size: 16,
                                color: isTextSynced ? Colors.green : Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            textAction.payload ?? "",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
