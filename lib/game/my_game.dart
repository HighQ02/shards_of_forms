import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'player.dart';
import 'joystick.dart';
import 'enemy_manager.dart';

class MyGame extends FlameGame with HasCollisionDetection {
  // Переименовали в gameWorld, чтобы не конфликтовать с встроенным world
  PositionComponent? gameWorld;
  late SpriteComponent background;
  late RectangleComponent ground;
  late Player player;
  late EnemyManager enemyManager;

  late Joystick joystick;
  late JumpButton jumpButton;
  late AttackButton attackButton;
  late MenuButton menuButton;

  late double worldWidth;
  late double worldHeight;

  int currentMap = 1;
  bool isPaused = false;
  // Флаг чтобы избежать одновременной загрузки карт и дублирования игрока
  bool _isLoadingMap = false;

  final double cameraDeadZone = 150.0;
  double cameraOffsetX = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // музыка (опционально)
    FlameAudio.bgm.initialize();
    // FlameAudio.bgm.play('game_music.mp3'); // раскомментируй если есть аудио

    // Инициализируем EnemyManager в начале
    enemyManager = EnemyManager();
    add(enemyManager);

    // создаём UI (добавляются в игровую сцену, но не в gameWorld)
    joystick = Joystick()..priority = 100;
    add(joystick);

    jumpButton = JumpButton()..priority = 101;
    add(jumpButton);

    attackButton = AttackButton()..priority = 101;
    add(attackButton);

    menuButton = MenuButton()..priority = 101;
    add(menuButton);

    // создаём игрока один раз (пока не добавляем в gameWorld)
    player = Player(
      joystick: joystick,
      jumpButton: jumpButton,
      attackButton: attackButton,
    )..priority = 10;

