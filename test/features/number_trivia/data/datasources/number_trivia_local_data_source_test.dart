import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPrefrences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPrefrences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPrefrences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  tearDown(() async {
    await mockSharedPreferences.clear();
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
        json.decode(fixture('trivia_cached.json')) as Map<String, Object>);

    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any))
            .thenReturn(fixture('trivia_cached.json'));
        // act
        final result = await dataSource.getLastNumberTrivia();
        // assert
        verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test('should throw a cache excpetion when there is not a cache value', () async {
      // arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      // act
      final call = dataSource.getLastNumberTrivia;

      // assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });

  test('cacheNumberTrivia should cache number trivia', () {
    // arrange
    final triviaNumber = NumberTriviaModel(text: 'text', number: 1);
    // act
    dataSource.cacheNumberTrivia(triviaNumber);

    // assert
    verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, json.encode(triviaNumber.toJson())));
  });
}
