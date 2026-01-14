import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';

class GamePainter extends CustomPainter {
  final Ball ball;
  final Paddle paddle;
  final List<Brick> bricks;
  final GameState state;
  final ui.Image? ballImage;

  GamePainter({
    required this.ball,
    required this.paddle,
    required this.bricks,
    required this.state,
    this.ballImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Background
    final bgPaint = Paint()..color = Colors.deepPurple.shade50;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw Bricks
    for (var brick in bricks) {
      if (!brick.isDestroyed) {
        final brickPaint = Paint()..color = brick.color;
        canvas.drawRect(brick.rect, brickPaint);
        
        // Optional: Draw border for bricks
        final borderPaint = Paint()
          ..color = Colors.black12
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        canvas.drawRect(brick.rect, borderPaint);
      }
    }

    // Draw Paddle
    final paddlePaint = Paint()..color = paddle.color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(paddle.rect, Radius.circular(4)),
      paddlePaint,
    );

    // Draw Ball
    if (ballImage != null) {
      // Draw ball image
      final srcRect = Rect.fromLTWH(0, 0, ballImage!.width.toDouble(), ballImage!.height.toDouble());
      final dstRect = Rect.fromCircle(center: ball.position, radius: ball.radius);
      canvas.drawImageRect(ballImage!, srcRect, dstRect, Paint());
    } else {
      // Fallback to circle if image not loaded
      final ballPaint = Paint()..color = ball.color;
      canvas.drawCircle(ball.position, ball.radius, ballPaint);
    }

    // Draw HUD (Score, Lives)
    // You can also do this with Flutter widgets on top of the CustomPaint
    // But drawing here is also fine for simple text
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true; // Always repaint for game loop
  }
}
