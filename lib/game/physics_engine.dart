import 'dart:ui';
import 'dart:math';
import 'models.dart';

class PhysicsEngine {
  final Size gameSize;

  PhysicsEngine(this.gameSize);

  void update(GameState state, Ball ball, Paddle paddle, List<Brick> bricks, double dt) {
    if (state.status != GameStatus.playing) return;

    // Move ball
    ball.position += ball.velocity * dt;

    // Wall collisions
    if (ball.position.dx - ball.radius < 0) {
      ball.position = Offset(ball.radius, ball.position.dy);
      ball.velocity = Offset(-ball.velocity.dx, ball.velocity.dy);
    }
    if (ball.position.dx + ball.radius > gameSize.width) {
      ball.position = Offset(gameSize.width - ball.radius, ball.position.dy);
      ball.velocity = Offset(-ball.velocity.dx, ball.velocity.dy);
    }
    if (ball.position.dy - ball.radius < 0) {
      ball.position = Offset(ball.position.dx, ball.radius);
      ball.velocity = Offset(ball.velocity.dx, -ball.velocity.dy);
    }

    // Bottom collision (Game Over / Life Lost)
    if (ball.position.dy + ball.radius > gameSize.height) {
      state.lives--;
      if (state.lives <= 0) {
        state.status = GameStatus.gameOver;
      } else {
        // Reset ball position
        ball.position = Offset(gameSize.width / 2, gameSize.height / 2);
        ball.velocity = Offset(0, 300); // Reset velocity
        // Optionally pause or wait for input
      }
    }

    // Paddle collision
    Rect ballRect = Rect.fromCircle(center: ball.position, radius: ball.radius);
    if (ballRect.overlaps(paddle.rect)) {
      // Simple collision response: reverse Y and add some X based on hit position
      ball.position = Offset(ball.position.dx, paddle.rect.top - ball.radius);
      
      double hitFactor = (ball.position.dx - paddle.rect.center.dx) / (paddle.rect.width / 2);
      ball.velocity = Offset(ball.velocity.dx + hitFactor * 200, -ball.velocity.dy.abs());
      
      // Normalize speed to prevent it from getting too fast or slow purely by paddle hits
      // For now, just clamp or ensure minimum vertical speed
      if (ball.velocity.dy.abs() < 100) {
        ball.velocity = Offset(ball.velocity.dx, -100);
      }
    }

    // Brick collision
    for (var brick in bricks) {
      if (!brick.isDestroyed && ballRect.overlaps(brick.rect)) {
        brick.isDestroyed = true;
        state.score += 10;
        
        // Determine collision side (simplified)
        // A more robust way is to check previous position or intersection depth
        // For simplicity, just reverse Y for now as most hits are vertical
        // To be better: check overlap width vs height
        Rect intersection = ballRect.intersect(brick.rect);
        if (intersection.width > intersection.height) {
          ball.velocity = Offset(ball.velocity.dx, -ball.velocity.dy);
        } else {
          ball.velocity = Offset(-ball.velocity.dx, ball.velocity.dy);
        }
        break; // Handle one collision per frame to prevent weird behavior
      }
    }

    // Check win condition
    if (bricks.every((b) => b.isDestroyed)) {
      state.status = GameStatus.won;
    }
  }
}
