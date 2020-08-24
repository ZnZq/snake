import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:snake/game/snake.dart';
import 'package:snake/game_page.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SafeArea(
        child: CubitProvider(
          create: (_) => Snake(),
          child: GamePage(),
        ),
      ),
    );
  }
}
