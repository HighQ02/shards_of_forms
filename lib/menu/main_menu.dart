import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:video_player/video_player.dart';
import 'package:flame_audio/flame_audio.dart';
import '../game/my_game.dart';
import '../main.dart'; // Добавляем импорт GamePage

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('menu_music.mp3');

    super.initState();
    _controller =
        VideoPlayerController.asset(
            'assets/videos/Hollow_Knight_Silksong_Animation_Creation.mp4',
          )
          ..initialize().then((_) {
            _controller.setLooping(true);
            _controller.setVolume(0);
            _controller.play();
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _menuButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white70, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Выбор игры',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuButton("Новая игра", () {
                Navigator.of(context).pop();
                FlameAudio.bgm.stop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GamePage()),
                );
              }),
              _menuButton("Продолжить", () {
                Navigator.of(context).pop();
              }),
              _menuButton("Отмена", () => Navigator.of(context).pop()),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Shards Of Forms",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 50),
                _menuButton("START GAME", _showStartDialog),
                _menuButton("OPTIONS", () {}),
                _menuButton("ACHIEVEMENTS", () {}),
                _menuButton("QUIT GAME", () {
                  FlameAudio.bgm.stop();
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
