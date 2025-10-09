import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'joystick.dart';

class MyGame extends FlameGame with HasCollisionDetection {
  late SpriteComponent background;
  late RectangleComponent ground;
  late Player player;
  late Joystick joystick;
  late JumpButton jumpButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // === ФОН ===
    final bg = await loadSprite('background.jpeg');
    background = SpriteComponent(
      sprite: bg,
      size: size,
      priority: 0, // фон всегда самый нижний слой
    );
    add(background);

    // === ПЛАТФОРМА ===
    ground = RectangleComponent(
      size: Vector2(size.x, 50),
      position: Vector2(0, size.y - 100),
      paint: Paint()..color = Colors.blueAccent,
      priority: 1,
    );
    add(ground);

    // === ДЖОЙСТИК ===
    joystick = Joystick()..priority = 10;
    add(joystick);

    // === КНОПКА ПРЫЖКА ===
    jumpButton = JumpButton()..priority = 11;
    add(jumpButton);

    // === ИГРОК ===
    player = Player(joystick: joystick, jumpButton: jumpButton)
      ..position = Vector2(size.x / 2, ground.position.y - 100)
      ..size = Vector2(96, 96)
      ..priority = 5;
    add(player);
  }
}
