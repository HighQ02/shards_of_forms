import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

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
}

/// Кнопка прыжка
class JumpButton extends PositionComponent with HasGameRef {
  bool isPressed = false;
  late ButtonComponent button;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    button = ButtonComponent(
      button: CircleComponent(
        radius: 35,
        paint: Paint()..color = const Color(0xAAFF8800),
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