    // строим первую карту и внутри неё добавим игрока
    await _buildWorld(1);
  }

  Future<void> _buildWorld(int mapNumber) async {
    // Очищаем старых врагов при смене карты
    for (var enemy in enemyManager.getEnemies().toList()) {
      if (enemy.parent != null) {
        enemy.removeFromParent();
      }
    }
    enemyManager.enemies.clear();

    if (gameWorld != null && gameWorld!.parent != null) {
      gameWorld!.removeFromParent();
    }

    final sprite = await loadSprite(
      mapNumber == 1 ? 'location1.png' : 'location2.png',
    );

    final orig = sprite.srcSize;
    final scale = size.y / orig.y;
    worldWidth = orig.x * scale;
    worldHeight = size.y;

    gameWorld = PositionComponent()
      ..size = Vector2(worldWidth, worldHeight)
      ..position = Vector2.zero();

    background = SpriteComponent(
      sprite: sprite,
      size: Vector2(worldWidth, worldHeight),
      position: Vector2.zero(),
      anchor: Anchor.topLeft,
    );
    gameWorld!.add(background);

    // --- ИСПРАВЛЕНО ---
    ground = RectangleComponent(
      size: Vector2(worldWidth, 50),
      position: Vector2(0, worldHeight - 50),
      paint: Paint()..color = Colors.transparent,
    )..debugMode = true; // <--- ИСПРАВЛЕНО
    gameWorld!.add(ground);

    if (mapNumber == 1) {
      gameWorld!.add(
        RectangleComponent(
          size: Vector2(160, 20),
          position: Vector2(worldWidth - 420, worldHeight - 120),
          paint: Paint()..color = Colors.transparent,
        )..debugMode = true, // <--- ИСПРАВЛЕНО
      );
      gameWorld!.add(
        RectangleComponent(
          size: Vector2(120, 20),
          position: Vector2(worldWidth - 280, worldHeight - 180),
          paint: Paint()..color = Colors.transparent,
        )..debugMode = true, // <--- ИСПРАВЛЕНО
      );
      gameWorld!.add(
        RectangleComponent(
          size: Vector2(80, 20),
          position: Vector2(worldWidth - 180, worldHeight - 240),
          paint: Paint()..color = Colors.transparent,
        )..debugMode = true, // <--- ИСПРАВЛЕНО
      );
    } else {
      gameWorld!.add(
        RectangleComponent(
          size: Vector2(worldWidth * 0.45, 20),
          position: Vector2(0, worldHeight - 50),
          paint: Paint()..color = Colors.transparent,
        )..debugMode = true, // <--- ИСПРАВЛЕНО
      );
      gameWorld!.add(
        RectangleComponent(
          size: Vector2(worldWidth * 0.45, 20),
          position: Vector2(worldWidth * 0.55, worldHeight - 50),
          paint: Paint()..color = Colors.transparent,
        )..debugMode = true, // <--- ИСПРАВЛЕНО
      );
    }

    // Добавляем игрока в мир (если он ещё не добавлен)
    // Если игрок всё ещё привязан к старому родителю — удалим его оттуда
    if (player.parent != null) {
      player.removeFromParent();
    }

    if (!gameWorld!.children.contains(player)) {
      gameWorld!.add(player);
    }

    // Устанавливаем стартовую позицию игрока для каждой карты
    if (mapNumber == 1) {
      player.position = Vector2(150, worldHeight - 200);
    } else {
      player.position = Vector2(100, worldHeight - 200);
    }

    // Добавляем gameWorld в сцену (под UI)
    if (gameWorld!.parent == null) {
      add(gameWorld!);
    }

    cameraOffsetX = 0;
    gameWorld!.position = Vector2(-cameraOffsetX, 0);
  }

  Future<void> loadNextMap() async {
    if (_isLoadingMap) return;
    if (currentMap == 1) {
      _isLoadingMap = true;
      try {
        currentMap = 2;

        if (player.parent != null) {
          player.removeFromParent();
        }
        await _buildWorld(2);

        player.position = Vector2(50, worldHeight - 200);
      } finally {
        _isLoadingMap = false;
      }
    }
  }

  Future<void> loadPreviousMap() async {
    if (_isLoadingMap) return;
    if (currentMap == 2) {
      _isLoadingMap = true;
      try {
        currentMap = 1;
        if (player.parent != null) {
          player.removeFromParent();
        }
        await _buildWorld(1);
        player.position = Vector2(worldWidth - 150, worldHeight - 200);

        cameraOffsetX = (worldWidth > size.x) ? (worldWidth - size.x) : 0.0;
        gameWorld!.position = Vector2(-cameraOffsetX, 0);
      } finally {
        _isLoadingMap = false;
      }
    }
  }

  @override
  void update(double dt) {
    if (isPaused) return;
    super.update(dt);

    if (gameWorld == null) return;

    // --- Логика камеры (остается как есть) ---
    if (worldWidth <= size.x) {
      cameraOffsetX = 0;
      gameWorld!.position = Vector2.zero();
    } else {
      final playerWorldX = player.position.x;
      final screenX = playerWorldX - cameraOffsetX;

      if (screenX > size.x - cameraDeadZone) {
        final targetOffset = (playerWorldX - (size.x - cameraDeadZone));
        cameraOffsetX = targetOffset.clamp(0, worldWidth - size.x);
      } else if (screenX < cameraDeadZone) {
        final targetOffset = (playerWorldX - cameraDeadZone);
        cameraOffsetX = targetOffset.clamp(0, worldWidth - size.x);
      }
      gameWorld!.position = Vector2(-cameraOffsetX, 0);
    }

    // --- ИСПРАВЛЕНО: Логика границ и переходов ---

    // Половина ширины игрока для точных расчетов
    final halfW = player.size.x / 2;

    if (currentMap == 1) {
      // --- КАРТА 1 ---

      // 1. Блокируем выход слева
      if (player.position.x < halfW) {
        player.position.x = halfW;
      }

      // 2. Переход на Карту 2 (справа)
      if (player.position.x > worldWidth - 30) {
        // ignore: unawaited_futures
        loadNextMap();
      }
    } else if (currentMap == 2) {
      // --- КАРТА 2 ---

      // 1. Переход на Карту 1 (слева)
      if (player.position.x < 30) {
        // ignore: unawaited_futures
        loadPreviousMap();
      }

      // 2. Блокируем выход справа
      if (player.position.x > worldWidth - halfW) {
        player.position.x = worldWidth - halfW;
      }
    }
  }

  void togglePauseMenu() {
    isPaused = !isPaused;
    if (isPaused) {
      overlays.add('PauseMenu');
    } else {
      overlays.remove('PauseMenu');
    }
  }
}
