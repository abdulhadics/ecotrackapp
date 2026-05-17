import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../services/hive_service.dart';
import '../services/discord_service.dart';
import '../models/habit_model.dart';

enum MapTransportMode { car, cycling, walking, electricTrain }

extension MapTransportModeExt on MapTransportMode {
  String get label {
    switch (this) {
      case MapTransportMode.car:           return 'CAR RIDE';
      case MapTransportMode.cycling:       return 'CYCLING';
      case MapTransportMode.walking:       return 'WALKING';
      case MapTransportMode.electricTrain: return 'ELECTRIC TRAIN';
    }
  }

  String get emoji {
    switch (this) {
      case MapTransportMode.car:           return '🚗';
      case MapTransportMode.cycling:       return '🚴';
      case MapTransportMode.walking:       return '🚶';
      case MapTransportMode.electricTrain: return '🚊';
    }
  }

  Color get color {
    switch (this) {
      case MapTransportMode.car:           return const Color(0xFFD32F2F);
      case MapTransportMode.cycling:       return const Color(0xFF1B5E20);
      case MapTransportMode.walking:       return const Color(0xFF1565C0);
      case MapTransportMode.electricTrain: return const Color(0xFF7B1FA2);
    }
  }

  double get co2Factor {
    // kg CO2 per km
    switch (this) {
      case MapTransportMode.car:           return 0.171; // Average petrol car
      case MapTransportMode.cycling:       return 0.004;
      case MapTransportMode.walking:       return 0.000;
      case MapTransportMode.electricTrain: return 0.035;
    }
  }
}

class MapDeedScreen extends StatefulWidget {
  const MapDeedScreen({super.key});

  @override
  State<MapDeedScreen> createState() => _MapDeedScreenState();
}

