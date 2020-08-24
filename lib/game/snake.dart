import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:hive/hive.dart';
import 'package:snake/game/snake_grid.dart';
import 'package:snake/game/game_state.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snake/game/snake_menu.dart';

class Snake extends Cubit<GameState> {
  Box box;
  SnakeGrid grid;
  SnakeMenu menu;
  Timer timer;
  int record = 0;

  Snake() : super(GameInit()) {
    init();
  }

  Future init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('snake');

    record = box.get('record', defaultValue: 0);

    menu = SnakeMenu();
    grid = SnakeGrid(box, onScore: onScore, onGameOver: onGameOver);

    emit(GameLoaded());
    reset();
  }

  void onGameOver() {
    grid.emit(GameOver());
    menu.emit(GameButtonStop());
  }

  void onScore(score) {
    menu.emit(GameInformationScore(score));
    if (score > record) {
      box.put('record', record = score);
      menu.emit(GameInformationRecord(record));
    }
  }

  void reset() {
    timer?.cancel();
    timer = null;
    menu.emit(GameInformationScore(0));
    menu.emit(GameInformationRecord(record));
    menu.emit(GameInit());
    grid.emit(GameInit());
  }

  void start() {
    if (grid.state is GameOver) {
      reset();
    }
    menu.emit(GameButtonStart());
    grid.emit(GameButtonStart());
    timer ??= Timer.periodic(Duration(milliseconds: 300), (timer) {
      grid.update();
    });
  }

  void pause() {
    menu.emit(GameButtonPause());
    grid.emit(GameButtonPause());
  }

  void stop() {
    menu.emit(GameButtonStop());
    grid.emit(GameButtonStop());
    reset();
  }
}
