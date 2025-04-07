import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
  });

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final ValueNotifier<double> volume = ValueNotifier<double>(1.0);
  double playbackSpeed = 1.0;
  bool showVolumeSlider = false;
  bool showSpeedOptions = false;
  OverlayEntry? _overlayEntry;
  OverlayEntry? _dropdownOverlayEntry;
  GlobalKey volumeIconKey = GlobalKey();
  GlobalKey settingsIconKey = GlobalKey();
  List<StreamSubscription> _subscriptions= [];// Quản lý các listener
  bool _isDisposed = false; // Theo dõi trạng thái dispose

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _isDisposed = false;

    // Gán giá trị cho _subscriptions trong initState
    _subscriptions = [
      _audioPlayer.onDurationChanged.listen((d) {
        if (mounted && !_isDisposed) {
          setState(() => duration = d);
        }
      }),
      _audioPlayer.onPositionChanged.listen((p) {
        if (mounted && !_isDisposed) {
          setState(() => position = p);
        }
      }),
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted && !_isDisposed) {
          setState(() {
            isPlaying = false;
            position = Duration.zero;
          });
        }
      }),
    ];
  }

  @override
  void dispose() {
    // Hủy tất cả các listener nếu chúng tồn tại
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    if (!_isDisposed) {
      _audioPlayer.stop();
      _audioPlayer.dispose();
      _isDisposed = true;
    }
    _removeOverlay();
    _removeDropdownOverlay();
    volume.dispose();
    super.dispose();
  }

  void stopAudio() {
    if (!_isDisposed) {
      _audioPlayer.stop();
      if (mounted) {
        setState(() {
          isPlaying = false;
          position = Duration.zero;
        });
      }
    }
  }

  void disposeAudioPlayer() {
    if (!_isDisposed) {
      _audioPlayer.stop();
      _audioPlayer.dispose();
      _isDisposed = true;
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _removeDropdownOverlay() {
    _dropdownOverlayEntry?.remove();
    _dropdownOverlayEntry = null;
  }

  void _createOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            showVolumeSlider = false;
            showSpeedOptions = false;
          });
          _removeOverlay();
          _removeDropdownOverlay();
        },
        child: Container(color: Colors.transparent),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _createDropdownOverlay(
      {required Widget dropdown, required GlobalKey iconKey}) {
    _removeDropdownOverlay();

    final RenderBox? renderBox =
        iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final iconSize = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    const dropdownWidth = 100.0;
    const paddingFromEdge = 8.0;

    double leftPosition;
    if (iconKey == volumeIconKey) {
      leftPosition = position.dx;
    } else {
      leftPosition = position.dx + iconSize.width - dropdownWidth;
      if (leftPosition + dropdownWidth > screenWidth - paddingFromEdge) {
        leftPosition = screenWidth - dropdownWidth - paddingFromEdge;
      }
      if (leftPosition < paddingFromEdge) {
        leftPosition = paddingFromEdge;
      }
    }

    _dropdownOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: leftPosition,
        top: position.dy + iconSize.height,
        child: Material(
          elevation: 4,
          child: dropdown,
        ),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlayEntry!);
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildSpeedOption(double speed, {String? label}) {
    return InkWell(
      onTap: () {
        if (_isDisposed || !mounted) return;
        setState(() {
          playbackSpeed = speed;
          if (!_isDisposed) {
            _audioPlayer.setPlaybackRate(speed);
          }
          showSpeedOptions = false;
          _removeOverlay();
          _removeDropdownOverlay();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          label ?? '${speed}x',
          style: TextStyle(
            color: playbackSpeed == speed ? Colors.blue : Colors.black,
            fontWeight: playbackSpeed == speed ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                if (_isDisposed) return;
                if (isPlaying) {
                  await _audioPlayer.pause();
                  if (mounted) {
                    setState(() => isPlaying = false);
                  }
                } else {
                  await _audioPlayer.play(UrlSource(widget.audioUrl));
                  if (mounted) {
                    setState(() => isPlaying = true);
                  }
                }
              },
            ),
            Expanded(
              child: Slider(
                activeColor: Color(0xFF00A2FF),
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble(),
                onChanged: (value) async {
                  if (_isDisposed) return;
                  final newPosition = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(newPosition);
                  if (mounted) {
                    setState(() => position = newPosition);
                  }
                },
              ),
            ),
            Text('${formatDuration(position)} / ${formatDuration(duration)}'),
            IconButton(
              key: volumeIconKey,
              icon: const Icon(Icons.volume_up),
              onPressed: () {
                if (_isDisposed || !mounted) return;
                setState(() {
                  showVolumeSlider = !showVolumeSlider;
                  if (showVolumeSlider) {
                    showSpeedOptions = false;
                    _createOverlay();
                    _createDropdownOverlay(
                      dropdown: ValueListenableBuilder<double>(
                        valueListenable: volume,
                        builder: (context, vol, child) {
                          return Container(
                            width: 40,
                            height: 150,
                            color: Colors.grey[200],
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.blue,
                                  inactiveTrackColor: Colors.grey,
                                  thumbColor: Colors.blue,
                                  trackHeight: 4.0,
                                ),
                                child: Slider(
                                  value: vol,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    volume.value = value;
                                    if (!_isDisposed) {
                                      _audioPlayer.setVolume(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      iconKey: volumeIconKey,
                    );
                  } else {
                    _removeOverlay();
                    _removeDropdownOverlay();
                  }
                });
              },
            ),
            IconButton(
              key: settingsIconKey,
              icon: const Icon(Icons.settings),
              onPressed: () {
                if (_isDisposed || !mounted) return;
                setState(() {
                  showSpeedOptions = !showSpeedOptions;
                  if (showSpeedOptions) {
                    showVolumeSlider = false;
                    _createOverlay();
                    _createDropdownOverlay(
                      dropdown: Container(
                        width: 100,
                        color: Colors.grey[200],
                        child: Column(
                          children: [
                            _buildSpeedOption(0.5),
                            _buildSpeedOption(0.8),
                            _buildSpeedOption(0.9),
                            _buildSpeedOption(1.0, label: 'Normal'),
                            _buildSpeedOption(1.1),
                            _buildSpeedOption(1.2),
                            _buildSpeedOption(1.3),
                            _buildSpeedOption(1.5),
                            _buildSpeedOption(2.0),
                          ],
                        ),
                      ),
                      iconKey: settingsIconKey,
                    );
                  } else {
                    _removeOverlay();
                    _removeDropdownOverlay();
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
