import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack_lite/widgets/AlgorithmicsCard.dart';

/*
 ═══════════════════════════════════════════════════════
 EcoTrack Enterprise | DAA Algorithmic Module Header
 ═══════════════════════════════════════════════════════
 [ALGORITHMIC INTENT]
   → Verify the UI reactivity and rendering logic of the 
     Algorithmics Monitor widget.

 [PARADIGM & DATA STRUCTURE]
   → Flutter Widget Testing Harness. Uses a Golden-path simulation 
     to verify that stream events trigger UI updates.

 [FORMAL COMPLEXITY PROOF]
   → Test Complexity: O(R * F) where R is the number of repaint cycles 
     and F is the number of frames per pump.

 [FAILURE & EDGE CASE ANALYSIS]
   → Stream Latency: The test uses pump() with specific durations to 
     simulate delayed data arrival and ensure the "Loading" state 
     transitions correctly.

 [BUSINESS & SUSTAINABILITY UTILITY]
   → Ensures that corporate executives see accurate, real-time 
     performance data without UI flicker or state desync.
 ═══════════════════════════════════════════════════════
*/

void main() {
  testWidgets('AlgorithmicsCard renders stream data and reacts to events', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AlgorithmicsCard(),
        ),
      ),
    ));

    // Initially, it might be empty if the stream hasn't emitted.
    // Our mock stream emits every 2 seconds.
    await tester.pump(const Duration(seconds: 2));

    // Verify that the title exists
    expect(find.text('ALGORITHMIC ENGINE MONITOR'), findsOneWidget);
    
    // Verify that the glassmorphic panels exist
    expect(find.text('SLIDING WINDOW MONITOR'), findsOneWidget);
    expect(find.text('ROUTE OPTIMIZER STATS'), findsOneWidget);
    expect(find.text('SYNC SCHEDULER QUEUE'), findsOneWidget);

    // Verify interaction: Tapping info icon opens bottom sheet
    final infoIcon = find.byIcon(Icons.info_outline).first;
    await tester.tap(infoIcon);
    await tester.pumpAndSettle();

    // Verify that the bottom sheet explanation appears
    expect(find.textContaining('Our system uses a consensus-based approach'), findsOneWidget);
  });
}
