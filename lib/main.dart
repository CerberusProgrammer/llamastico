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
  late List<PowerUp> powerUps;
  Random rng = Random();
  double timeUntilNextPowerUp = 3.0;

  @override
  Future<void> onLoad() async {
    square = Square(size / 2);
    add(square);
    obstacles = List.generate(
        5,
        (index) => Obstacle(size.x + index * size.x / 5,
            rng.nextInt(3) * size.y / 2, rng.nextDouble() * 256.0 + 64.0));
    obstacles.forEach(add);
    powerUps = [];
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
            .any((obstacle) => obstacle.toRect().overlaps(square.toRect())) ||
        square.size.x <= 0 ||
        square.size.y <= 0) {
      square.y = size.y / 2;
      square.speedY = 0.0;
      square.size.x = Square.squareSize;
      square.size.y = Square.squareSize;
      obstacles.forEach((obstacle) {
        obstacle.x = size.x + obstacles.indexOf(obstacle) * size.x / 5;
        obstacle.y = rng.nextInt(3) * size.y / 2;
        obstacle.size.y = rng.nextDouble() * 256.0 + 64.0;
      });
      powerUps.forEach(remove);
      powerUps.clear();
      timeUntilNextPowerUp = 3.0;
    }
    obstacles.removeWhere((obstacle) => obstacle.x < 0);
    if (obstacles.length < 5) {
      obstacles.add(Obstacle(size.x, rng.nextInt(3) * size.y / 2,
          rng.nextDouble() * 256.0 + 64.0));
      add(obstacles.last);
    }
    powerUps.removeWhere((powerUp) => powerUp.x < 0);
    List<PowerUp> toRemove = [];
    powerUps
        .where((powerUp) => powerUp.toRect().overlaps(square.toRect()))
        .forEach((powerUp) {
      square.size.x = Square.squareSize;
      square.size.y = Square.squareSize;
      toRemove.add(powerUp);
    });
    toRemove.forEach((powerUp) {
      powerUps.remove(powerUp);
      remove(powerUp);
    });
    timeUntilNextPowerUp -= dt;
    if (timeUntilNextPowerUp <= 0) {
      powerUps.add(PowerUp(size.x, rng.nextDouble() * size.y));
      add(powerUps.last);
      timeUntilNextPowerUp = 3.0;
    }
    square.size.x -= dt * 10;
    square.size.y -= dt * 10;
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
  static const obstacleSpeed = 200.0;

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

class PowerUp extends RectangleComponent {
  static const powerUpSpeed = 200.0;

  static final Paint orange = BasicPalette.orange.paint();

  PowerUp(double initialX, double initialY)
      : super(
          position: Vector2(initialX, initialY),
          size: Vector2.all(32.0),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    x -= powerUpSpeed * dt;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    paint = orange;
  }
}
