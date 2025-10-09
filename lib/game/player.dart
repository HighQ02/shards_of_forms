import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'joystick.dart';

class Player extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final Joystick joystick;
  final JumpButton jumpButton;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation jumpAnimation;

  double moveSpeed = 200;
  double gravity = 800;
  double jumpForce = -450;
  double velocityY = 0;
  bool isOnGround = false;

  Player({required this.joystick, required this.jumpButton});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // === ЗАГРУЗКА АНИМАЦИЙ ===
    final idleImage = await gameRef.images.load('player_idle.png');
    final runImage = await gameRef.images.load('player_run.png');
    final jumpImage = await gameRef.images.load('player_jump.png');

    idleAnimation = SpriteAnimation.fromFrameData(
      idleImage,
      SpriteAnimationData.sequenced(
        amount: 6,
        textureSize: Vector2(idleImage.width / 6, idleImage.height.toDouble()),
        stepTime: 0.18,
        loop: true,
      ),
    );

    runAnimation = SpriteAnimation.fromFrameData(
      runImage,
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(runImage.width / 8, runImage.height.toDouble()),
        stepTime: 0.1,
        loop: true,
      ),
    );

    jumpAnimation = SpriteAnimation.fromFrameData(
      jumpImage,
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2(jumpImage.width / 4, jumpImage.height.toDouble()),
        stepTime: 0.15,
        loop: false,
      ),
    );

    animation = idleAnimation;
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // === ГРАВИТАЦИЯ ===
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // === ОГРАНИЧЕНИЕ — ПОЛ ===
    final groundY = gameRef.size.y - 100 - size.y / 2;
    if (position.y >= groundY) {
      position.y = groundY;
      velocityY = 0;
      isOnGround = true;
    } else {
      isOnGround = false;
    }

    // === ДВИЖЕНИЕ ===
    final dx = joystick.relativeDelta.x;

    if (dx.abs() > 0.1) {
      position.x += dx * moveSpeed * dt;
      animation = runAnimation;

      // зеркалим спрайт при движении влево
      if (dx < 0 && scale.x > 0) scale.x = -1;
      if (dx > 0 && scale.x < 0) scale.x = 1;
    } else if (isOnGround) {
      animation = idleAnimation;
    }

    // === ПРЫЖОК ===
    if (jumpButton.isPressed && isOnGround) {
      velocityY = jumpForce;
      animation = jumpAnimation;
      isOnGround = false;
    }

    // === ОГРАНИЧЕНИЯ ===
    final halfW = size.x / 2;
    position.x = position.x.clamp(halfW, gameRef.size.x - halfW);
  }
}
