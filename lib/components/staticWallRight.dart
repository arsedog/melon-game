import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game/melongame.dart';

class WallStaticRight extends BodyComponent {
  @override
  Body createBody() {

    final bodyDef = BodyDef(
      position: Vector2(worldSize.x, 0),
      type: BodyType.static,
    );

    final shape = EdgeShape()..set(Vector2.zero(), Vector2(0, worldSize.y));
    final fixtureDef = FixtureDef(shape)..friction = .1;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}