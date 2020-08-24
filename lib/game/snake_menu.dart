import 'package:cubit/cubit.dart';
import 'package:snake/game/game_state.dart';

class SnakeMenu extends Cubit<GameState> {
  SnakeMenu() : super(GameInit());
}
