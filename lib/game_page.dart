import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:snake/game/game_state.dart';
import 'package:snake/game/snake.dart';
import 'package:snake/game/snake_grid.dart';
import 'package:snake/game/snake_menu.dart';

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CubitBuilder<Snake, GameState>(
        builder: (context, state) {
          if (state is GameInit) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGrid(),
              _buildMenu(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenu() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInformation(),
          _buildButtons(),
        ],
      ),
    );
  }

  Expanded _buildButtons() {
    return Expanded(
      child: CubitProvider(
        create: (context) => context.cubit<Snake>().menu,
        child: CubitBuilder<SnakeMenu, GameState>(
          buildWhen: (previous, current) {
            return current is GameButtonState || current is GameInit;
          },
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlayButton(context, state),
                _buildPauseButton(context, state),
                _buildStopButton(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Padding _buildInformation() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: CubitProvider(
        create: (context) => context.cubit<Snake>().menu,
        child: Row(
          children: [
            _buildScore(),
            _buildRecord(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecord() {
    return Expanded(
      child: Center(
        child: CubitBuilder<SnakeMenu, GameState>(
          buildWhen: (previous, current) {
            return current is GameInformationRecord || current is GameInit;
          },
          builder: (context, state) {
            if (state is GameInformationRecord) {
              return Text('R E C O R D: ${state.point}');
            }

            return Text('R E C O R D: ${context.cubit<Snake>().record}');
          },
        ),
      ),
    );
  }

  Widget _buildScore() {
    return Expanded(
      child: Center(
        child: CubitBuilder<SnakeMenu, GameState>(
          buildWhen: (previous, current) {
            return current is GameInformationScore || current is GameInit;
          },
          builder: (context, state) {
            if (state is GameInformationScore) {
              return Text('S C O R E: ${state.point}');
            }

            return Text('S C O R E: 0');
          },
        ),
      ),
    );
  }

  Expanded _buildPlayButton(BuildContext context, GameState state) {
    var enabled = state is! GameButtonStart || state is GameInit;
    return Expanded(
      child: FlatButton.icon(
        onPressed: enabled
            ? () {
                context.cubit<Snake>().start();
              }
            : null,
        icon: Icon(Icons.play_arrow),
        label: Text('С Т А Р Т'),
      ),
    );
  }

  Expanded _buildPauseButton(BuildContext context, GameState state) {
    var enabled = state is! GameButtonPause &&
        state is! GameButtonStop &&
        state is! GameInit;
    return Expanded(
      child: FlatButton.icon(
        onPressed: enabled
            ? () {
                context.cubit<Snake>().pause();
              }
            : null,
        icon: Icon(Icons.pause),
        label: Text('П А У З А'),
      ),
    );
  }

  Expanded _buildStopButton(BuildContext context, GameState state) {
    var enabled = state is! GameButtonStop && state is! GameInit;
    return Expanded(
      child: FlatButton.icon(
        onPressed: enabled
            ? () {
                context.cubit<Snake>().stop();
              }
            : null,
        icon: Icon(Icons.stop),
        label: Text('С Т О П'),
      ),
    );
  }

  Widget _buildGrid() {
    return CubitProvider(
      create: (context) => context.cubit<Snake>().grid,
      child: CubitBuilder<SnakeGrid, GameState>(
        builder: (context, state) {
          var grid = context.cubit<SnakeGrid>();
          return Stack(
            children: [
              _buildGameGrid(grid, state),
              if (state is GameButtonPause) _buildPauseScreen(),
              if (state is GameOver) _buildGameOverScreen(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameGrid(SnakeGrid grid, state) {
    return GestureDetector(
      onVerticalDragUpdate: (d) {
        if (state is GameButtonStart || state is GameGridUpdate) {
          if (grid.direction != Direction.up && d.delta.dy > 0) {
            grid.direction = Direction.down;
          } else if (grid.direction != Direction.down && d.delta.dy < 0) {
            grid.direction = Direction.up;
          }
        }
      },
      onHorizontalDragUpdate: (d) {
        if (state is! GameButtonStart || state is! GameGridUpdate) {
          if (grid.direction != Direction.left && d.delta.dx > 0) {
            grid.direction = Direction.right;
          } else if (grid.direction != Direction.right && d.delta.dx < 0) {
            grid.direction = Direction.left;
          }
        }
      },
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(1),
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: grid.width,
        ),
        itemCount: grid.width * grid.height,
        itemBuilder: (context, index) {
          if (index == grid.food) {
            return _buildCell(Colors.green);
          } else if (grid.tiles.contains(index)) {
            return _buildCell(Colors.white54);
          }

          return _buildCell(Colors.white24);
        },
      ),
    );
  }

  Container _buildCell(Color color) {
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildPauseScreen() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Center(
          child: Text(
            'P A U S E',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'В Ы  П Р О И Г Р А Л И !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'S C O R E: ${context.cubit<Snake>().grid.score}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
