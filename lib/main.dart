// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/pause_menu.dart';
import 'game/my_game.dart';
import 'game/game_hud.dart';
import 'menu/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainMenu(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  MyGame? game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Восстанавливаем игру при возвращении в приложение
      game?.resumeEngine();
    } else if (state == AppLifecycleState.paused) {
      // Приостанавливаем игру при сворачивании приложения
      game?.pauseEngine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget.controlled(
              gameFactory: () {
                game = MyGame();
                return game!;
              },
              overlayBuilderMap: {
                'PauseMenu': (context, game) => PauseMenu(game: game as MyGame),
              },
            ),
            if (game != null) GameHUD(game: game!),
          ],
        ),
      ),
    );
  }
}
