part of 'number_trivia_bloc.dart';

enum NumberTriviaStatus {
  empty,
  loading,
  loaded,
  error,
}

class NumberTriviaState extends Equatable {
  final NumberTriviaStatus numberTriviaStatus;
  final NumberTrivia? trivia;
  final String? errorMessage;
  const NumberTriviaState({
    required this.numberTriviaStatus,
    this.trivia,
    this.errorMessage,
  });

  factory NumberTriviaState.empty() {
    return const NumberTriviaState(
      numberTriviaStatus: NumberTriviaStatus.empty,
    );
  }

  @override
  List<Object?> get props => [numberTriviaStatus, trivia, errorMessage];

  @override
  bool get stringify => true;

  NumberTriviaState copyWith({
    NumberTriviaStatus? numberTriviaStatus,
    NumberTrivia? trivia,
    String? errorMessage,
  }) {
    return NumberTriviaState(
      numberTriviaStatus: numberTriviaStatus ?? this.numberTriviaStatus,
      trivia: trivia ?? this.trivia,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
