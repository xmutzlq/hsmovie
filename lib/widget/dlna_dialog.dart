// ignore_for_file: file_names

import 'dart:async';

import 'package:ble_project/ui/player/player_controller/logic.dart';
import 'package:ble_project/util/toast_util.dart';
import 'package:ble_project/widget/dlna_cast_session.dart';
import 'package:ble_project/widget/dlna_stream_items.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:zo_animated_border/widget/zo_breathing_border.dart';

class DlnaCastOverlayController {
  static const _dialogTag = 'dlna-control-dialog';
  static final instance = DlnaCastOverlayController._();

  DlnaCastOverlayController._();

  DlnaCastSession? _session;
  OverlayEntry? _floatingEntry;
  bool _dialogVisible = false;

  bool get hasActiveSession => _session != null;

  Future<void> open(
    DLNADevice device, {
    String? videoId,
    String mediaTitle = '',
  }) async {
    final previous = _session;
    _session = null;
    _removeFloating();
    if (previous != null) {
      try {
        await previous.stop();
      } catch (_) {}
      previous.dispose();
    }

    final session = DlnaCastSession(
      device,
      videoId: videoId,
      mediaTitle: mediaTitle,
    );
    _session = session;
    _showControl(session);
  }

  void restore() {
    final session = _session;
    if (session == null || _dialogVisible) return;
    _removeFloating();
    _showControl(session, animateFromFloating: true);
  }

  void minimize() {
    final session = _session;
    if (session == null) return;
    _showFloating(session);
    unawaited(SmartDialog.dismiss(tag: _dialogTag));
  }

  Future<void> close() async {
    final session = _session;
    _session = null;
    _removeFloating();
    if (session != null) {
      try {
        await session.stop();
      } catch (error) {
        ToastUtil.showToast('$error');
      } finally {
        session.dispose();
      }
    }
    await SmartDialog.dismiss(tag: _dialogTag);
  }

  void _showControl(
    DlnaCastSession session, {
    bool animateFromFloating = false,
  }) {
    _dialogVisible = true;
    unawaited(
      SmartDialog.show<void>(
        tag: _dialogTag,
        debounce: true,
        clickMaskDismiss: false,
        useAnimation: false,
        onDismiss: () {
          _dialogVisible = false;
          if (_session == session && _floatingEntry == null) {
            _showFloating(session);
          }
        },
        builder: (_) =>
            DlnaDialog(session, animateFromFloating: animateFromFloating),
      ),
    );
  }

  void _showFloating(DlnaCastSession session) {
    if (_floatingEntry != null || _session != session) return;
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        right: 16,
        bottom: 88,
        child: SafeArea(
          child: DlnaFloatingBall(session: session, onRestore: restore),
        ),
      ),
    );
    _floatingEntry = entry;
    overlay.insert(entry);
  }

  void _removeFloating() {
    _floatingEntry?.remove();
    _floatingEntry = null;
  }
}

class DlnaFloatingBall extends StatelessWidget {
  final DlnaCastSession session;
  final VoidCallback onRestore;

