import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends FlameGame with TapDetector {
  late Square square;
  late List<Obstacle> obstacles;
  Random rng = Random();

  @override
  Future<void> onLoad() async {
    square = Square(size / 2);
    add(square);
    obstacles = List.generate(
        5,
        (index) => Obstacle(size.x, rng.nextInt(3) * size.y / 2,
            rng.nextDouble() * 128.0 + 64.0));
    obstacles.forEach(add);
  }

  @override
  void onTapDown(TapDownInfo event) {
    square.jump();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (square.toRect().bottom > size.y ||
        obstacles
            .any((obstacle) => obstacle.toRect().overlaps(square.toRect()))) {
      square.y = size.y / 2;
      square.speedY = 0.0;
      obstacles.forEach((obstacle) {
        obstacle.x = size.x;
        obstacle.y = rng.nextInt(3) * size.y / 2;
        obstacle.size.y = rng.nextDouble() * 128.0 + 64.0;
      });
    }
    obstacles.removeWhere((obstacle) => obstacle.x < 0);
    if (obstacles.length < 5) {
      obstacles.add(Obstacle(size.x, rng.nextInt(3) * size.y / 2,
          rng.nextDouble() * 128.0 + 64.0));
      add(obstacles.last);
    }
  }
}

class Square extends RectangleComponent {
  static const squareSize = 128.0;
  static const jumpStrength = 350.0;
  static const gravity = 1000.0;

  static final Paint orange = BasicPalette.orange.paint();

  double speedY = 0.0;

  Square(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(squareSize),
          anchor: Anchor.center,
        );

  void jump() {
    speedY = -jumpStrength;
  }

  @override
  void update(double dt) {
    super.update(dt);
    speedY += gravity * dt;
    y += speedY * dt;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    paint = orange;
  }
}

class Obstacle extends RectangleComponent {
  static const obstacleSpeed = 100.0;

  static final Paint green = BasicPalette.green.paint();

  Obstacle(double initialX, double initialY, double height)
      : super(
          position: Vector2(initialX, initialY),
          size: Vector2(128.0, height),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    x -= obstacleSpeed * dt;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    paint = green;
  }
}
