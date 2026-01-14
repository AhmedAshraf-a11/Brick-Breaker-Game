import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../game/models.dart';
import '../game/physics_engine.dart';
import '../game/renderer.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late GameState _gameState;
  late PhysicsEngine _physicsEngine;
  
  // Game Entities
  late Ball _ball;
  late Paddle _paddle;
  late List<Brick> _bricks;
  
  Size? _gameSize;
  ui.Image? _ballImage;

  @override
  void initState() {
    super.initState();
    _gameState = GameState();
    _ticker = createTicker(_onTick);
    
    // Initialize entities with dummy values, will be reset on first layout
    _ball = Ball(position: Offset.zero, velocity: Offset.zero, radius: 10, color: Colors.deepPurple);
    _paddle = Paddle(rect: Rect.zero, color: Colors.deepPurple, speed: 0);
    _bricks = [];
    
    // Load ball image
    _loadBallImage();
  }
  
  Future<void> _loadBallImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/ball2.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      setState(() {
        _ballImage = frameInfo.image;
      });
    } catch (e) {
      // If image fails to load, fallback to circle drawing
      print('Failed to load ball image: $e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initGame(Size size) {
    _gameSize = size;
    _physicsEngine = PhysicsEngine(size);
    _resetLevel();
    _ticker.start();
  }

  void _resetLevel() {
    if (_gameSize == null) return;
    
    // Reset Ball
    _ball = Ball(
      position: Offset(_gameSize!.width / 2, _gameSize!.height / 2),
      velocity: const Offset(0, 300), // Start moving down
      radius: 8,
      color: Colors.deepPurple,
    );

    // Reset Paddle
    const paddleWidth = 100.0;
    const paddleHeight = 20.0;
    _paddle = Paddle(
      rect: Rect.fromLTWH(
        (_gameSize!.width - paddleWidth) / 2,
        _gameSize!.height - paddleHeight - 50,
        paddleWidth,
        paddleHeight,
      ),
      color: Colors.deepPurple,
      speed: 0,
    );

    // Reset Bricks
    _bricks.clear();
    const int rows = 5;
    const int cols = 7;
    const double padding = 5.0;
    const double topOffset = 50.0;
    
    final double brickWidth = (_gameSize!.width - (cols + 1) * padding) / cols;
    final double brickHeight = 20.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _bricks.add(Brick(
          rect: Rect.fromLTWH(
            padding + c * (brickWidth + padding),
            topOffset + r * (brickHeight + padding),
            brickWidth,
            brickHeight,
          ),
          color: Colors.purple[(r + 1) * 100] ?? Colors.purple,
        ));
      }
    }
    
    _gameState.status = GameStatus.playing;
  }

  void _onTick(Duration elapsed) {
    if (_gameSize == null) return;
    
    // Calculate delta time (simplified, ideally use elapsed delta)
    // Ticker gives total elapsed time. We need delta.
    // For simplicity in this step, assuming 60fps fixed step or keeping track of last frame
    // A better way is to store last elapsed.
    
    // However, for a simple game, we can just use a small fixed dt or calculate it.
    // Let's use a simplified approach:
    // Note: Ticker callback gives total elapsed time since start.
    
    setState(() {
       // In a real app, calculate actual dt. Here assuming ~16ms for 60fps
       // or better, track previous frame time.
       _physicsEngine.update(_gameState, _ball, _paddle, _bricks, 0.016);
       
       if (_gameState.status == GameStatus.gameOver || _gameState.status == GameStatus.won) {
         _ticker.stop();
       }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_gameSize == null) return;
    
    // Move paddle directly with finger
    double newLeft = _paddle.rect.left + details.delta.dx;
    
    // Clamp to screen
    if (newLeft < 0) newLeft = 0;
    if (newLeft + _paddle.rect.width > _gameSize!.width) {
      newLeft = _gameSize!.width - _paddle.rect.width;
    }
    
    _paddle.rect = Rect.fromLTWH(
      newLeft,
      _paddle.rect.top,
      _paddle.rect.width,
      _paddle.rect.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_gameSize == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initGame(Size(constraints.maxWidth, constraints.maxHeight));
            });
          }
          
          return GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Container(
              color: Colors.deepPurple.shade50,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: GamePainter(
                      ball: _ball,
                      paddle: _paddle,
                      bricks: _bricks,
                      state: _gameState,
                      ballImage: _ballImage,
                    ),
                    size: Size.infinite,
                  ),
                  // HUD
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Text(
                      'Score: ${_gameState.score}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: Text(
                      'Lives: ${_gameState.lives}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  if (_gameState.status == GameStatus.gameOver)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'GAME OVER',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _gameState = GameState();
                                _resetLevel();
                                _ticker.start();
                              });
                            },
                            child: const Text('Restart'),
                          ),
                        ],
                      ),
                    ),
                   if (_gameState.status == GameStatus.won)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'YOU WIN!',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _gameState = GameState();
                                _resetLevel();
                                _ticker.start();
                              });
                            },
                            child: const Text('Play Again'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
