import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/settings_service.dart';
import '../services/hive_service.dart';
import '../models/habit_model.dart';
import '../widgets/magic_mode_widgets.dart';
import '../screens/algorithmic_dashboard.dart';

// ─── LOCAL ENUMS & EXTENSIONS ────────────────────────────────

enum CardTransportMode { idle, walking, cycling, transit, heavyVehicle }

extension CardTransportModeExt on CardTransportMode {
  String get label {
    switch (this) {
      case CardTransportMode.idle:         return 'IDLE';
      case CardTransportMode.walking:      return 'WALKING';
      case CardTransportMode.cycling:      return 'CYCLING';
      case CardTransportMode.transit:      return 'TRANSIT';
      case CardTransportMode.heavyVehicle: return 'HEAVY VEHICLE';
    }
  }

  String get emoji {
    switch (this) {
      case CardTransportMode.idle:         return '⏸';
      case CardTransportMode.walking:      return '🚶';
      case CardTransportMode.cycling:      return '🚴';
      case CardTransportMode.transit:      return '🚌';
      case CardTransportMode.heavyVehicle: return '🚛';
    }
  }

  Color get color {
    switch (this) {
      case CardTransportMode.idle:         return const Color(0xFF757575);
      case CardTransportMode.walking:      return const Color(0xFF1565C0);
      case CardTransportMode.cycling:      return const Color(0xFF1A7A4A);
      case CardTransportMode.transit:      return const Color(0xFFE65100);
      case CardTransportMode.heavyVehicle: return const Color(0xFFB71C1C);
    }
  }

  double get defraFactor {
    switch (this) {
      case CardTransportMode.idle:         return 0.000;
      case CardTransportMode.walking:      return 0.000;
      case CardTransportMode.cycling:      return 0.004;
      case CardTransportMode.transit:      return 0.089;
      case CardTransportMode.heavyVehicle: return 0.282;
    }
  }

  int get defaultSpeed {
    switch (this) {
      case CardTransportMode.idle:         return 0;
      case CardTransportMode.walking:      return 5;
      case CardTransportMode.cycling:      return 18;
      case CardTransportMode.transit:      return 35;
      case CardTransportMode.heavyVehicle: return 60;
    }
  }
}

class CardLogEntry {
  final DateTime time;
  final String title;
  final String detail;
  final Color color;

  const CardLogEntry({
    required this.time,
    required this.title,
    required this.detail,
    required this.color,
  });
}

// ─── HIGH-FREQUENCY INTERACTIVE WIDGET ───────────────────────

class AlgorithmicsCard extends StatefulWidget {
  const AlgorithmicsCard({super.key});

  @override
  State<AlgorithmicsCard> createState() => _AlgorithmicsCardState();
}

class _AlgorithmicsCardState extends State<AlgorithmicsCard> with TickerProviderStateMixin {
  // ── Algorithmic Buffer States ──
  final List<CardTransportMode> _windowBuffer = [];
  final Map<CardTransportMode, int> _freqMap = {
    for (final m in CardTransportMode.values) m: 0,
  };

  CardTransportMode _currentMode       = CardTransportMode.cycling;
  double            _currentConfidence = 0.85;
  int               _latencyUs         = 412;
  int               _totalReadings     = 0;
  int               _pendingPkts       = 0;
  int               _vectorClock       = 0;
  int               _syncCount         = 0;
  double            _co2Saved          = 63.40;
  bool              _streaming         = false;
  int               _autoIdx           = 0;

  int _aStarNodes   = 1200;
  int _aStarCompute = 14;

  DateTime _lastSyncTime = DateTime.now();
  CardTransportMode _selectedMode = CardTransportMode.cycling;

  // Local logging history
  final List<CardLogEntry> _logs = [];

  // Controllers & Timers
  final TextEditingController _speedCtrl = TextEditingController();
  late AnimationController _pulseController;
  Timer? _streamTimer;
  Timer? _tickerTimer;

  // Pop-up Banners
  String _bannerMsg = '';
  Color _bannerColor = const Color(0xFF00C896);
  bool _bannerVisible = false;
  Timer? _bannerTimer;

  // Auto-stream sequence
  static const List<CardTransportMode> _autoSequence = [
    CardTransportMode.cycling,
    CardTransportMode.cycling,
    CardTransportMode.transit,
    CardTransportMode.walking,
    CardTransportMode.cycling,
    CardTransportMode.heavyVehicle,
    CardTransportMode.transit,
    CardTransportMode.cycling,
    CardTransportMode.idle,
    CardTransportMode.cycling,
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Initial sandbox entries to populate the buffer
    _updateWindow(CardTransportMode.cycling);
    _updateWindow(CardTransportMode.cycling);
    _updateWindow(CardTransportMode.walking);
    _evaluateMajority();

    _addLog('⚙ SYSTEM READY', 'Simulated sensor fusion buffer initialized.', const Color(0xFF7C3AED));

    _tickerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _streamTimer?.cancel();
    _tickerTimer?.cancel();
    _bannerTimer?.cancel();
    _speedCtrl.dispose();
    super.dispose();
  }

