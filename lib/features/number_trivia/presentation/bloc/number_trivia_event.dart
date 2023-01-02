part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();

  @override
  List<Object> get props => [];
}

class GetTriviaForConcreteNumberEvent extends NumberTriviaEvent {
  final String numberString;

  const GetTriviaForConcreteNumberEvent(this.numberString);
}

class GetTriviaForRandomNumberEvent extends NumberTriviaEvent {}
