import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:space_balls/model/game_level.dart';
import 'package:space_balls/model/player_ball.dart';

final _log = Logger('SpaceBallsGame');

class SpaceBallsGame extends Forge2DGame {
  var frameCount = 0;
  final GameLevel level;

  SpaceBallsGame({
    required this.level,
  }) : super(
          gravity: Vector2(0, 0),
          zoom: 100,
          contactListener: TestContactListener(
            onPlayerContact: () {
              _log.info('Player contact');
            },
          ),
        );

  @override
  Future<void> onLoad() async {
    addAll(level.gameObjects);
    addAll(createBoundaries());

    return super.onLoad();
  }

  List<Component> createBoundaries() {
    final topLeft = Vector2.zero();
    final bottomRight = screenToWorld(camera.viewport.effectiveSize);
    final topRight = Vector2(bottomRight.x, topLeft.y);
    final bottomLeft = Vector2(topLeft.x, bottomRight.y);

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft)
    ];
  }

  @override
  void update(double dt) {
    frameCount++;
    // _log.fine('frame $frameCount with dt $dt');
    final objects = level.gameObjects;
    dt = 0.016;

    for (var i = 0; i < objects.length; i++) {
      if (objects[i].isStatic) {
        // newObjects.add(objects[i]);
        continue;
      }
      var acceleration = Vector2.zero();
      Vector2 calcAcceleration(Vector2 testPosition) {
        for (var j = 0; j < objects.length; j++) {
          if (i == j) {
            continue;
          }

          final objectA = objects[i];
          // TODO this is necessary fro the kX calculation
          // .withFakePosition(testPosition);
          final objectB = objects[j];

          final interaction = objectB.calculateInteraction(objectA);
          acceleration += interaction;
        }
        return acceleration;
      }

      // Calculate the k1 values
      final k1Velocity = calcAcceleration(objects[i].position) * dt;
      final k1Position = objects[i].velocity * dt;

      // Calculate the k2 values
      // final k2Velocity =
      //     calcAcceleration(objects[i].position + k1Position * 0.5) * dt;
      // final k2Position = (objects[i].velocity + k1Velocity * 0.5) * dt;
      //
      // // Calculate the k3 values
      // final k3Velocity =
      //     calcAcceleration(objects[i].position + k2Position * 0.5) * dt;
      // final k3Position = (objects[i].velocity + k2Velocity * 0.5) * dt;
      //
      // // Calculate the k4 values
      // final k4Velocity =
      //     calcAcceleration(objects[i].position + k3Position) * dt;
      // final k4Position = (objects[i].velocity + k3Velocity) * dt;

      // Update the velocity and position
      // final newVelocity = objects[i].velocity +
      //     (k1Velocity + k2Velocity * 2 + k3Velocity * 2 + k4Velocity) * (1 / 6);
      // final newPosition = objects[i].position +
      //     (k1Position + k2Position * 2 + k3Position * 2 + k4Position) * (1 / 6);

      // final newVelocity =
      //     objects[i].velocity + acceleration * (16000 * 0.000001);

      // final newObject = objects[i].copyWith(
      //   velocity: newVelocity,
      //   position: newPosition,//objects[i].position + newVelocity * (16000*0.000001),
      // );
      // _log.fine(
      //   'update object ${objects[i].runtimeType} with velocity: ${objects[i].velocity} and newVelocity: $newVelocity',
      // );
      final newVelocity = objects[i].velocity + k1Velocity;
      objects[i].body.linearVelocity = newVelocity;
      // _log.fine('k1: $k1Velocity');
      // _log.fine(
      //   'update object ${objects[i].runtimeType} velocity is now: ${objects[i].body.linearVelocity}',
      // );
    }

    super.update(dt);
  }
}

class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      userData: this,
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class TestContactListener extends ContactListener {
  final VoidCallback onPlayerContact;

  TestContactListener({
    required this.onPlayerContact,
  });

  @override
  void beginContact(Contact contact) {
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;

    final bodyA = fixtureA.body;
    final bodyB = fixtureB.body;

    final objectA = bodyA.userData;
    final objectB = bodyB.userData;

    if (objectA is PlayerBall || objectB is PlayerBall) {
      onPlayerContact();
    }
  }

  @override
  void endContact(Contact contact) {}

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {}

  @override
  void preSolve(Contact contact, Manifold oldManifold) {}
}
