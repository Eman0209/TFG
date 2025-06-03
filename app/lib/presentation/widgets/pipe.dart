import 'dart:math';

import 'package:flutter/material.dart';

enum Direction { up, right, down, left }

class PipeTile {
  Set<Direction> connections;
  int rotation = 0; // 0, 90, 180, 270

  PipeTile(this.connections);

  void rotate() {
    rotation = (rotation + 90) % 360;
    connections = connections.map((d) => _rotateDirection(d)).toSet();
  }

  static Direction _rotateDirection(Direction d) {
    return Direction.values[(d.index + 1) % 4];
  }

  static PipeTile random() {
    final shapes = [
      {Direction.up, Direction.down}, // vertical
      {Direction.left, Direction.right}, // horizontal
      {Direction.up, Direction.right}, // elbow
      {Direction.right, Direction.down}, // elbow
      {Direction.down, Direction.left}, // elbow
      {Direction.left, Direction.up}, // elbow
      {Direction.up, Direction.right, Direction.down, Direction.left}, // cross
    ];
    final rand = Random();
    return PipeTile(shapes[rand.nextInt(shapes.length)]);
  }
}

class PipePainter extends CustomPainter {
  final PipeTile tile;

  PipePainter(this.tile);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final half = size.width / 2;

    for (var dir in tile.connections) {
      Offset end;
      switch (dir) {
        case Direction.up:
          end = Offset(center.dx, 0);
          break;
        case Direction.down:
          end = Offset(center.dx, size.height);
          break;
        case Direction.left:
          end = Offset(0, center.dy);
          break;
        case Direction.right:
          end = Offset(size.width, center.dy);
          break;
      }
      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

