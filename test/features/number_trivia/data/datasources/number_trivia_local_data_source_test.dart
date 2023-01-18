import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture/core/error/exceptions.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../core/fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

class TestSharedPreferences extends Mock implements SharedPreferences {}

@GenerateMocks([TestSharedPreferences])
void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockTestSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockTestSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group("getLastNumberTrivia", () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture("trivia_cached.json")));
    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        //arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture("trivia_cached.json"));
        //act
        final result = await dataSource.getLastNumberTrivia();
        //assert
        verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a CacheException when there is not a cached value',
      () async {
        //arrange
        when(mockSharedPreferences.getString(any)).thenReturn(null);
        //act
        final call = dataSource.getLastNumberTrivia;
        //assert
        expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
      },
    );
  });

  group("cacheNumberTrivia", () {
    const tNumberTriviaModel =
        NumberTriviaModel(text: "test trivia", number: 1);
    test(
      'should call SharedPreferences to cache the data',
      () async {
        //arange
        //needed to add this line compared to the tutorial to avoid a missing stub error
        when(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, any))
            .thenAnswer((_) async => true);
        //act
        dataSource.cacheNumberTrivia(tNumberTriviaModel);
        //assert
        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
        verify(mockSharedPreferences.setString(
            CACHED_NUMBER_TRIVIA, expectedJsonString));
      },
    );
  });
}
