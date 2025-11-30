import 'package:flutter/material.dart';
import 'screens/music_player_screen.dart';

void main() {
  runApp(const SimpleMusicPlayerApp());
}

class SimpleMusicPlayerApp extends StatelessWidget {
  const SimpleMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}


