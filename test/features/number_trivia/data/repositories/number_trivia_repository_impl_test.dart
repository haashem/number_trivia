import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/core/error/failure.dart';

import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/respositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;
  final tNumber = 1;
  final tNumberTriviaModel =
      NumberTriviaModel(number: tNumber, text: 'test trivia');
  final NumberTrivia tNumberTrivia =
      NumberTrivia(number: tNumber, text: 'test trivia');

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getConcreteNumberTrivia', () {
    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected)
          .thenAnswer((realInvocation) async => true);
      when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
          .thenAnswer((realInvocation) async => tNumberTriviaModel);
      // act
      await repository.getConcreteNumberTrivia(tNumber);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('when device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected)
            .thenAnswer((realInvocation) async => true);
      });

      test(
          'should return remote data when call to remote data source is successful',
          () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right<Failure, NumberTrivia>(tNumberTrivia)));
      });

      test(
          'should cache data locally when call to remote data source is successful',
          () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return server failure when call to remote data source is unsuccessful',
          () async {
        // arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
            .thenThrow(ServerException());

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Left<Failure, NumberTrivia>(ServerFailure())));
        verifyZeroInteractions(mockLocalDataSource);
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return last locally cached data when data is presnet',
          () async {
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right<Failure, NumberTrivia>(tNumberTrivia)));
      });

      test('should throw cache error when data is not in the cache', () async {
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left<Failure, NumberTrivia>(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    test('should check if the device is online', () async {
      when(mockNetworkInfo.isConnected)
          .thenAnswer((realInvocation) async => true);
      when(mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((realInvocation) async => tNumberTriviaModel);
      // act
      await repository.getRandomNumberTrivia();

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected)
            .thenAnswer((realInvocation) async => true);
      });

      test('should return random number trivia from remote data source',
          () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(Right<Failure, NumberTrivia>(tNumberTrivia)));
      });

      test(
          'should cache data locally when call to remote data source is successfull',
          () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should throw server failure when call to remote data source is not successfull', () async {
        // arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(Left<Failure, NumberTrivia>(ServerFailure())));
        verifyZeroInteractions(mockLocalDataSource);
      });
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected)
            .thenAnswer((realInvocation) async => false);
      });

      test('should return last locally cached data when data is presnet',
          () async {
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right<Failure, NumberTrivia>(tNumberTrivia)));
      });

      test('should throw cache error when data is not in the cache', () async {
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        // act
        final result = await repository.getRandomNumberTrivia();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left<Failure, NumberTrivia>(CacheFailure())));
      });
    });
  });
}
