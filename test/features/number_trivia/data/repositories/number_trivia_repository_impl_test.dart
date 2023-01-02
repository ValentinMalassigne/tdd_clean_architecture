import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'number_trivia_repository_impl_test.mocks.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

@GenerateMocks([MockRemoteDataSource, MockLocalDataSource, MockNetworkInfo])
void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockMockRemoteDataSource mockRemoteDataSource;
  late MockMockLocalDataSource mockLocalDataSource;
  late MockMockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockMockRemoteDataSource();
    mockLocalDataSource = MockMockLocalDataSource();
    mockNetworkInfo = MockMockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestOnline(Function body) {
    group("device is online", () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestOffline(Function body) {
    group("device is offline", () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group("getConcreteNumberTrivia", () {
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: "Test trivia");
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test(
      'should check if the device is online',
      () async {
        //arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        //needed to add this line compared to the tutorial to avoid a missing stub error
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockNetworkInfo.isConnected);
      },
    );
    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          //arrange
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          //it is not necessary to write equals, but it can help making the code clearer
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          //arrange
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          //arrange
          when(mockRemoteDataSource.getConcreteNumberTrivia(any))
              .thenThrow(ServerException());
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          //arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          //arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group("getRandomNumberTrivia", () {
    const tNumberTriviaModel =
        NumberTriviaModel(number: 123, text: "Test trivia");
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test(
      'should check if the device is online',
      () async {
        //arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        //need to add the following lines compared to the tutorial to avoid a missing stub error
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        await repository.getRandomNumberTrivia();
        //assert
        verify(mockNetworkInfo.isConnected);
      },
    );
    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          //arrange
          when(mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          //it is not necessary to write equals, but it can help making the code clearer
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          //arrange
          when(mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          await repository.getRandomNumberTrivia();
          //assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          //arrange
          when(mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verify(mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          //arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          //arrange
          when(mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
