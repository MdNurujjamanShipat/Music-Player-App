import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/song.dart';

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final AudioPlayer _player = AudioPlayer();

  final List<Song> _playlist = [
    Song(
      title: 'SoundHelix Song 1',
      artist: 'SoundHelix',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      durationSeconds: 356,
    ),
    Song(
      title: 'SoundHelix Song 2',
      artist: 'SoundHelix',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      durationSeconds: 325,
    ),
    Song(
      title: 'SoundHelix Song 3',
      artist: 'SoundHelix',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      durationSeconds: 390,
    ),
  ];

  int _currentIndex = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _player.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _player.onPlayerComplete.listen((event) {
      _playNext();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    final song = _playlist[_currentIndex];

    try {
      await _player.stop();
      await _player.play(UrlSource(song.url));
      setState(() {});
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_position >= _duration && _duration > Duration.zero) {
        await _player.seek(Duration.zero);
      }
      if (_player.state == PlayerState.stopped ||
          _player.state == PlayerState.completed) {
        await _playSongAtIndex(_currentIndex);
      } else {
        await _player.resume();
      }
    }
  }

  Future<void> _playNext() async {
    final nextIndex = (_currentIndex + 1) % _playlist.length;
    await _playSongAtIndex(nextIndex);
  }

  Future<void> _playPrevious() async {
    final prevIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _playSongAtIndex(prevIndex);
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _playlist[_currentIndex];
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Music Player',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: screenHeight * 0.25,
                                height: screenHeight * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.music_note,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  Text(
                                    currentSong.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentSong.artist,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Column(
                                children: [
                                  SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 14,
                                          ),
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white
                                          .withOpacity(0.3),
                                      thumbColor: Colors.white,
                                    ),
                                    child: Slider(
                                      min: 0,
                                      max: (_duration.inSeconds > 0)
                                          ? _duration.inSeconds.toDouble()
                                          : 1.0,
                                      value: (_position.inSeconds.clamp(
                                        0,
                                        (_duration.inSeconds > 0)
                                            ? _duration.inSeconds
                                            : 1,
                                      )).toDouble(),
                                      onChanged: (value) async {
                                        final newDuration = Duration(
                                          seconds: value.toInt(),
                                        );
                                        await _player.seek(newDuration);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(_position),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(_duration),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    iconSize: 32,
                                    onPressed: _playPrevious,
                                    icon: Icon(
                                      Icons.skip_previous,
                                      color: Colors.white,
                                    ),
                                    tooltip: 'Previous',
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.grey.shade300,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      iconSize: 32,
                                      onPressed: _togglePlayPause,
                                      icon: Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.deepPurple,
                                        size: 28,
                                      ),
                                      tooltip: _isPlaying ? 'Pause' : 'Play',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    iconSize: 32,
                                    onPressed: _playNext,
                                    icon: Icon(
                                      Icons.skip_next,
                                      color: Colors.white,
                                    ),
                                    tooltip: 'Next',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            const Text(
                              'Playlist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_playlist.length} songs',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 8,
                            left: 8,
                            right: 8,
                          ),
                          itemCount: _playlist.length,
                          itemBuilder: (context, index) {
                            final s = _playlist[index];
                            final isCurrent = index == _currentIndex;
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? Colors.deepPurple.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isCurrent
                                    ? Border.all(
                                        color: Colors.deepPurple.withOpacity(
                                          0.3,
                                        ),
                                        width: 1,
                                      )
                                    : null,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? Colors.deepPurple
                                        : Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: isCurrent
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  s.title,
                                  style: TextStyle(
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCurrent
                                        ? Colors.deepPurple
                                        : Colors.black87,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  s.artist,
                                  style: TextStyle(
                                    color: isCurrent
                                        ? Colors.deepPurple.withOpacity(0.7)
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: isCurrent
                                    ? Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isPlaying
                                              ? Icons.equalizer
                                              : Icons.music_note,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      )
                                    : null,
                                onTap: () async {
                                  await _playSongAtIndex(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
