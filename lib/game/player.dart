import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'joystick.dart';
import 'my_game.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final Joystick joystick;
  final JumpButton jumpButton;
  final AttackButton attackButton;

  // --- Анимации ---
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;
  late SpriteAnimation jumpAnticipateAnimation; // Приседание
  late SpriteAnimation jumpAnimation; // В воздухе
  late SpriteAnimation attackAnimation;

  // --- Параметры движения ---
  double moveSpeed = 200;
  double gravity = 600;
  double velocityY = 0;
  bool isOnGround = false;

  // --- Состояния ---
  bool isJumping = false;
  bool isPreparingJump = false;
  bool isAttacking = false;

  // --- Переменная высота прыжка ---
  double jumpInitialForce = -250;
  double jumpHoldForce = -800;
  double maxJumpHoldTime = 0.15;
  double jumpHoldTimer = 0.0;
  bool canJumpHold = false;

  Player({
    required this.joystick,
    required this.jumpButton,
    required this.attackButton,
  }) {
    size = Vector2(100, 100);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // === Загружаем файлы ===
    final idleImage = await gameRef.images.load('hornet_idle.png');
    final walkImage = await gameRef.images.load('hornet_walk.png');
    final jumpAnticipateImage = await gameRef.images.load(
      'hornet_jump_anticipate.png',
    );
    final jumpImage = await gameRef.images.load('hornet_jump.png');
    final attackImage = await gameRef.images.load('hornet_attack.png');

    // === ИСПРАВЛЕНО: Настраиваем анимации с ВАШИМИ цифрами ===

    // 1. Ожидание (6 кадров, 1 ряд)
    idleAnimation = SpriteAnimation.fromFrameData(
      idleImage,
      SpriteAnimationData.sequenced(
        amount: 6, // БЫЛО: 8
        textureSize: Vector2(idleImage.width / 6, idleImage.height.toDouble()),
        stepTime: 0.15,
        loop: true,
      ),
    );

    // 2. Ходьба (8 кадров, 1 ряд)
    walkAnimation = SpriteAnimation.fromFrameData(
      walkImage,
      SpriteAnimationData.sequenced(
        amount: 8, // БЫЛО: 6
        textureSize: Vector2(walkImage.width / 8, walkImage.height.toDouble()),
        stepTime: 0.1,
        loop: true,
      ),
    );

    // 3. Приседание (4 кадра, 1 ряд)
    jumpAnticipateAnimation = SpriteAnimation.fromFrameData(
      jumpAnticipateImage,
      SpriteAnimationData.sequenced(
        amount: 4, // БЫЛО: 3
        textureSize: Vector2(
          jumpAnticipateImage.width / 4,
          jumpAnticipateImage.height.toDouble(),
        ),
        stepTime: 0.08,
        loop: false,
      ),
    );

    // 4. Прыжок (9 кадров, 1 ряд)
    jumpAnimation = SpriteAnimation.fromFrameData(
      jumpImage,
      SpriteAnimationData.sequenced(
        amount: 9, // БЫЛО: 5
        textureSize: Vector2(jumpImage.width / 9, jumpImage.height.toDouble()),
        stepTime: 0.1,
        loop: false,
      ),
    );

    // 5. Атака (7 кадров, 2 ряда) - Эта логика остается, т.к. она верная
    final frameWidth = attackImage.width / 6.0;
    final frameHeight = attackImage.height / 2.0;
    final frameSize = Vector2(frameWidth, frameHeight);

    attackAnimation = SpriteAnimation.fromFrameData(
      attackImage,
      SpriteAnimationData([
        SpriteAnimationFrameData(
          srcPosition: Vector2(0 * frameWidth, 0),
          srcSize: frameSize,
          stepTime: 0.08,
        ),
        SpriteAnimationFrameData(
          srcPosition: Vector2(1 * frameWidth, 0),
          srcSize: frameSize,
          stepTime: 0.08,
        ),
        SpriteAnimationFrameData(
          srcPosition: Vector2(2 * frameWidth, 0),
          srcSize: frameSize,
          stepTime: 0.08,
        ),
        SpriteAnimationFrameData(
          srcPosition: Vector2(3 * frameWidth, 0),
          srcSize: frameSize,
          stepTime: 0.08,
        ),
        SpriteAnimationFrameData(
          srcPosition: Vector2(4 * frameWidth, 0),
          srcSize: frameSize,
          stepTime: 0.08,
        ),
        SpriteAnimationFrameData(
          srcPosition: Vector2(5 * frameWidth, 0),
          srcSize: frameSize,
          stepTime: 0.08,
        ),
        SpriteAnimationFrameData(
          srcPosition: Vector2(0 * frameWidth, 1 * frameHeight),
          srcSize: frameSize,
          stepTime: 0.08,
        ),
      ], loop: false),
    );

    animation = idleAnimation;
    add(RectangleHitbox());
    position = Vector2(150, gameRef.worldHeight - 150);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // --- 1. Гравитация ---
    if (!(isJumping && jumpButton.isPressed && canJumpHold)) {
      velocityY += gravity * dt;
    }

    // --- 2. Переменная высота прыжка ---
    if (isJumping && jumpButton.isPressed && canJumpHold) {
      if (jumpHoldTimer < maxJumpHoldTime) {
        velocityY += jumpHoldForce * dt;
        jumpHoldTimer += dt;
      } else {
        canJumpHold = false;
      }
    }
    if (isJumping && !jumpButton.isPressed) {
      canJumpHold = false;
    }

    position.y += velocityY * dt;

    // --- 3. Проверка касания земли ---
    if (position.y >= gameRef.ground.position.y - size.y / 2) {
      position.y = gameRef.ground.position.y - size.y / 2;
      velocityY = 0;

      if (!isOnGround) {
        isJumping = false;
        canJumpHold = false;

        if (!isAttacking && !isPreparingJump) {
          animation = idleAnimation;
          animationTicker?.reset();
        }
      }
      isOnGround = true;
    } else {
      isOnGround = false;
    }

    // --- 4. Логика состояний ---

    // 4.1. ЕСЛИ АТАКУЕМ
    if (isAttacking) {
      if (animationTicker?.done() ?? false) {
        isAttacking = false;
      }
      return;
    }

    // 4.2. ЕСЛИ ГОТОВИМСЯ К ПРЫЖКУ
    if (isPreparingJump) {
      if (animationTicker?.done() ?? false) {
        isPreparingJump = false;
        isJumping = true;
        canJumpHold = true;
        jumpHoldTimer = 0.0;
        velocityY = jumpInitialForce;
        animation = jumpAnimation;
        animationTicker?.reset();
      }
      return;
    }

    // 4.3. ПРОВЕРКА ВВОДА (Input)
    if (attackButton.isPressed && isOnGround) {
      isAttacking = true;
      animation = attackAnimation;
      animationTicker?.reset();
      return;
    }

    if (jumpButton.isPressed && isOnGround && !isJumping) {
      isPreparingJump = true;
      animation = jumpAnticipateAnimation;
      animationTicker?.reset();
      return;
    }

    // 4.4. ДВИЖЕНИЕ ВЛЕВО/Вправо
    final dx = joystick.relativeDelta.x;
    if (dx.abs() > 0.12) {
      position.x += dx * moveSpeed * dt;

      // Проверяем, что анимация неактивна, прежде чем ее запускать
      if (isOnGround && animation != walkAnimation) {
        animation = walkAnimation;
      }

      // === ИНВЕРТИРОВАННОЕ УПРАВЛЕНИЕ ===
      if (dx < 0 && scale.x < 0) {
        scale.x = -scale.x;
      }
      if (dx > 0 && scale.x > 0) {
        scale.x = -scale.x;
      }
    } else if (isOnGround && animation != idleAnimation) {
      // Проверяем, что не стоим уже
      animation = idleAnimation;
    }

    // 4.5. Анимация в воздухе
    if (!isOnGround &&
        !isJumping &&
        !isPreparingJump &&
        animation != jumpAnimation) {
      animation = jumpAnimation;
      animationTicker?.reset();
    }

    // --- 5. Ограничения в пределах мира ---
    // final halfW = size.x / 2;
    // // Оставляем ограничение слева
    // if (position.x < halfW) {
    //   position.x = halfW;
    // }

    // Ограничение справа УБРАНО, чтобы работал переход на карту
    /*
    if (position.x > gameRef.worldWidth - halfW) {
      position.x = gameRef.worldWidth - halfW;
    }
    */
  }
}
