import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

class EsgReportService {
  Future<Uint8List> generateComplianceReport(String userId, DateTimeRange range) async {
    final pdf = pw.Document();
    final client = Supabase.instance.client;

    // Fetch from Supabase esg_audit_logs filtered by userId and date range
    final List<dynamic> logs = await client
        .from('esg_audit_logs')
        .select()
        .eq('user_id', userId)
        .gte('timestamp', range.start.toIso8601String())
        .lte('timestamp', range.end.toIso8601String())
        .order('timestamp');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'ESG Compliance Report — EcoTrack Enterprise',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date Range: ${range.start.toLocal().toString().substring(0, 10)} to ${range.end.toLocal().toString().substring(0, 10)}',
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Table: date | transport_mode | co2_saved_kg | confidence_score
              pw.Table.fromTextArray(
                context: context,
                headers: <String>['Date', 'Transport Mode', 'CO2 Saved (kg)', 'Confidence Score'],
                data: <List<String>>[
                  ...logs.map((log) {
                    final dateStr = log['timestamp']?.toString().substring(0, 10) ?? '';
                    final modeStr = log['transport_mode']?.toString() ?? '';
                    final co2Str = (log['co2_saved_kg'] as num?)?.toStringAsFixed(2) ?? '0.00';
                    final confStr = '${(((log['confidence_score'] as num?)?.toDouble() ?? 0.0) * 100).toInt()}%';
                    return [dateStr, modeStr, co2Str, confStr];
                  }),
                ],
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 8),
              // Footer
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Verified by EcoTrack Algorithmic Integrity Protocol v1.0',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
