import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// Простой враг для использования без спрайтов
/// Отображается как цветной прямоугольник с анимацией
class SimpleEnemy extends PositionComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  // Параметры врага
  double health = 30;
  double maxHealth = 30;
  double damage = 5;
  int xpReward = 10;
  double moveSpeed = 100;

  // Направление движения (-1 слева направо, 1 справа налево)
  double direction = 1;

  bool isDead = false;
  double deathTimer = 0;
  double animationTimer = 0;

  late Paint _paint;

  SimpleEnemy({required Vector2 position, required this.direction})
    : super(size: Vector2(60, 60), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _paint = Paint()..color = Colors.red[700]!;
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) {
      deathTimer += dt;
      // Удаляем врага через 0.5 секунды после смерти
      if (deathTimer > 0.5) {
        removeFromParent();
      }
      return;
    }

    // Анимация мигания при жизни
    animationTimer += dt;
    if (animationTimer > 0.1) {
      animationTimer = 0;
      final opacity = (health / maxHealth * 0.5) + 0.5;
      _paint.color = Colors.red[700]!.withOpacity(opacity);
    }

    // Движение врага
    position.x += moveSpeed * direction * dt;

    // Проверяем выход за границы экрана
    if (gameRef.gameWorld != null) {
      final worldPos = position;
      if (worldPos.x < -100 || worldPos.x > gameRef.worldWidth + 100) {
        removeFromParent();
      }
    }
  }

  void takeDamage(double dmg) {
    if (isDead) return;

    health -= dmg;

    if (health <= 0) {
      die();
    }
  }

  void die() {
    if (isDead) return;
    isDead = true;

    // Даём игроку опыт
    gameRef.player.addExperience(xpReward.toDouble());

    // Меняем цвет на серый при смерти
    _paint.color = Colors.grey;
  }

  // Получить процент здоровья для отрисовки полоски
  double getHealthPercent() {
    return (health / maxHealth).clamp(0, 1);
  }
}
