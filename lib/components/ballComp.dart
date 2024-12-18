import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/rendering.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:game/melongame.dart';
import 'package:flame_audio/flame_audio.dart';

enum ObjectState {
  normal,
  combined,
}

class Ball extends BodyComponent with ContactCallbacks {
  // define ball state as normal
  ObjectState state = ObjectState.normal;
  
  // define init position, init level, sprite and the game object
  final Vector2 initialPosition;
  int level;
  @override
  final MyGame game;
  late final SpriteComponent spriteComponent;

  final effect = ScaleEffect.by(
    Vector2.all(1.4),
    EffectController(duration: 0.2),
  );

  Ball({required this.initialPosition, required this.level, required this.game}){
    priority = 0;
  }

  // load assets
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // create and config of the sprite
    spriteComponent = SpriteComponent(
      sprite: game.ballSprites[level]!,
      size: _ballSize(level),
      anchor: Anchor.center,
    );

    add(spriteComponent);
    spriteComponent.add(effect);
  }

  // create body
  @override 
  Body createBody(){
    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.dynamic,
    );
    final shape = CircleShape()..radius = _ballRadius(level);
    final fixtureDef = FixtureDef(shape)
      ..density = 10
      ..friction = 0.9
      ..restitution = 0.3;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
  
  @override
  void update(double dt) {
    super.update(dt);

    if (state == ObjectState.combined) {
      removeFromParent();
    }

    if (canCombine){
      _checkNearbyBallsForCombination();
    }
    
  }


  // |||||||| CONTACT AND LEVELLING BALLS ||||||||

    bool canCombine = true;
    final double combineCooldown = 0.5;


    void _checkNearbyBallsForCombination() {
      for (final contact in body.contacts) {
        final other = contact.getOtherBody(body).userData;
        if (other is Ball &&
            state == ObjectState.normal &&
            other.state == ObjectState.normal &&
            other.level == level) {
          _combineWith(other);
          canCombine = false;
          Future.delayed(Duration(milliseconds: (combineCooldown * 1000).toInt()), () {
            canCombine = true;
          });
        }
      }
    }


    void _combineWith(Ball other) {
      if(level != 10){
        level++;
        _updateSpriteAndSize();
        game.updateScore(level);
        FlameAudio.play('pop.mp3');

        other.state = ObjectState.combined;
        other.removeFromParent();
      }
      else {
        game.magicBallCount++;

        game.triggerWin();

        other.state = ObjectState.combined;
        other.removeFromParent();
        state = ObjectState.combined;
        removeFromParent();

        FlameAudio.play('pop.mp3');
      }
    }

    void _updateSpriteAndSize() {
    // update sprite
    spriteComponent.sprite = game.ballSprites[level]!;
    spriteComponent.size = _ballSize(level);

    // update body and fixtures
    _updateFixtureSize();
  }


  void _updateFixtureSize() {
    final newRadius = _ballRadius(level);
    final shape = CircleShape()..radius = newRadius;

    // update the fixtures
    final fixture = body.fixtures.first;
    fixture.shape = shape;
    body.resetMassData(); // recalculate and reset the mass and other properties after updating the fixtures
  }

  double _ballRadius(int level) {
    return 0.2 + (level * 0.2);
  }

  Vector2 _ballSize(int level) {
    final radius = _ballRadius(level);
    return Vector2.all(radius * 1.8);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ball &&
        state == ObjectState.normal &&
        other.state == ObjectState.normal &&
        other.level == level) {
      _combineWith(other);
    }
  }

}