class _MapDeedScreenState extends State<MapDeedScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _fromCtrl = TextEditingController(text: 'Central Park, NYC');
  final TextEditingController _toCtrl = TextEditingController(text: 'Times Square, NYC');
  final TextEditingController _webhookCtrl = TextEditingController();

  MapTransportMode _selectedMode = MapTransportMode.cycling;
  double _distanceKm = 4.2;
  bool _isDispatching = false;

  // Map Animation Controller
  late AnimationController _mapAnimCtrl;
  double _animProgress = 0.0;
  List<Offset> _routePath = [];

  @override
  void initState() {
    super.initState();
    _mapAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          _animProgress = _mapAnimCtrl.value;
        });
      });
    _mapAnimCtrl.repeat();

    // Generate random route coordinates inside map canvas space
    _generateRoutePoints();
  }

  @override
  void dispose() {
    _mapAnimCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    _webhookCtrl.dispose();
    super.dispose();
  }

  void _generateRoutePoints() {
    final rand = Random();
    _routePath = [
      const Offset(40, 200),
      Offset(80 + rand.nextInt(40).toDouble(), 150 + rand.nextInt(30).toDouble()),
      Offset(140 + rand.nextInt(40).toDouble(), 180 + rand.nextInt(30).toDouble()),
      Offset(220 + rand.nextInt(40).toDouble(), 100 + rand.nextInt(40).toDouble()),
      const Offset(320, 80),
    ];
  }

  void _triggerDeedDispatch(
    DiscordService discordService,
    HiveService hiveService,
    bool isMagic,
  ) async {
    if (_fromCtrl.text.isEmpty || _toCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify both start and destination locations.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isDispatching = true);

    // Dynamic Carbon Footprint calculation vs standard Car baseline
    final baselineCo2 = MapTransportMode.car.co2Factor * _distanceKm;
    final modeCo2 = _selectedMode.co2Factor * _distanceKm;
    final co2Saved = max(0.0, baselineCo2 - modeCo2);

    final points = (_selectedMode == MapTransportMode.cycling || _selectedMode == MapTransportMode.walking)
        ? (_distanceKm * 2).round().clamp(2, 25)
        : 1;

    final String activityTitle = "Deed Log: ${_selectedMode.label}";
    final String description = "User navigated from ${_fromCtrl.text} to ${_toCtrl.text} via ${_selectedMode.label}. Route audited successfully.";

    // Apply Custom webhook override if specified
    if (_webhookCtrl.text.isNotEmpty) {
      discordService.webhookUrl = _webhookCtrl.text;
    }

    // Post to Discord Webhook via DiscordService
    final discordSuccess = await discordService.sendDeedReport(
      title: "🌍 Carbon-Mitigation Route Audited!",
      description: "A new ESG transport deed has been verified by the O(1) Sliding Window and logged to the administrative registry.",
      activityName: "Car Ride Replaced with ${_selectedMode.label}",
      fromLocation: _fromCtrl.text,
      toLocation: _toCtrl.text,
      distanceKm: _distanceKm,
      co2SavedKg: co2Saved,
      points: points,
      color: _selectedMode.color,
    );

    // Save habit record in Hive local database
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(100).toString(),
      title: activityTitle,
      description: "Route: ${_fromCtrl.text} ➔ ${_toCtrl.text} (${_distanceKm.toStringAsFixed(1)}km) · CO₂ Saved: ${co2Saved.toStringAsFixed(2)}kg · Discord Notification: ${discordSuccess ? 'SENT' : 'OFFLINE'}",
      category: HabitCategory.transport,
      points: points,
      date: DateTime.now(),
      isCompleted: true,
      userId: hiveService.currentUser?.id ?? 'default_user',
    );

    await hiveService.addHabit(newHabit);

    setState(() => _isDispatching = false);

    // Show success dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isMagic ? Colors.white : const Color(0xFF1B2B3B),
          title: Row(
            children: [
              Text(discordSuccess ? '🎉 Deed Dispatched!' : '⚠️ Deed Logged Local Only',
                  style: TextStyle(color: isMagic ? Colors.black : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your green deed has been saved to Hive and sent to the cloud audit trace.',
                style: TextStyle(color: isMagic ? Colors.black87 : Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              _buildStatsBadge('Distance', '${_distanceKm.toStringAsFixed(1)} km', isMagic),
              _buildStatsBadge('Mitigated CO₂', '${co2Saved.toStringAsFixed(3)} kg', isMagic),
              _buildStatsBadge('Eco Points', '+$points Credits', isMagic),
              _buildStatsBadge('Discord Status', discordSuccess ? 'ACTIVE EMBED SENT' : 'FAILED / OFFLINE', isMagic),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ACKNOWLEDGE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C896))),
            )
          ],
        ),
      );
    }

    _generateRoutePoints();
  }

  Widget _buildStatsBadge(String label, String value, bool isMagic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(color: isMagic ? Colors.grey : Colors.white54, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C896), fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discordService = Provider.of<DiscordService>(context);
    final hiveService = Provider.of<HiveService>(context);
    final isMagic = Provider.of<SettingsService>(context).isMagicMode;

    if (_webhookCtrl.text.isEmpty) {
      _webhookCtrl.text = discordService.webhookUrl;
    }

    final cardBg = isMagic ? Colors.white : const Color(0xFF1B2B3B);
    final textColor = isMagic ? const Color(0xFF1B5E20) : Colors.white;
    final subtitleColor = isMagic ? const Color(0xFF388E3C) : Colors.white60;
    final accentColor = isMagic ? const Color(0xFF2E7D32) : const Color(0xFF00C896);
    final borderColors = isMagic ? const Color(0xFFC8E6C8) : Colors.white.withOpacity(0.12);

    return Scaffold(
      backgroundColor: isMagic ? const Color(0xFFF0FAF4) : const Color(0xFF0D1B2A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. MAP IN FRONT (Topmost Item)
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isMagic ? const Color(0xFFE8F5E8) : const Color(0xFF152232),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColors, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _selectedMode.color.withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _MapCanvasPainter(
                        route: _routePath,
                        progress: _animProgress,
                        isMagic: isMagic,
                        modeColor: _selectedMode.color,
                        modeEmoji: _selectedMode.emoji,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🗺️ ECO-ROUTE TELEMETRY ACTIVE',
                          style: TextStyle(color: accentColor, fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. TRANSPORT OPTIONS
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColors),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🚴', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'SELECT TRANSPORT & TRIP METRICS',
                        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Mode Selector Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.8,
                    children: MapTransportMode.values.map((m) {
                      final selected = _selectedMode == m;
                      return InkWell(
                        onTap: () => setState(() => _selectedMode = m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: selected ? m.color : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selected ? m.color : borderColors, width: 1.5),
                            boxShadow: selected ? [
                              BoxShadow(color: m.color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))
                            ] : [],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(m.emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  m.label,
                                  style: TextStyle(
                                    color: selected ? Colors.white : textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Route Fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField('Start Point', _fromCtrl, isMagic, textColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInputField('End Point', _toCtrl, isMagic, textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Distance Tracker Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance Traced:', style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('${_distanceKm.toStringAsFixed(1)} km', style: TextStyle(color: _selectedMode.color, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ],
                  ),
                  Slider(
                    value: _distanceKm,
                    min: 0.5,
                    max: 30.0,
                    divisions: 59,
                    activeColor: _selectedMode.color,
                    inactiveColor: borderColors,
                    onChanged: (val) {
                      setState(() {
                        _distanceKm = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. DISCORD OPTION (At the bottom)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColors),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('👾', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text('DISCORD CHANNEL INTEGRATION',
                          style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField('Discord Webhook URL Override', _webhookCtrl, isMagic, textColor, maxLines: 2),
                  const SizedBox(height: 18),

                  // Action Button Inside the Discord Card for Unified Flow
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isDispatching
                          ? null
                          : () => _triggerDeedDispatch(discordService, hiveService, isMagic),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedMode.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                        shadowColor: _selectedMode.color.withOpacity(0.4),
                      ),
                      child: _isDispatching
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.discord_outlined, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  '🌟 AUDIT DEED & SEND TO DISCORD',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController ctrl,
    bool isMagic,
    Color textColor, {
    int maxLines = 1,
  }) {
    final borderColors = isMagic ? const Color(0xFFC8E6C8) : Colors.white.withOpacity(0.12);
    final inputBg = isMagic ? const Color(0xFFF0FAF4) : const Color(0xFF0D1B2A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: TextStyle(fontSize: 12, color: textColor),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColors),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColors),
            ),
          ),
        ),
      ],
    );
  }
}

// ── CUSTOM VECTOR MAP CANVAS PAINTER ─────────────────────────

class _MapCanvasPainter extends CustomPainter {
  final List<Offset> route;
  final double progress;
  final bool isMagic;
  final Color modeColor;
  final String modeEmoji;

  const _MapCanvasPainter({
    required this.route,
    required this.progress,
    required this.isMagic,
    required this.modeColor,
    required this.modeEmoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Grid Roads & Land
    final roadPaint = Paint()
      ..color = isMagic ? const Color(0xFFD4EAD4) : const Color(0xFF1E2E40)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw horizontal grid lines
    for (int y = 40; y < h; y += 50) {
      canvas.drawLine(Offset(10, y.toDouble()), Offset(w - 10, y.toDouble()), roadPaint);
    }
    // Draw vertical grid lines
    for (int x = 50; x < w; x += 70) {
      canvas.drawLine(Offset(x.toDouble(), 10), Offset(x.toDouble(), h - 10), roadPaint);
    }

    if (route.isEmpty) return;

    // 2. Draw Route Outline Path
    final path = Path()..moveTo(route.first.dx, route.first.dy);
    for (int i = 1; i < route.length; i++) {
      path.lineTo(route[i].dx, route[i].dy);
    }

    final outlinePaint = Paint()
      ..color = modeColor.withOpacity(0.3)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, outlinePaint);

    final tracePaint = Paint()
      ..color = modeColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, tracePaint);

    // 3. Draw Nodes (Start and Destination)
    final nodePaint = Paint()
      ..color = const Color(0xFF00C896)
      ..style = PaintingStyle.fill;

    // Start Node (Green Circle)
    canvas.drawCircle(route.first, 8, nodePaint);
    canvas.drawCircle(route.first, 12, Paint()..color = const Color(0xFF00C896).withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Destination Node (Red/Accent Target)
    canvas.drawCircle(route.last, 8, Paint()..color = Colors.orangeAccent..style = PaintingStyle.fill);
    canvas.drawCircle(route.last, 12, Paint()..color = Colors.orangeAccent.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 2);

    // 4. Draw Moving Transport Vehicle Along Path
    // Calculate precise position along multi-segment line
    final totalSegments = route.length - 1;
    final activeSegment = (progress * totalSegments).floor().clamp(0, totalSegments - 1);
    final segmentProgress = (progress * totalSegments) - activeSegment;

    final pStart = route[activeSegment];
    final pEnd = route[activeSegment + 1];
    final currentPos = Offset(
      pStart.dx + (pEnd.dx - pStart.dx) * segmentProgress,
      pStart.dy + (pEnd.dy - pStart.dy) * segmentProgress,
    );

    // Draw pulsating indicator
    final pulsePaint = Paint()
      ..color = modeColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPos, 22 * (0.6 + 0.4 * sin(progress * 2 * pi)), pulsePaint);

    // Draw icon backing circle
    canvas.drawCircle(currentPos, 14, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawCircle(currentPos, 14, Paint()..color = modeColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Render Emoji inside canvas
    final textPainter = TextPainter(
      text: TextSpan(
        text: modeEmoji,
        style: const TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(currentPos.dx - textPainter.width / 2, currentPos.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_MapCanvasPainter old) =>
      old.progress != progress || old.modeColor != modeColor || old.modeEmoji != modeEmoji;
}
