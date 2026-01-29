import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:ui' as ui;
import '../my_game.dart';

class Baldur extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  // Параметры врага
  double health = 40;
  double maxHealth = 40;
  double damage = 6;
  int xpReward = 15;
  double moveSpeed = 80;

  // Направление движения (-1 слева направо, 1 справа налево)
  double direction = 1;

  bool isDead = false;
  double deathTimer = 0;

  // Состояние враага
  String currentState = 'idle';

  // Система атак
  double attackCooldown = 0;
  double attackInterval = 2.0; // Атакует каждые 2 секунды
  double attackRange = 100; // Расстояние для атаки

  // Размер кадра спрайта (в пикселах)
  static const double frameWidth = 64;
  static const double frameHeight = 64;

  Baldur({required Vector2 position, required this.direction}) {
    size = Vector2(frameWidth, frameHeight);
    anchor = Anchor.center;
    this.position = position;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      final spriteImage = await gameRef.images.load('enemies/Baldur.png');

      // Начальная анимация - idle
      animation = _createIdleAnimation(spriteImage);

      add(RectangleHitbox());
    } catch (e) {
      print('Ошибка загрузки спрайта Baldur: $e');
      add(RectangleHitbox());
    }
  }

  SpriteAnimation _createIdleAnimation(ui.Image image) {
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 4, // 4 idle frames
        textureSize: Vector2(frameWidth, frameHeight),
        stepTime: 0.15,
        loop: true,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isDead) {
      deathTimer += dt;
      if (deathTimer > 0.5) {
        removeFromParent();
      }
      return;
    }

    // Движение врага
    position.x += moveSpeed * direction * dt;

    // Устанавливаем правильную ориентацию
    if (direction > 0) {
      scale.x = 1; // Смотрит вправо
    } else {
      scale.x = -1; // Смотрит влево
    }

    // Обновляем кулдаун атаки
    attackCooldown -= dt;

    // Проверяем расстояние до игрока и атакуем если он в пределах досягаемости
    final distanceToPlayer = (gameRef.player.position - position).length;
    if (distanceToPlayer < attackRange && attackCooldown <= 0) {
      _attackPlayer();
      attackCooldown = attackInterval;
    }

    // Проверяем выход за границы экрана
    if (gameRef.gameWorld != null) {
      final worldPos = position;
      if (worldPos.x < -100 || worldPos.x > gameRef.worldWidth + 100) {
        removeFromParent();
      }
    }
  }

  void _attackPlayer() {
    gameRef.player.takeDamage(damage);
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
    moveSpeed = 0;

    gameRef.player.addExperience(xpReward.toDouble());
  }

  double getHealthPercent() {
    return (health / maxHealth).clamp(0, 1);
  }
}