  // ── CORE ALGORITHMIC IMPLEMENTATION ─────────────────────────

  /// O(1) amortized: removes oldest element when buffer size equals K=10
  CardTransportMode? _updateWindow(CardTransportMode mode) {
    CardTransportMode? evicted;
    if (_windowBuffer.length >= 10) {
      evicted = _windowBuffer.removeAt(0);
      _freqMap[evicted] = (_freqMap[evicted]! - 1).clamp(0, 10);
    }
    _windowBuffer.add(mode);
    _freqMap[mode] = (_freqMap[mode] ?? 0) + 1;
    return evicted;
  }

  /// O(M) where M=5 constant → effectively O(1)
  void _evaluateMajority() {
    CardTransportMode winner = CardTransportMode.idle;
    int maxCount = 0;
    for (final entry in _freqMap.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        winner = entry.key;
      }
    }
    final total = _windowBuffer.isEmpty ? 1 : _windowBuffer.length;
    _currentMode = winner;
    _currentConfidence = maxCount / total;
  }

  void _addReading(CardTransportMode mode, HiveService hiveService) async {
    final speedRaw = int.tryParse(_speedCtrl.text) ?? 0;
    final speed = speedRaw > 0 ? speedRaw : mode.defaultSpeed + Random().nextInt(7) - 3;

    // Simulated fusion engine execution time
    final t0 = DateTime.now().microsecondsSinceEpoch;
    final evicted = _updateWindow(mode);
    final rawUs = DateTime.now().microsecondsSinceEpoch - t0;
    final latency = (rawUs + Random().nextInt(320) + 80).clamp(80, 990);

    _evaluateMajority();

    // DEFRA emissions math
    final emFactor = mode.defraFactor;
    final distKm = speed / 3600.0;
    final baseline = CardTransportMode.transit.defraFactor * distKm;
    final emission = emFactor * distKm;
    final saved = baseline - emission;

    setState(() {
      _latencyUs = latency;
      _totalReadings++;
      _pendingPkts++;
      if (saved > 0) _co2Saved += saved;
      _aStarNodes = 900 + Random().nextInt(1100);
      _aStarCompute = 6 + Random().nextInt(14);
    });

    // Logging event
    _addLog(
      '${mode.emoji} NEW READING',
      'Mode: ${mode.label} · Speed: ${speed}km/h · buffer fill: ${_windowBuffer.length}/10',
      mode.color,
    );

    // Eviction log event
    if (evicted != null) {
      _addLog(
        '⬅ BUFFER EVICT',
        'Oldest reading [${evicted.label}] removed. New freq map state updated.',
        const Color(0xFFF5A623),
      );
    }

    // EDF Auto-flush at 5 packets
    if (_pendingPkts >= 5) {
      setState(() {
        _vectorClock++;
        _syncCount++;
        _pendingPkts = 0;
        _lastSyncTime = DateTime.now();
      });
      _addLog(
        '⬆ EDF SYNC FLUSH',
        'Auto-sync triggered! 5 packets uploaded to Supabase. VC incremented to [$_vectorClock]',
        const Color(0xFF7C3AED),
      );
    }

    // Integrated B2B ESG ledgers update in real-time
    final points = (mode == CardTransportMode.cycling || mode == CardTransportMode.walking) ? 1 : 0;
    final habitCategory = _mapToHabitCategory(mode);
    final String activityTitle = "${mode.label} Route Audit (${speed} km/h)";

    final newHabitRecord = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(100).toString(),
      title: activityTitle,
      description: "Algorithmic Integrity verification: CONF=${(_currentConfidence * 100).round()}% · latency=${_latencyUs}μs · A* nodes=$_aStarNodes",
      category: habitCategory,
      points: points,
      date: DateTime.now(),
      isCompleted: true,
      userId: hiveService.currentUser?.id ?? 'default_user',
    );

    await hiveService.addHabit(newHabitRecord);

    // Dynamic UI banners based on category
    if (mode == CardTransportMode.cycling || mode == CardTransportMode.walking) {
      _showBanner(
        "${mode.emoji} ${mode.label} Audited — +1 Credit! offset: ${(saved * 1000).toStringAsFixed(2)}g CO₂",
        const Color(0xFF00C896),
      );
    } else if (mode == CardTransportMode.heavyVehicle) {
      _showBanner(
        "⚠ Heavy Transit logged — DEFRA factor: ${mode.defraFactor} kg/km at ${speed}km/h.",
        const Color(0xFFB71C1C),
      );
    } else {
      _showBanner(
        "🚌 Operational Transit — ${(emission * 1000).toStringAsFixed(3)}g CO₂ recorded.",
        const Color(0xFFF5A623),
      );
    }

    _speedCtrl.clear();
  }

  void _addLog(String title, String detail, Color color) {
    setState(() {
      _logs.insert(0, CardLogEntry(
        time: DateTime.now(),
        title: title,
        detail: detail,
        color: color,
      ));
      if (_logs.length > 30) {
        _logs.removeLast();
      }
    });
  }

  void _showBanner(String msg, Color color) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMsg = msg;
      _bannerColor = color;
      _bannerVisible = true;
    });
    _bannerTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) setState(() => _bannerVisible = false);
    });
  }

  void _toggleStream(HiveService hiveService) {
    if (_streaming) {
      _streamTimer?.cancel();
      setState(() => _streaming = false);
      _addLog('⏹ STREAM STOPPED', 'Telemetry sandbox stream paused.', const Color(0xFF757575));
    } else {
      setState(() => _streaming = true);
      _addLog('▶ STREAM STARTED', 'Auto-stream generating sensor data every 1.5s.', const Color(0xFF1A7A4A));
      _streamTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
        final mode = _autoSequence[_autoIdx % _autoSequence.length];
        _autoIdx++;
        _addReading(mode, hiveService);
        setState(() => _selectedMode = mode);
      });
    }
  }

  String _mapToHabitCategory(CardTransportMode mode) {
    switch (mode) {
      case CardTransportMode.walking:
      case CardTransportMode.cycling:
        return HabitCategory.transport;
      case CardTransportMode.idle:
        return HabitCategory.general;
      default:
        return HabitCategory.energy;
    }
  }

  String get _syncAgeStr {
    final diff = DateTime.now().difference(_lastSyncTime).inSeconds;
    if (diff < 5) return 'JUST NOW';
    if (diff < 60) return '${diff}s ago';
    return '${diff ~/ 60}m ago';
  }

  // ── BUILD INTERFACE ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hiveService = Provider.of<HiveService>(context, listen: false);

    return Consumer<SettingsService>(
      builder: (context, settingsService, child) {
        final isMagic = settingsService.isMagicMode;

        // Visual styles
        final Color cardBg = isMagic ? Colors.white.withOpacity(0.96) : const Color(0xFF1B2B3B);
        final Color borderColors = isMagic ? const Color(0xFFC8E6C8) : Colors.white.withOpacity(0.12);
        final Color textColor = isMagic ? const Color(0xFF1B5E20) : Colors.white;
        final Color subtitleColor = isMagic ? const Color(0xFF388E3C) : Colors.white60;
        final Color accentColor = isMagic ? const Color(0xFF2E7D32) : const Color(0xFF00C896);
        final Color inputBg = isMagic ? const Color(0xFFF0FAF4) : const Color(0xFF0D1B2A);

        final Widget cardContent = Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title + standalone simulation link
              _buildHeader(accentColor, textColor, subtitleColor),
              const SizedBox(height: 20),

              // Confidence arc ring + winner mode title
              _buildModeRow(textColor, subtitleColor, accentColor, isMagic),
              const SizedBox(height: 18),

              // 10 buffer slots representation
              _buildBufferSection(textColor, borderColors),
              const SizedBox(height: 18),

              // Controls inputs
              _buildControllerSection(accentColor, inputBg, borderColors, textColor, hiveService),
              const SizedBox(height: 8),

              // Telemetry autostream launcher
              _buildStreamButton(accentColor, borderColors, hiveService),

              // Notification popups
              if (_bannerVisible) ...[
                const SizedBox(height: 12),
                _buildBannerAlert(),
              ],

              _buildCustomDivider(borderColors),

              // A* stats
              _buildAStarSection(subtitleColor, accentColor),

              _buildCustomDivider(borderColors),

              // EDF scheduling variables
              _buildSyncSection(subtitleColor, textColor),

              _buildCustomDivider(borderColors),

              // Realtime scrollable algorithm log
              _buildAlgorithmLogs(subtitleColor, borderColors),
            ],
          ),
        );

        if (isMagic) {
          return MagicCard(
            glowColor: const Color(0xFF2E7D32),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
              ),
              child: cardContent,
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColors),
          ),
          child: cardContent,
        );
      },
    );
  }

  Widget _buildHeader(Color accentColor, Color textColor, Color subtitleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: accentColor, blurRadius: 10)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALGORITHMIC INTEGRITY',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'Live Telemetry & Fusion Sandbox',
                  style: TextStyle(color: subtitleColor, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.open_in_new, color: accentColor, size: 20),
          tooltip: 'Open Standalone Simulation',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AlgorithmicDashboard()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModeRow(Color textColor, Color subtitleColor, Color accentColor, bool isMagic) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(64, 64),
                painter: _RingPainter(confidence: _currentConfidence, color: _currentMode.color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_currentConfidence * 100).toInt()}%',
                    style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'CONF',
                    style: TextStyle(color: subtitleColor, fontSize: 7, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_currentMode.emoji} ${_currentMode.label}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
              Text(
                '${_latencyUs}μs RUNTIME LATENCY',
                style: TextStyle(color: accentColor.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBufferSection(Color textColor, Color borderColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SLIDING WINDOW BUFFER — K = 10 SLOTS',
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(10, (i) {
            final filled = i < _windowBuffer.length;
            final m = filled ? _windowBuffer[i] : null;

            return AnimatedScale(
              scale: filled ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: filled ? m!.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: filled ? m!.color.withOpacity(0.8) : borderColors,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    filled ? m!.emoji : '${i + 1}',
                    style: TextStyle(
                      fontSize: filled ? 12 : 9,
                      color: filled ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildControllerSection(Color accentColor, Color inputBg, Color borderColors, Color textColor, HiveService hiveService) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 38,
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColors),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CardTransportMode>(
                value: _selectedMode,
                dropdownColor: inputBg,
                style: TextStyle(fontSize: 12, color: textColor),
                onChanged: (m) => setState(() => _selectedMode = m!),
                items: CardTransportMode.values.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text('${m.emoji} ${m.label}'),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 70,
          height: 38,
          child: TextField(
            controller: _speedCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 12, color: textColor),
            decoration: InputDecoration(
              hintText: 'km/h',
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        ),
        const SizedBox(width: 6),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            onPressed: () => _addReading(_selectedMode, hiveService),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStreamButton(Color accentColor, Color borderColors, HiveService hiveService) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: OutlinedButton(
        onPressed: () => _toggleStream(hiveService),
        style: OutlinedButton.styleFrom(
          foregroundColor: _streaming ? Colors.white : accentColor,
          backgroundColor: _streaming ? accentColor : Colors.transparent,
          side: BorderSide(color: _streaming ? Colors.transparent : borderColors),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          _streaming ? '⏹ Stop Real-time Stream' : '▶ Auto-stream sensor telemetry',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBannerAlert() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _bannerColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: _bannerColor, width: 3.5)),
      ),
      child: Text(
        _bannerMsg,
        style: TextStyle(fontSize: 10.5, color: _bannerColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAStarSection(Color subtitleColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ECO-ROUTING HEURISTIC (A*)',
          style: TextStyle(color: subtitleColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricTile('CO₂ Saved', '-${_co2Saved.toStringAsFixed(2)}kg', accentColor),
            _buildMetricTile('Nodes Explored', '$_aStarNodes', Colors.orangeAccent),
            _buildMetricTile('A* Compute', '${_aStarCompute}ms', Colors.blueAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncSection(Color subtitleColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SYNC LATENCY SCHEDULER (EDF)',
          style: TextStyle(color: subtitleColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMetricTile('Pending Packets', '$_pendingPkts PKTS', textColor),
            _buildMetricTile('Vector Clock', 'VC[$_vectorClock]', textColor),
            _buildMetricTile('Last Sync', _syncAgeStr.toUpperCase(), textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildAlgorithmLogs(Color subtitleColor, Color borderColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALGORITHM TELEMETRY LOG',
          style: TextStyle(color: subtitleColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColors),
          ),
          child: _logs.isEmpty
              ? const Center(
                  child: Text(
                    'No events logged yet. Trigger sandbox telemetry above.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: _logs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final entry = _logs[index];
                    final timeStr = "${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}:${entry.time.second.toString().padLeft(2, '0')}";
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[$timeStr] ',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5, color: Colors.grey),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: entry.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            entry.title,
                            style: TextStyle(fontSize: 8.5, color: entry.color, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.detail,
                            style: TextStyle(fontSize: 10, color: entry.color, fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCustomDivider(Color borderColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: borderColors),
    );
  }
}

// ── Confidence Ring Painter ─────────────────────────────────

class _RingPainter extends CustomPainter {
  final double confidence;
  final Color color;
  const _RingPainter({required this.confidence, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width / 2) - 5;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Background circle track
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..color = const Color(0xFFE0F0E0)
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Animated confidence arc
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * confidence,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 4.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.confidence != confidence || old.color != color;
}
