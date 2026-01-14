import 'dart:ui';

enum GameStatus { initial, playing, gameOver, won }

class Ball {
  Offset position;
  Offset velocity;
  final double radius;
  final Color color;

  Ball({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
  });
}

class Paddle {
  Rect rect;
  final Color color;
  final double speed;

  Paddle({required this.rect, required this.color, required this.speed});
}

class Brick {
  Rect rect;
  final Color color;
  bool isDestroyed;

  Brick({required this.rect, required this.color, this.isDestroyed = false});
}

class GameState {
  int score;
  int level;
  int lives;
  GameStatus status;

  GameState({
    this.score = 0,
    this.level = 1,
    this.lives = 3,
    this.status = GameStatus.initial,
  });
}
