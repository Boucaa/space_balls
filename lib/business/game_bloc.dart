import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:space_balls/model/game_object.dart';
import 'package:space_balls/model/player_ball.dart';
import 'package:vector_math/vector_math_64.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? tickTimer;

  GameBloc()
      : super(
          GameState(
            objects: [
              // PlayerBall(
              //   position: Vector2(0, 0),
              //   velocity: Vector2(0, 0),
              //   mass: 1,
              // ),
              PlayerBall(
                position: Vector2(200, 300),
                velocity: Vector2(0, 0),
                mass: 1,
              )
            ],
          ),
        ) {
    on<Start>((event, emit) {
      tickTimer?.cancel();
      tickTimer = Timer.periodic(
        const Duration(milliseconds: 16),
        (timer) => add(Tick()),
      );
      emit(state.copyWith(isRunning: true));
    });
    on<Stop>((event, emit) {
      tickTimer?.cancel();
      emit(state.copyWith(isRunning: false));
    });
    on<Tick>((event, emit) {
      final objects = state.objects;
      final newObjects = <GameObject>[];
      for (var i = 0; i < objects.length; i++) {
        if (objects[i].isStatic) {
          newObjects.add(objects[i]);
          continue;
        }
        var acceleration = Vector2.zero();
        for (var j = 0; j < objects.length; j++) {
          if (i == j) {
            continue;
          }
          final objectA = objects[i];
          final objectB = objects[j];
          final interaction = objectA.calculateInteraction(objectB);
          acceleration += interaction;
        }
        final newVelocity = objects[i].velocity + acceleration;
        final newObject = objects[i].copyWith(
          velocity: newVelocity,
          position: objects[i].position + newVelocity,
        );
        newObjects.add(newObject);
      }
      emit(state.copyWith(objects: newObjects));
    });
    on<StartPreview>((event, emit) {
      emit(state.copyWith(previewStart: () => event.offset));
    });
    on<PreviewShot>((event, emit) {
      emit(state.copyWith(previewOffset: () => event.offset));
    });
    on<Shoot>((event, emit) {
      if (state.previewOffset == null) {
        return;
      }
      final objects = state.objects;
      final newObjects = <GameObject>[];
      for (var i = 0; i < objects.length; i++) {
        if (objects[i] is PlayerBall) {
          final newObject = objects[i].copyWith(
            velocity: Vector2(
              (state.previewStart!.dx - state.previewOffset!.dx) / 100,
              (state.previewStart!.dy - state.previewOffset!.dy) / 100,
            ),
          );
          newObjects.add(newObject);
        } else {
          newObjects.add(objects[i]);
        }
      }
      emit(state.copyWith(
        objects: newObjects,
        previewOffset: () => null,
      ));
    });
  }

  @override
  Future<void> close() {
    tickTimer?.cancel();
    return super.close();
  }
}
