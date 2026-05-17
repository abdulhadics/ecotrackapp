import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/discord_service.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discordService = Provider.of<DiscordService>(context);
    final isMagic = Provider.of<SettingsService>(context).isMagicMode;

    final cardBg = isMagic ? Colors.white : const Color(0xFF1B2B3B);
    final textColor = isMagic ? const Color(0xFF1B5E20) : Colors.white;
    final subtitleColor = isMagic ? const Color(0xFF388E3C) : Colors.white60;
    final borderColors = isMagic ? const Color(0xFFC8E6C8) : Colors.white.withOpacity(0.12);

    final sentLogs = discordService.sentLogs;
    final totalSent = sentLogs.length;
    final successCount = sentLogs.where((l) => l.status.contains('200') || l.status.contains('SUCCESS')).length;
    final successRate = totalSent == 0 ? 100 : (successCount / totalSent * 100).round();

    return Scaffold(
      backgroundColor: isMagic ? const Color(0xFFF0FAF4) : const Color(0xFF0D1B2A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Text(
              'ADMIN ESG REPORTS',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.5),
            ),
            Text(
              'Compliance auditing metrics, Discord Webhook status monitors, and real-time ledger verification.',
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),
            const SizedBox(height: 18),

            // Performance Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricBadge('Webhooks Dispatched', '$totalSent', Colors.blueAccent, cardBg, borderColors, textColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricBadge('Sync Delivery Rate', '$successRate%', const Color(0xFF00C896), cardBg, borderColors, textColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Compliance Audit Standard List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColors),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESG COMPLIANCE CERTIFICATION LEDGER',
                    style: TextStyle(color: textColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 10),
                  _buildComplianceRow('DEFRA 2024 Scope 3 emission factors verified.', true),
                  _buildComplianceRow('O(1) Sliding Window majority-vote consensus audited.', true),
                  _buildComplianceRow('Real-time Discord notification embeds triggered on deeds.', true),
                  _buildComplianceRow('Greedy EDF priority queue backup sync enabled.', true),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Title for Discord Audit Trails
            Row(
              children: [
                const Text('👾', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'DISCORD WEBHOOK INTEGRATION LEDGER',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Webhook Sent Logs List
            if (sentLogs.isEmpty)
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColors),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📡', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      Text(
                        'No Discord notifications recorded yet.',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Post a new green deed from the Trip Logs map tab.',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sentLogs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final log = sentLogs[index];
                  return _buildDiscordEmbedMock(log, isMagic);
                },
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBadge(
    String label,
    String value,
    Color accentColor,
    Color bg,
    Color border,
    Color text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: accentColor, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildComplianceRow(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(active ? Icons.verified : Icons.pending, color: active ? const Color(0xFF00C896) : Colors.orangeAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // A pristine mock mimicking Discord's original light/dark embed bubble!
  Widget _buildDiscordEmbedMock(DiscordDeedLog log, bool isMagic) {
    final hexColor = Color(log.color | 0xFF000000);
    final isSuccess = log.status.contains('200') || log.status.contains('SUCCESS');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2F3136), // Discord's exact message container color
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Channel Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5865F2), // Discord Blurple
                        shape: BoxShape.circle,
                      ),
                      child: const Center(child: Text('🤖', style: TextStyle(fontSize: 12))),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'EcoTrack Integration Bot',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5865F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('BOT', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSuccess ? Colors.green : Colors.red, width: 0.8),
                  ),
                  child: Text(
                    isSuccess ? 'DELIVERED TO DISCORD' : 'SEND FAILED',
                    style: TextStyle(color: isSuccess ? Colors.greenAccent : Colors.redAccent, fontSize: 7, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 2. Rich Discord Embed Block
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF202225), // Discord's exact embed body background
              borderRadius: BorderRadius.circular(4),
              border: Border(
                left: BorderSide(color: hexColor, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  log.description,
                  style: const TextStyle(color: Color(0xFFDCDDDE), fontSize: 11),
                ),
                const SizedBox(height: 10),

                // Fields Grid
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: log.fields.entries.map((e) {
                    return SizedBox(
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(color: Color(0xFF8E9297), fontSize: 8.5, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.value,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: Colors.grey, size: 10),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'EcoTrack Enterprise • DAA Investment-Grade ESG Trail',
                        style: TextStyle(color: Color(0xFF72767D), fontSize: 8),
                      ),
                    ),
                    Text(
                      '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Color(0xFF72767D), fontSize: 8, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
