import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'my_game.dart';
import 'dart:math';

class Enemy extends SpriteComponent
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

  // Список спрайтов врагов
  static const List<String> enemySprites = [
    'enemies/Baldur.png',
    'enemies/Husk Hornhead.png',
    'enemies/Mosscreep.png',
  ];

  Enemy({required Vector2 position, required this.direction}) {
    size = Vector2(80, 80);
    anchor = Anchor.center;
    this.position = position;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    try {
      // Выбираем случайный спрайт врага
      final random = Random();
      final spriteIndex = random.nextInt(enemySprites.length);
      final spriteImage = await gameRef.images.load(enemySprites[spriteIndex]);

      sprite = Sprite(spriteImage);

      add(RectangleHitbox());
    } catch (e) {
      // Если спрайт не найден, создаем белый квадрат
      print('Ошибка загрузки спрайта врага: $e');
      add(RectangleHitbox());
    }
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

    // Движение врага
    position.x += moveSpeed * direction * dt;

    // Устанавливаем правильную ориентацию
    if (direction > 0) {
      scale.x = -1; // Смотрит вправо
    } else {
      scale.x = 1; // Смотрит влево
    }

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
  }

  double getHealthPercent() {
    return (health / maxHealth).clamp(0, 1);
  }
}
