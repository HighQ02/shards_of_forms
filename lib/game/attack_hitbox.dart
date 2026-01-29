import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'my_game.dart';
import 'enemies/baldur.dart';
import 'enemies/mosscreep.dart';
import 'enemies/husk_hornhead.dart';
import 'player.dart';

/// Компонент хитбокса для атаки игрока
/// Появляется в момент атаки и наносит урон врагам
class AttackHitbox extends PositionComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final Player player;
  final double duration = 0.3; // Длительность хитбокса в секундах
  double elapsedTime = 0;
  final Set<dynamic> hitEnemies = {}; // Отслеживаем уже поражённых врагов

  AttackHitbox({required this.player}) {
    size = Vector2(120, 100);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    elapsedTime += dt;
    if (elapsedTime >= duration) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (!hitEnemies.contains(other)) {
      // Проверяем враги типов Baldur, Mosscreep, HuskHornhead
      if (other is Baldur || other is Mosscreep || other is HuskHornhead) {
        (other as dynamic).takeDamage(gameRef.player.attackDamage);
        hitEnemies.add(other);
      }
    }
  }
}
