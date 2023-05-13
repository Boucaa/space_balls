import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:logging/logging.dart';
import 'package:space_balls/model/game_object.dart';
import 'package:space_balls/model/newton_object.dart';
import 'package:space_balls/model/player_ball.dart';

class SpaceBallsGame extends Forge2DGame {
  final _log = Logger('SpaceBallsGame');

  SpaceBallsGame()
      : super(
          gravity: Vector2(0, 0),
          zoom: 1.0,
          // world: BodyDef(type: BodyType.static),
        );

  @override
  Future<void> onLoad() async {
    add(
      PlayerBall(
        // position: size / 2,
        mass: 1,
        initialVelocity: Vector2(-10000, 1000),
        initialPosition: size / 2,
        // velocity: Vector2.zero(),
      ),
    );
    add(
      NewtonObject(
        initialPosition: size / 3,
        // velocity: Vector2.zero(),
        mass: 700000,
      ),
    );
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
    final objects = children.whereType<GameObject>().toList();
    dt = 16 / 1000;
    // _log.fine(
    //   'update with objects: ${objects.length} objects, dt: ${dt.toStringAsFixed(3)}',
    // );

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

          final objectA = objects[i].withFakePosition(testPosition);
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
      final k2Velocity =
          calcAcceleration(objects[i].position + k1Position * 0.5) * dt;
      final k2Position = (objects[i].velocity + k1Velocity * 0.5) * dt;

      // Calculate the k3 values
      final k3Velocity =
          calcAcceleration(objects[i].position + k2Position * 0.5) * dt;
      final k3Position = (objects[i].velocity + k2Velocity * 0.5) * dt;

      // Calculate the k4 values
      final k4Velocity =
          calcAcceleration(objects[i].position + k3Position) * dt;
      final k4Position = (objects[i].velocity + k3Velocity) * dt;

      // Update the velocity and position
      final newVelocity = objects[i].velocity +
          (k1Velocity + k2Velocity * 2 + k3Velocity * 2 + k4Velocity) * (1 / 6);
      final newPosition = objects[i].position +
          (k1Position + k2Position * 2 + k3Position * 2 + k4Position) * (1 / 6);

      // final newVelocity =
      //     objects[i].velocity + acceleration * (16000 * 0.000001);

      // final newObject = objects[i].copyWith(
      //   velocity: newVelocity,
      //   position: newPosition,//objects[i].position + newVelocity * (16000*0.000001),
      // );
      // _log.fine(
      //   'update object ${objects[i].runtimeType} with velocity: ${objects[i].velocity} and newVelocity: $newVelocity',
      // );
      objects[i].body.linearVelocity = newVelocity;
      // _log.fine(
      //   'update object ${objects[i].runtimeType} velocity is now: ${objects[i].body.linearVelocity}',
      // );
      // newObjects.add(newObject);
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