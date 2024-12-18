import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game/components/gameOver.dart';
import 'package:game/components/gameWin.dart';
import 'package:game/melongame.dart';

void main() {
  runApp(GameWidget.controlled(gameFactory: MyGame.new,
        overlayBuilderMap: {
        'GameOver': (_, game) => GameOver(game: MyGame()),
        'GameWin': (_, game) => GameWin(game: MyGame()),
      },),);
}

