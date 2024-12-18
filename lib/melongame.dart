import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game/components/ballComp.dart';
import 'package:game/components/staticFloor.dart';
import 'package:game/components/staticWallLeft.dart';
import 'package:game/components/staticWallRight.dart';
import 'package:flutter/painting.dart';
import 'package:flame_audio/flame_audio.dart';

final screenSize = Vector2(1280, 720);
final worldSize = Vector2(12.8, 7.2);

enum state {
  playing,
  game_over,
  won,
}

class MyGame extends Forge2DGame with TapCallbacks, MouseMovementDetector, HasKeyboardHandlerComponents {
  MyGame() : super(
    zoom: 100,
    gravity: Vector2(0, 15),);
  
  late final Map<int, Sprite> ballSprites;

  // init score
  TextComponent? scoreText;
  int score = 0;
  int maxBallLevel = 1;

  final Random _random = Random();

  late VerticalLineComponent verticalLine; // The line indicating ball drop position

  @override
  Color backgroundColor() => const Color(0xFFeeeeee);

  bool isGameOver = false;
  bool isWin = false;

  TextComponent? timerText;
  double timeRemaining = 120;
  int magicBallCount = 0;

  @override
  Future<void> onLoad() async {
    // fixing the camera
    camera.viewport = FixedResolutionViewport(resolution: screenSize);
    camera.moveTo(worldSize / 2);

    super.onLoad();

    //loading all of the sprites
    ballSprites = {
      1: await Sprite.load('blueberryBall.png'),
      2: await Sprite.load('cranberryBall.png'),
      3: await Sprite.load('lemonBall.png'),
      4: await Sprite.load('oliveBall.png'),
      5: await Sprite.load('orangeBall.png'),
      6: await Sprite.load('pinkBall.png'),
      7: await Sprite.load('appleBall.png'),
      8: await Sprite.load('melonBall.png'),
      9: await Sprite.load('coconutBall.png'),
      10: await Sprite.load('magicBall.png'),
    };

    world.add(FloorStatic());
    world.add(WallStaticRight());
    world.add(WallStaticLeft());

    // ||||||| UI COMPONENTS AND INIT |||||||||

    // create and add the score/timer text
    scoreText = TextComponent(
      text: 'Timer: $timeRemaining Score: $score',
      position: Vector2(screenSize.x - 20, 20), // Initial position
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 24,
          fontFamily: 'Arial',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText!);

    verticalLine = VerticalLineComponent(screenHeight: screenSize.y);
    add(verticalLine);

    startTimer();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (scoreText != null) {
      scoreText!.position = Vector2(size.x - 20, 20); // reposition dynamically
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return; 

    final screenPosition = event.localPosition;
    final worldPosition = screenToWorld(screenPosition);
    final ballPosition = Vector2(
      worldPosition.x.clamp(0.5, worldSize.x - 0.5),
      0.5,
    );
    // create ball

    final randomLevel = _random.nextInt(maxBallLevel) + 1;
    world.add(Ball(initialPosition: ballPosition, level: randomLevel, game: this));
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition = info.eventPosition.global;
    verticalLine.updatePosition(screenPosition.x);
  }

  // method to update score and update max level
  void updateScore(int level) {
    score += level * 183; // score scales based on level
    scoreText!.text = 'Timer: $timeRemaining Score: $score';

    // update max level range
    if (level > maxBallLevel) {
      maxBallLevel = level - 1;
    }
  }

  // ||||||| LOSE & WIN CONDITION |||||||

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), _timerTick);
  }

  void _timerTick() {
    if (!isGameOver && !isWin && timeRemaining > 0) {
      timeRemaining -= 1;
      scoreText!.text = 'Timer: $timeRemaining Score: $score'; // update the timer text
      if (timeRemaining > 0) {
        Future.delayed(const Duration(seconds: 1), _timerTick);
      } else {
        if (magicBallCount < 1) {
          triggerGameOver();
        }
        else {
          triggerWin();
        }
      }
    }
  }

  void triggerGameOver() {
    isGameOver = true;
    overlays.add('GameOver');
  }

  void triggerWin() {
    isWin = true;
    overlays.add('GameWin');
  }

  void resetGame() {
    isGameOver = false;
    score = 0;
    maxBallLevel = 1;
    magicBallCount = 0;
    timeRemaining = 55.0;

    world.children.whereType<Ball>().forEach((ball) => ball.removeFromParent());
    scoreText?.text = 'Score: 0';
  }

  void addCommand(void Function() command) {
    Future.microtask(command);
  }
}

class VerticalLineComponent extends PositionComponent {
  Paint paint = Paint()..color = const Color.fromARGB(255, 0, 0, 0);
  double screenHeight;

  VerticalLineComponent({required this.screenHeight});

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      Offset.zero,
      Offset(0, screenHeight),
      paint..strokeWidth = 2,
    );
  }

  void updatePosition(double x) {
    position.x = x;
  }

  void updateHeight(double newHeight) {
    screenHeight = newHeight;
  }
}
