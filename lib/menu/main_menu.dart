import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:video_player/video_player.dart';
import '../game/my_game.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/background.mp4')
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🎬 Видео-фон
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
            )
          else
            const Center(child: CircularProgressIndicator()),

          /// 🌫 Полупрозрачная маска для читаемости текста
          Container(color: Colors.black.withOpacity(0.4)),

          /// 🕹 Кнопки меню
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _menuButton("START GAME", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameWidget(game: MyGame()),
                    ),
                  );
                }),
                _menuButton("OPTIONS", () {
                  // позже добавим окно настроек
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Options menu coming soon!")),
                  );
                }),
                _menuButton("ACHIEVEMENTS", () {
                  // позже добавим достижения
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Achievements coming soon!")),
                  );
                }),
                _menuButton("QUIT GAME", () {
                  // закрываем приложение
                  Future.delayed(const Duration(milliseconds: 200), () {
                    Navigator.of(context).pop();
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
