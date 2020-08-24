import 'dart:math';

import 'package:cubit/cubit.dart';
import 'package:hive/hive.dart';
import 'package:snake/game/game_state.dart';

class SnakeGrid extends Cubit<GameState> {
  static final rand = Random();
  final Box box;
  final tiles = <int>[];
  final width = 19;
  final height = 27;
  final Function(int) onScore;
  final Function onGameOver;
  int get size => width * height;
  int snakeLength;
  int food = 0;
  int score = 0;
  Direction direction = Direction.up;

  SnakeGrid(this.box, {this.onScore, this.onGameOver}) : super(GameInit());

  @override
  void onTransition(Transition<GameState> transition) {
    super.onTransition(transition);
    if (transition.nextState is GameInit) {
      direction = Direction.up;
      snakeLength = 1;
      score = 0;
      tiles.clear();
      tiles.add(toIndex(width, height));
      newFood();
      emit(GameGridUpdate());
    }
  }

  Point toPoint(int index) {
    return Point(index % width, index ~/ width);
  }

  int toIndex(int x, int y) {
    return y ~/ 2 * x + x ~/ 2;
  }

  void update() {
    if (state is GameButtonStart || state is GameGridUpdate) {
      var index = tiles.last;
      switch (direction) {
        case Direction.up:
          index = index < width ? index - width + size : index - width;
          break;
        case Direction.down:
          index = index > (size - width) ? index + width - size : index + width;
          break;
        case Direction.left:
          index = index % width == 0 ? index - 1 + width : index - 1;
          break;
        case Direction.right:
          index = (index + 1) % width == 0 ? index + 1 - width : index + 1;
          break;
      }

      tiles.add(index);

      if (index == food) {
        eat();
      } else {
        tiles.removeAt(0);

        if (isGameOver()) {
          onGameOver?.call();
          return;
        }
      }

      emit(GameGridUpdate());
    }
  }

  bool isGameOver() {
    return tiles.length != tiles.toSet().length;
  }

  void newFood() {
    do {
      food = rand.nextInt(size);
    } while(tiles.contains(food));
  }

  void eat() {
    newFood();
    snakeLength++;
    onScore?.call(++score);
  }
}

enum Direction { up, down, left, right }
