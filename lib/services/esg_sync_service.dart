import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/AlgorithmicsCard.dart';

class SyncResult {
  final bool success;
  final String auditLogId;

  SyncResult({required this.success, required this.auditLogId});
}

class EsgSyncService {
  static const String _n8nWebhookUrl = 'https://your-n8n-instance.com/webhook/ecotrack-esg';

  Future<SyncResult> syncTripLog(AlgoMetrics metrics, String userId) async {
    try {
      final client = Supabase.instance.client;
      
      // a) INSERT a row into esg_audit_logs in Supabase
      final response = await client.from('esg_audit_logs').insert({
        'user_id': userId,
        'transport_mode': metrics.transportMode,
        'co2_saved_kg': metrics.co2SavedKg,
        'confidence_score': metrics.confidence,
        'timestamp': DateTime.now().toIso8601String(),
        'synced_to_n8n': true,
      }).select().single();

      final String logId = response['id'].toString();

      // b) After successful insert, POST the same data as JSON to n8n
      bool n8nSuccess = false;
      try {
        final n8nResponse = await http.post(
          Uri.parse(_n8nWebhookUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': logId,
            'user_id': userId,
            'transport_mode': metrics.transportMode,
            'co2_saved_kg': metrics.co2SavedKg,
            'confidence_score': metrics.confidence,
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
        if (n8nResponse.statusCode >= 200 && n8nResponse.statusCode < 300) {
          n8nSuccess = true;
        }
      } catch (_) {
        n8nSuccess = false;
      }

      // c) On n8n HTTP error, mark synced_to_n8n = false
      if (!n8nSuccess) {
        await client
            .from('esg_audit_logs')
            .update({'synced_to_n8n': false})
            .eq('id', logId);
      }

      return SyncResult(success: true, auditLogId: logId);
    } catch (e) {
      return SyncResult(success: false, auditLogId: '');
    }
  }
}