  const DlnaFloatingBall({
    super.key,
    required this.session,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) => Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 82,
          height: 82,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 4,
                bottom: 2,
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF20252B),
                    border: Border.all(
                      color: const Color(0xFF4CC9A7),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x52000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: session.isPlaying ? '暂停投屏' : '继续投屏',
                    onPressed: session.isBusy
                        ? null
                        : () async {
                            try {
                              await session.togglePlayback();
                            } catch (error) {
                              ToastUtil.showToast('$error');
                            }
                          },
                    icon: session.isBusy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            session.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 34,
                          ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CC9A7),
                  ),
                  child: IconButton(
                    tooltip: '恢复投屏控制',
                    padding: EdgeInsets.zero,
                    onPressed: onRestore,
                    icon: const Icon(
                      Icons.open_in_full,
                      size: 16,
                      color: Color(0xFF10231E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DlnaDialog extends StatefulWidget {
  final DlnaCastSession session;
  final bool animateFromFloating;

  const DlnaDialog(this.session, {super.key, this.animateFromFloating = false});

  @override
  State<DlnaDialog> createState() => _DlnaDialogState();
}

class _DlnaDialogState extends State<DlnaDialog> {
  static const _animationDuration = Duration(milliseconds: 320);
  static const _buttonHeight = 35.0;
  bool _compact = false;
  bool _showPlaybackUrl = false;

  @override
  void initState() {
    super.initState();
    _compact = widget.animateFromFloating;
    widget.session.addListener(_onSessionChanged);
    if (_compact) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _compact = false);
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _minimize() async {
    if (_compact) return;
    setState(() => _compact = true);
    await Future<void>.delayed(_animationDuration);
    if (mounted) DlnaCastOverlayController.instance.minimize();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final dialogWidth = (screen.width - 40).clamp(280.0, 560.0);
    final dialogHeight = (screen.height * 2 / 3).clamp(320.0, 560.0);

    return SizedBox(
      width: screen.width,
      height: screen.height,
      child: SafeArea(
        child: AnimatedPadding(
          duration: _animationDuration,
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.only(right: 16, bottom: _compact ? 88 : 20),
          child: AnimatedAlign(
            duration: _animationDuration,
            curve: Curves.easeInOutCubic,
            alignment: _compact ? Alignment.bottomRight : Alignment.center,
            child: AnimatedContainer(
              duration: _animationDuration,
              curve: Curves.easeInOutCubic,
              width: _compact ? 74 : dialogWidth,
              height: _compact ? 74 : dialogHeight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                child: _compact ? _compactPreview() : _dialogSurface(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactPreview() {
    return Container(
      key: const ValueKey('dlna-compact-preview'),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF20252B),
        border: Border.all(color: const Color(0xFF4CC9A7), width: 2),
      ),
      child: Icon(
        widget.session.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 34,
      ),
    );
  }

  Widget _dialogSurface(BuildContext context) {
    return Material(
      key: const ValueKey('dlna-control-dialog'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 10, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.session.device.info.friendlyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 100, 100, 135),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '最小化投屏控制',
                  onPressed: _minimize,
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  tooltip: '结束投屏',
                  onPressed: DlnaCastOverlayController.instance.close,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Expanded(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.topCenter,
          child: Text(
            widget.session.device.info.URLBase,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ),
        const SizedBox(height: 8),
        _buildCurrentPlayback(),
        const SizedBox(height: 20),
        _buildActions(),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCurrentPlayback() {
    final position = widget.session.position;
    final currentUrl = position?.TrackURI ?? '';
    final title = widget.session.mediaTitle.trim().isEmpty
        ? '当前影片'
        : widget.session.mediaTitle.trim();
    return ZoBreathingBorder(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(8),
      colors: const [Colors.blue, Colors.purple, Colors.red, Colors.orange],
      animationDuration: const Duration(seconds: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('当前播放:', style: TextStyle(color: Colors.green)),
            const SizedBox(height: 6),
            InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () => setState(() => _showPlaybackUrl = !_showPlaybackUrl),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE06C27),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _showPlaybackUrl ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      child: const Icon(Icons.arrow_drop_down, size: 24),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _showPlaybackUrl
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SelectableText(
                              currentUrl.isEmpty ? '暂无播放链接' : currentUrl,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4F5964),
                              ),
                            ),
                          ),
                          if (currentUrl.isNotEmpty)
                            IconButton(
                              tooltip: '复制播放链接',
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: currentUrl),
                                );
                                ToastUtil.showToast('已复制');
                              },
                              icon: const Icon(Icons.copy, size: 17),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (position != null && position.AbsTime.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('${position.AbsTime} / ${position.TrackDuration}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    const textStyle = TextStyle(fontSize: 12);

    Widget button(String label, VoidCallback? onPressed, {double width = 80}) {
      return SizedBox(
        width: width,
        height: _buttonHeight,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(label, style: textStyle),
        ),
      );
    }

    return Column(
      children: [
        OverflowBar(
          alignment: MainAxisAlignment.center,
          children: [button('投屏', _castCurrent, width: 90)],
        ),
        const SizedBox(height: 20),
        OverflowBar(
          alignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            button('播放', () => _run(widget.session.play)),
            button('暂停', () => _run(widget.session.pause)),
            button('停止', () => _run(widget.session.stop)),
          ],
        ),
        const SizedBox(height: 15),
        OverflowBar(
          alignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            button('快退10秒', () => _seek(-10), width: 100),
            button('快进10秒', () => _seek(10), width: 100),
          ],
        ),
        const SizedBox(height: 15),
        OverflowBar(
          alignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            button('快退30秒', () => _seek(-30), width: 100),
            button('快进30秒', () => _seek(30), width: 100),
          ],
        ),
      ],
    );
  }

  void _castCurrent() {
    final videoId = widget.session.videoId;
    if (videoId != null && videoId.isNotEmpty) {
      SmartDialog.show(
        alignment: Alignment.bottomCenter,
        builder: (_) => DlnaStreamItems(widget.session.device, videoId),
      );
      return;
    }

    final logic = Get.find<PlayerControllerLogic>();
    _run(() => widget.session.cast(logic.currentPlayUrl), prefix: '投屏失败：');
  }

  Future<void> _seek(int seconds) => _run(() => widget.session.seekBy(seconds));

  Future<void> _run(
    Future<void> Function() action, {
    String prefix = '',
  }) async {
    try {
      await action();
    } catch (error) {
      ToastUtil.showToast('$prefix$error');
    }
  }
}
