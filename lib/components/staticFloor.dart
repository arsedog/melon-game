import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart';
import 'package:game/melongame.dart';

class FloorStatic extends BodyComponent {
  @override
  Body createBody() {

    final bodyDef = BodyDef(
      position: Vector2(0, worldSize.y),
      type: BodyType.static,
    );

    final shape = EdgeShape()..set(Vector2.zero(), Vector2(worldSize.x, 0));
    final fixtureDef = FixtureDef(shape)..friction = .1;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}