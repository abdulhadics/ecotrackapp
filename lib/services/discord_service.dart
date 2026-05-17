import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiscordDeedLog {
  final DateTime timestamp;
  final String title;
  final String description;
  final Map<String, String> fields;
  final int color;
  final String status;
  final String payloadJson;

  const DiscordDeedLog({
    required this.timestamp,
    required this.title,
    required this.description,
    required this.fields,
    required this.color,
    required this.status,
    required this.payloadJson,
  });
}

class DiscordService extends ChangeNotifier {
  static final DiscordService _instance = DiscordService._internal();
  factory DiscordService() => _instance;
  DiscordService._internal();

  // User customizable Discord Webhook URL
  String _webhookUrl = 'https://discord.com/api/webhooks/1372818987178332160/P-a8J1-vUuGg_6G0r0UeRk7C0u5Fp3Uo3N_u8I6O4G2a';

  String get webhookUrl => _webhookUrl;

  set webhookUrl(String url) {
    _webhookUrl = url;
    notifyListeners();
  }

  // Live in-memory logs to display on the Admin Dashboard
  final List<DiscordDeedLog> _sentLogs = [];

  List<DiscordDeedLog> get sentLogs => List.unmodifiable(_sentLogs);

  /// Dispatch carbon deed report directly to Discord as a rich embedded widget
  Future<bool> sendDeedReport({
    required String title,
    required String description,
    required String activityName,
    required String fromLocation,
    required String toLocation,
    required double distanceKm,
    required double co2SavedKg,
    required int points,
    required Color color,
  }) async {
    if (_webhookUrl.isEmpty || !_webhookUrl.startsWith('http')) {
      _recordLog(
        title: title,
        description: description,
        fields: {
          'Activity': activityName,
          'Route': '$fromLocation ➔ $toLocation',
          'Distance': '${distanceKm.toStringAsFixed(2)} km',
          'CO₂ Saved': '${co2SavedKg.toStringAsFixed(3)} kg',
          'Credits': '+$points Pts',
        },
        color: color.value,
        status: 'FAILED: Invalid Webhook URL',
        payloadJson: '{}',
      );
      return false;
    }

    final hexColor = color.value & 0xFFFFFF; // Convert to decimal RGB integer

    final payload = {
      "content": "🌿 **[EcoTrack Audit Log] — Real-time Carbon Mitigation Deed Dispatched!**",
      "embeds": [
        {
          "title": title,
          "description": description,
          "color": hexColor,
          "fields": [
            {
              "name": "Deed/Activity",
              "value": activityName,
              "inline": true
            },
            {
              "name": "Start Location",
              "value": fromLocation,
              "inline": true
            },
            {
              "name": "Destination",
              "value": toLocation,
              "inline": true
            },
            {
              "name": "Distance Traced",
              "value": "${distanceKm.toStringAsFixed(2)} km",
              "inline": true
            },
            {
              "name": "CO₂ Mitigation",
              "value": "${co2SavedKg.toStringAsFixed(3)} kg CO₂ Saved",
              "inline": true
            },
            {
              "name": "ESG Credits Earned",
              "value": "+$points Credits",
              "inline": true
            }
          ],
          "footer": {
            "text": "EcoTrack Enterprise • DAA Investment-Grade ESG Trail",
            "icon_url": "https://i.imgur.com/gI2Q91E.png"
          },
          "timestamp": DateTime.now().toUtc().toIso8601String()
        }
      ]
    };

    final payloadStr = jsonEncode(payload);

    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: payloadStr,
      );

      final success = response.statusCode >= 200 && response.statusCode < 300;
      final statusStr = success ? 'SUCCESS (${response.statusCode})' : 'FAILED (${response.statusCode}): ${response.body}';

      _recordLog(
        title: title,
        description: description,
        fields: {
          'Deed/Activity': activityName,
          'Start Location': fromLocation,
          'Destination': toLocation,
          'Distance Traced': '${distanceKm.toStringAsFixed(2)} km',
          'CO₂ Mitigation': '${co2SavedKg.toStringAsFixed(3)} kg CO₂ Saved',
          'ESG Credits Earned': '+$points Credits',
        },
        color: hexColor,
        status: statusStr,
        payloadJson: payloadStr,
      );

      return success;
    } catch (e) {
      _recordLog(
        title: title,
        description: description,
        fields: {
          'Deed/Activity': activityName,
          'Start Location': fromLocation,
          'Destination': toLocation,
          'Distance Traced': '${distanceKm.toStringAsFixed(2)} km',
          'CO₂ Mitigation': '${co2SavedKg.toStringAsFixed(3)} kg CO₂ Saved',
          'ESG Credits Earned': '+$points Credits',
        },
        color: hexColor,
        status: 'ERROR: $e',
        payloadJson: payloadStr,
      );
      return false;
    }
  }

  void _recordLog({
    required String title,
    required String description,
    required Map<String, String> fields,
    required int color,
    required String status,
    required String payloadJson,
  }) {
    _sentLogs.insert(
      0,
      DiscordDeedLog(
        timestamp: DateTime.now(),
        title: title,
        description: description,
        fields: fields,
        color: color,
        status: status,
        payloadJson: payloadJson,
      ),
    );
    notifyListeners();
  }
}
