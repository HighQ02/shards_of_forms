import 'package:flame/components.dart';
import 'my_game.dart';
import 'enemies/baldur.dart';
import 'enemies/mosscreep.dart';
import 'enemies/husk_hornhead.dart';
import 'dart:math';

class EnemyManager extends Component with HasGameRef<MyGame> {
  final List<dynamic> enemies = [];
  double spawnTimer = 0;
  double spawnInterval = 10; // Спавн каждые 10 секунд
  final double minSpawnInterval = 5; // Минимальный интервал
  final double maxSpawnInterval = 15; // Максимальный интервал

  final Random random = Random();

  @override
  void update(double dt) {
    super.update(dt);

    // Временно отключаем спавн для тестирования
    /*
    spawnTimer += dt;

    // Спавним врагов случайно
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      spawnInterval =
          minSpawnInterval +
          random.nextDouble() * (maxSpawnInterval - minSpawnInterval);
      _spawnEnemy();
    }
    */

    // Обновляем список врагов - удаляем мёртвых
    enemies.removeWhere((e) {
      try {
        return (e as dynamic).isDead ?? false;
      } catch (e) {
        return false;
      }
    });
  }

  void _spawnEnemy() {
    if (gameRef.gameWorld == null) return;

    // Случайно выбираем сторону: 0 = слева, 1 = справа
    final isFromLeft = random.nextBool();

    late Vector2 spawnPos;
    late double direction;

    // Используем Y позицию игрока, чтобы враги спавнились рядом
    final playerY = gameRef.player.position.y;

    if (isFromLeft) {
      // Спавним слева рядом с игроком
      spawnPos = Vector2(-50, playerY);
      direction = 1; // Движется вправо
    } else {
      // Спавним справа рядом с игроком
      spawnPos = Vector2(gameRef.worldWidth + 50, playerY);
      direction = -1; // Движется влево
    }

    // Выбираем случайного врага из трёх типов
    final enemyType = random.nextInt(3);
    late dynamic enemy;

    switch (enemyType) {
      case 0:
        enemy = Baldur(position: spawnPos, direction: direction);
        break;
      case 1:
        enemy = Mosscreep(position: spawnPos, direction: direction);
        break;
      case 2:
        enemy = HuskHornhead(position: spawnPos, direction: direction);
        break;
    }

    enemies.add(enemy);
    gameRef.gameWorld!.add(enemy);
  }

  void checkCollisions() {
    // Проверяем столкновения врагов с атакой игрока
    // Это будет вызвано из системы атак игрока
  }

  List<dynamic> getEnemies() {
    return enemies;
  }

  int getEnemyCount() {
    return enemies.length;
  }
}
