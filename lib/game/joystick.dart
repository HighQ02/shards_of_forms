import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'my_game.dart'; // <--- НОВЫЙ ИМПОРТ для MyGame

class Joystick extends JoystickComponent {
  Joystick()
    : super(
        knob: CircleComponent(
          radius: 25,
          paint: Paint()..color = const Color(0xAAFFFFFF),
        ),
        background: CircleComponent(
          radius: 60,
          paint: Paint()..color = const Color(0x55FFFFFF),
        ),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );

  set positionType(
    positionType,
  ) {} // Этот сеттер не используется, можно удалить, если хотите.
}

/// Кнопка прыжка
class JumpButton extends PositionComponent with HasGameRef {
  bool isPressed = false;
  late ButtonComponent button;

  set positionType(positionType) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    button = ButtonComponent(
      button: CircleComponent(
        radius: 35,
        paint: Paint()..color = const Color(0xAAFF8800), // Оранжевая
      ),
      buttonDown: CircleComponent(
        radius: 35,
        paint: Paint()..color = const Color(0xFFFF6600),
      ),
      onPressed: () => isPressed = true,
      onReleased: () => isPressed = false,
      position: Vector2(gameRef.size.x - 100, gameRef.size.y - 100),
      anchor: Anchor.center,
      priority: 10,
    );

    add(button);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    button.position = Vector2(canvasSize.x - 100, canvasSize.y - 100);
  }
}

/// Кнопка атаки
class AttackButton extends PositionComponent with HasGameRef {
  bool isPressed = false;
  late ButtonComponent button;

  set positionType(positionType) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    button = ButtonComponent(
      button: CircleComponent(
        radius: 35,
        paint: Paint()..color = const Color(0xAAFF0000), // Красная
      ),
      buttonDown: CircleComponent(
        radius: 35,
        paint: Paint()..color = const Color(0xFFCC0000),
      ),
      onPressed: () => isPressed = true,
      onReleased: () => isPressed = false,
      position: Vector2(gameRef.size.x - 180, gameRef.size.y - 100),
      anchor: Anchor.center,
      priority: 10,
    );

    add(button);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    button.position = Vector2(canvasSize.x - 180, canvasSize.y - 100);
  }
}

/// --- НОВАЯ КНОПКА МЕНЮ / ПАУЗЫ ---
class MenuButton extends PositionComponent with HasGameRef<MyGame> {
  late ButtonComponent button;

  set positionType(positionType) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    button = ButtonComponent(
      button: CircleComponent(
        radius: 30,
        paint: Paint()..color = const Color(0xAA0000FF), // Синяя кнопка
      ),
      buttonDown: CircleComponent(
        radius: 30,
        paint: Paint()..color = const Color(0xFF0000CC),
      ),
      onPressed: () {
        print("--- 1. MenuButton НАЖАТА ---"); // <--- ДОБАВЬ ЭТО
        gameRef.togglePauseMenu();
      },
      // ИСПРАВЛЕНО: Позиция в правом верхнем углу
      position: Vector2(gameRef.size.x - 50, 50),
      anchor: Anchor.center,
      priority: 10,
    );

    add(button);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // ИСПРАВЛЕНО: Обновляем позицию
    button.position = Vector2(canvasSize.x - 50, 50);
  }
}
