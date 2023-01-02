import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/usecases/usecase.dart';
import 'package:tdd_clean_architecture/core/utils/input_converter.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

@GenerateMocks([
  MockGetConcreteNumberTrivia,
  MockGetRandomNumberTrivia,
  MockInputConverter
])
void main() {
  late NumberTriviaBloc bloc;
  late MockMockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockMockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockMockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockMockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockMockGetRandomNumberTrivia();
    mockInputConverter = MockMockInputConverter();

    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test("initialState should be Empty", () {
    //assert
    expect(bloc.state, equals(NumberTriviaState.empty()));
  });

  group("GetTriviaForConcreteNumber", () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(const Right(tNumberParsed));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        //arrange
        setUpMockInputConverterSuccess();
        //needed to add this line compared to the tutorial to avoid a missing stub error
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //act
        bloc.add(const GetTriviaForConcreteNumberEvent(tNumberString));
        //because blocs work with streams we need to await for the function to be called before continuing the test
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
        //assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      'should emit [Error] when the input is invalid',
      () async* {
        //arrange
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        //in this case we assert before acting because the bloc.add call could finish faster than we arrive at the assert part and that would fail the expectLater test
        //assert
        final expected = [
          NumberTriviaState.empty(),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.error,
            errorMessage: INVALID_INPUT_FAILURE_MESSAGE,
          ),
        ];
        expectLater(
          bloc.state,
          emitsInOrder(expected),
        );
        //act
        bloc.add(const GetTriviaForConcreteNumberEvent(tNumberString));
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        //arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //act
        bloc.add(const GetTriviaForConcreteNumberEvent(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia(any));
        //assert
        verify(
          mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)),
        );
      },
    );
    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async* {
        //arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //assert
        final expected = [
          NumberTriviaState.empty(),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loading,
          ),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loaded,
            trivia: tNumberTrivia,
          ),
        ];
        expect(bloc.state, emitsInOrder(expected));
        //act
        bloc.add(const GetTriviaForConcreteNumberEvent(tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when data is not gotten successfully',
      () async* {
        //arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        //assert
        final expected = [
          NumberTriviaState.empty(),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loading,
          ),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.error,
            errorMessage: SERVER_FAILURE_MESSAGE,
          ),
        ];
        expect(bloc.state, emitsInOrder(expected));
        //act
        bloc.add(const GetTriviaForConcreteNumberEvent(tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when data is not gotten successfully',
      () async* {
        //arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        //assert
        final expected = [
          NumberTriviaState.empty(),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loading,
          ),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.error,
            errorMessage: CACHE_FAILURE_MESSAGE,
          ),
        ];
        expect(bloc.state, emitsInOrder(expected));
        //act
        bloc.add(const GetTriviaForConcreteNumberEvent(tNumberString));
      },
    );
  });

  group("GetTriviaForRandomNumber", () {
    const tNumberTrivia = NumberTrivia(number: 1, text: "test trivia");

    test(
      'should get data from the random use case',
      () async* {
        //arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //act
        bloc.add(GetTriviaForRandomNumberEvent());
        await untilCalled(mockGetRandomNumberTrivia(any));
        //assert
        verify(
          mockGetRandomNumberTrivia(NoParams()),
        );
      },
    );
    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async* {
        //arrange

        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //assert
        final expected = [
          NumberTriviaState.empty(),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loading,
          ),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loaded,
            trivia: tNumberTrivia,
          ),
        ];
        expect(bloc.state, emitsInOrder(expected));
        //act
        bloc.add(GetTriviaForRandomNumberEvent());
      },
    );

    test(
      'should emit [Loading, Error] when data is not gotten successfully',
      () async* {
        //arrange

        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        //assert
        final expected = [
          NumberTriviaState.empty(),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loading,
          ),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.error,
            errorMessage: SERVER_FAILURE_MESSAGE,
          ),
        ];
        expect(bloc.state, emitsInOrder(expected));
        //act
        bloc.add(GetTriviaForRandomNumberEvent());
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when data is not gotten successfully',
      () async* {
        //arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        //assert
        final expected = [
          NumberTriviaState.empty(),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.loading,
          ),
          const NumberTriviaState(
            numberTriviaStatus: NumberTriviaStatus.error,
            errorMessage: CACHE_FAILURE_MESSAGE,
          ),
        ];
        expect(bloc.state, emitsInOrder(expected));
        //act
        bloc.add(GetTriviaForRandomNumberEvent());
      },
    );
  });
}
