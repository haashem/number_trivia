import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  MockHttpClient mockHttpClient;
  NumberTriviaRemoteDataSource dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });
  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response(fixture('trivia.json'), 200),
    );
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response('Something went wrong', 404),
    );
  }

  group('getConcreteNumberTrivia', () {
    final number = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
        json.decode(fixture('trivia.json')) as Map<String, Object>);
    test(
        'should perfrom a GET request on a URL with number being endpoint and with application/json header',
        () {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      dataSource.getConcreteNumberTrivia(number);

      // assert
      verify(mockHttpClient.get('http://numbersapi.com/$number',
          headers: {'Content-Type': 'application/json'}));
    });

    test(
        'should return NumberTriviaModel when the response code is 200 (success)',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      final result = await dataSource.getConcreteNumberTrivia(number);

      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the response code is not 200',
        () async {
      setUpMockHttpClientFailure404();
      when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (realInvocation) async => http.Response('Something went wrong', 404));
      // act
      final call = dataSource.getConcreteNumberTrivia;

      expect(call(number), throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(
        json.decode(fixture('trivia.json')) as Map<String, Object>);
    test(
        'should perfrom a GET request on a URL with random being endpoint and with application/json header',
        () {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      dataSource.getRandomNumberTrivia();

      // assert
      verify(mockHttpClient.get('http://numbersapi.com/random',
          headers: {'Content-Type': 'application/json'}));
    });

    test(
        'should return NumberTriviaModel when the response code is 200 (success)',
        () async {
      // arrange
      setUpMockHttpClientSuccess200();

      // act
      final result = await dataSource.getRandomNumberTrivia();

      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the response code is not 200',
        () async {
      setUpMockHttpClientFailure404();
      when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (realInvocation) async => http.Response('Something went wrong', 404));
      // act
      final call = dataSource.getRandomNumberTrivia;

      expect(call(), throwsA(isA<ServerException>()));
    });
  });
}
