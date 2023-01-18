// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd_clean_architecture/core/usecases/usecase.dart';

import 'package:tdd_clean_architecture/core/utils/input_converter.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = "Server Failure";
const String CACHE_FAILURE_MESSAGE = "Cache Failure";
const String INVALID_INPUT_FAILURE_MESSAGE =
    "Invalid Input - The number must be a positive integer or zero.";

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(NumberTriviaState.empty()) {
    on<GetTriviaForConcreteNumberEvent>((event, emit) async {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);
      await inputEither.fold(
        (failure) {
          emit(state.copyWith(
              numberTriviaStatus: NumberTriviaStatus.error,
              errorMessage: INVALID_INPUT_FAILURE_MESSAGE));
        },
        (integer) async {
          emit(state.copyWith(numberTriviaStatus: NumberTriviaStatus.loading));
          final failureOrTrivia =
              await getConcreteNumberTrivia(Params(number: integer));
          _eitherLoadedOrErrorState(failureOrTrivia, emit);
        },
      );
    });

    on<GetTriviaForRandomNumberEvent>((event, emit) async {
      emit(state.copyWith(numberTriviaStatus: NumberTriviaStatus.loading));
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());

      _eitherLoadedOrErrorState(failureOrTrivia, emit);
    });
  }

  void _eitherLoadedOrErrorState(
      Either<Failure, NumberTrivia> failureOrTrivia, emit) {
    failureOrTrivia.fold(
      (failure) => emit(state.copyWith(
        numberTriviaStatus: NumberTriviaStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (trivia) => emit(state.copyWith(
        numberTriviaStatus: NumberTriviaStatus.loaded,
        trivia: trivia,
      )),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;

      default:
        return 'Unexpected error';
    }
  }
}
