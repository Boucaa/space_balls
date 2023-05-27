import 'package:flame/game.dart';
import 'package:space_balls/model/game_level.dart';
import 'package:space_balls/model/kerr_hole.dart';
import 'package:space_balls/model/newton_object.dart';
import 'package:space_balls/model/player_ball.dart';
import 'package:space_balls/model/schwarzschild_hole.dart';
import 'package:space_balls/model/target.dart';
import 'package:space_balls/model/wall.dart';

class LevelRepository {
  GameLevel getLevel(int levelId) {
    switch (levelId) {
      case 0:
        return GameLevel(
          name: 'tutorial',
          description: 'lorem ipsum',
          gameObjects: [
            PlayerBall(
              mass: 1,
              initialVelocity: Vector2(-1, 0),
              initialPosition: Vector2(2, 4),
            ),
            Target(
              initialPosition: Vector2(2.5, 1),
            ),
            NewtonObject(
              initialPosition: Vector2(1, 4.5),
              mass: 1,
            ),
            WallLine(
              Vector2(1.5, 1.5),
              Vector2(2.0, 2.0),
              isContactGameOver: false,
            ),
            WallLine(
              Vector2(1.0, 1.5),
              Vector2(1.5, 2.0),
              isContactGameOver: true,
            ),
          ],
        );
      case 1:
        return GameLevel(
          name: 'newtonian object',
          description: 'lorem ipsum',
          gameObjects: [
            PlayerBall(
              mass: 1,
              initialVelocity: Vector2(-1, 0),
              initialPosition: Vector2(1.5, 4.8),
            ),
            Target(
              initialPosition: Vector2(1.5, 0.8),
            ),
            NewtonObject(
              initialPosition: Vector2(1.5, 3),
              mass: 2,
            ),
          ],
        );
      case 2:
        return GameLevel(
          name: 'sun with a planet',
          description: 'lorem ipsum',
          gameObjects: [
            PlayerBall(
              mass: 1,
              initialVelocity: Vector2(-1, 0),
              initialPosition: Vector2(1.5, 4.8),
            ),
            Target(
              initialPosition: Vector2(1.5, 0.8),
            ),
            NewtonObject(
              initialPosition: Vector2(1, 3),
              mass: 1.5,
            ),
            NewtonObject(
              initialPosition: Vector2(2, 3),
              mass: 0.5,
              isStatic: false,
              initialVelocity: Vector2(0, -1),
            ),
          ],
        );
      case 3:
        return GameLevel(
          name: 'schwardschild black hole',
          description: 'lorem ipsum',
          gameObjects: [
            PlayerBall(
              mass: 1,
              initialVelocity: Vector2(-1, 0),
              initialPosition: Vector2(1.5, 4.8),
            ),
            Target(
              initialPosition: Vector2(1.5, 0.8),
            ),
            SchwardschildHole(
              initialPosition: Vector2(1.5, 3),
              mass: 1.5,
            ),
          ],
        );
      case 4:
        return GameLevel(
          name: 'kerr black hole',
          description: 'lorem ipsum',
          gameObjects: [
            PlayerBall(
              mass: 1,
              initialVelocity: Vector2(-1, 0),
              initialPosition: Vector2(1.5, 4.8),
            ),
            Target(
              initialPosition: Vector2(1.5, 0.8),
            ),
            KerrHole(
              initialPosition: Vector2(1.5, 3),
              mass: 1.5,
              spin: 1,
              drag: 3,
            ),
          ],
        );
      default:
        throw Exception('Unknown level id: $levelId');
    }
  }
}
