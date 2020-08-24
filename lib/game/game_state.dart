import 'package:equatable/equatable.dart';

class GameState extends Equatable {
  final String state;

  const GameState(this.state);

  @override
  List<Object> get props => [state];

  @override
  String toString() {
    return state;
  }
}

class GameInit extends GameState {
  GameInit() : super('GameInit');
}

class GameLoaded extends GameState {
  GameLoaded() : super('GameLoaded');
}

class GameOver extends GameState {
  GameOver() : super('GameOver');
}

class GameGridUpdate extends GameState {
  static int _update = 0;

  GameGridUpdate() : super('GameGridUpdate');

  @override
  List<Object> get props => [_update++, ...super.props];
}

class GameInformationState extends GameState {
  final int point;
  GameInformationState(this.point, String state) : super(state);

  @override
  List<Object> get props => [point, ...super.props];
}

class GameInformationScore extends GameInformationState {
  GameInformationScore(int point) : super(point ?? 0, 'GameInformationScore');
}

class GameInformationRecord extends GameInformationState {
  GameInformationRecord(int point) : super(point ?? 0, 'GameInformationRecord');
}

class GameButtonState extends GameState {
  GameButtonState(String state) : super(state);
}

class GameButtonStart extends GameButtonState {
  GameButtonStart() : super('GameStart');
}

class GameButtonStop extends GameButtonState {
  GameButtonStop() : super('GameStop');
}

class GameButtonPause extends GameButtonState {
  GameButtonPause() : super('GamePause');
}
