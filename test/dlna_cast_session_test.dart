import 'package:ble_project/widget/dlna_cast_session.dart';
import 'package:ble_project/widget/dlna_dialog.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:dlna_dart/xmlParser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDlnaDevice extends DLNADevice {
  String transportState = 'STOPPED';
  int playCalls = 0;
  int pauseCalls = 0;
  int stopCalls = 0;
  int? lastSeekSeconds;

  FakeDlnaDevice()
    : super(
        DeviceInfo(
          'http://tv.local',
          'urn:schemas-upnp-org:device:MediaRenderer:1',
          'Living room TV',
          const [],
        ),
      );

  @override
  Future<String> position() async => '''
    <GetPositionInfoResponse>
      <TrackDuration>00:30:00</TrackDuration>
      <RelTime>00:05:00</RelTime>
      <AbsTime>00:05:00</AbsTime>
      <TrackURI>https://cdn.example.com/video.m3u8</TrackURI>
    </GetPositionInfoResponse>
  ''';

  @override
  Future<String> getTransportInfo() async =>
      '''
    <GetTransportInfoResponse>
      <CurrentTransportState>$transportState</CurrentTransportState>
      <CurrentTransportStatus>OK</CurrentTransportStatus>
    </GetTransportInfoResponse>
  ''';

  @override
  Future<String> play() async {
    playCalls++;
    transportState = 'PLAYING';
    return '';
  }

  @override
  Future<String> pause() async {
    pauseCalls++;
    transportState = 'PAUSED_PLAYBACK';
    return '';
  }

  @override
  Future<String> stop() async {
    stopCalls++;
    transportState = 'STOPPED';
    return '';
  }

  @override
  Future<String> seekByCurrent(String text, int seconds) async {
    lastSeekSeconds = seconds;
    return '';
  }
}

void main() {
  test('floating control toggles the active DLNA session', () async {
    final device = FakeDlnaDevice();
    final session = DlnaCastSession(device);
    addTearDown(session.dispose);
    await session.refresh();

    await session.togglePlayback();
    expect(session.isPlaying, isTrue);
    expect(device.playCalls, 1);

    await session.togglePlayback();
    expect(session.isPlaying, isFalse);
    expect(device.pauseCalls, 1);

    await session.stop();
    expect(session.isPlaying, isFalse);
    expect(device.stopCalls, 1);
  });

  test(
    'seek controls stay available after moving state out of the dialog',
    () async {
      final device = FakeDlnaDevice();
      final session = DlnaCastSession(device);
      addTearDown(session.dispose);

      await session.seekBy(30);

      expect(device.lastSeekSeconds, 30);
      expect(session.position?.TrackURI, 'https://cdn.example.com/video.m3u8');
    },
  );

  testWidgets('floating ball toggles playback and restores the dialog', (
    tester,
  ) async {
    final device = FakeDlnaDevice();
    final session = DlnaCastSession(device);
    await session.refresh();
    var restoreCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DlnaFloatingBall(
            session: session,
            onRestore: () => restoreCalls++,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(device.pauseCalls, 1);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tester.tap(find.byIcon(Icons.open_in_full));
    expect(restoreCalls, 1);

    session.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'dialog places minimize before close and restores from the ball',
    (tester) async {
      final session = DlnaCastSession(FakeDlnaDevice(), mediaTitle: '九门');
      await session.refresh();

      await tester.pumpWidget(
        MaterialApp(home: DlnaDialog(session, animateFromFloating: true)),
      );
      expect(
        find.byKey(const ValueKey('dlna-compact-preview')),
        findsOneWidget,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final minimize = find.byIcon(Icons.remove);
      final close = find.byIcon(Icons.close);
      expect(find.byKey(const ValueKey('dlna-control-dialog')), findsOneWidget);
      expect(minimize, findsOneWidget);
      expect(close, findsOneWidget);
      expect(
        tester.getCenter(minimize).dx,
        lessThan(tester.getCenter(close).dx),
      );

      expect(find.text('九门'), findsOneWidget);
      expect(find.text('https://cdn.example.com/video.m3u8'), findsNothing);
      await tester.tap(find.text('九门'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('https://cdn.example.com/video.m3u8'), findsOneWidget);

      session.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
