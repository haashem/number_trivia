import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failure.dart';

import 'package:number_trivia/core/presentation/util/input_convertor.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConvertor extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConvertor mockInputConvertor;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConvertor = MockInputConvertor();

    bloc = NumberTriviaBloc(
        inputConverter: mockInputConvertor,
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia);
  });

  test('initialState should be empty', () {
    expect(bloc.initialState, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    final tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() {
      when(mockInputConvertor.stringToUnsignedInteger(tNumberString))
          .thenReturn(Right(tNumberParsed));
    }

    test(
        'should call the InputConvertor to validate and convert string to unsigned integer ',
        () async {
      setUpMockInputConverterSuccess();
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConvertor.stringToUnsignedInteger(any));

      // assert
      verify(mockInputConvertor.stringToUnsignedInteger(tNumberString));
    });

    test(
      'should emit [Error] when the input is invalid',
      () async {
        // arrange
        when(mockInputConvertor.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));

        // assert later
        final expected = [
          // The initial state is always emitted first
          Empty(),
          Error(message: INVALID_INPUT_FAILURE_MESSAGE),
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(params: Params(tNumberParsed)))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
            mockGetConcreteNumberTrivia(params: Params(tNumberParsed)));
        // assert
        verify(mockGetConcreteNumberTrivia(params: Params(tNumberParsed)));
      },
    );
    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
          // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(params: Params(tNumberParsed)))
            .thenAnswer((_) async => Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));

        // assert
        final expectations = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];

        expectLater(bloc, emitsInOrder(expectations));
      },
    );

    test('should emit [Loading, Error] when getting data fails from api', () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(params: Params(tNumberParsed)))
            .thenAnswer((_) async => Left(ServerFailure()));

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      // assert
      final expectations = [Empty(), Loading(), Error(message: SERVER_FAILURE_MESSAGE)];

      expectLater(bloc, emitsInOrder(expectations));
    });

    test('should emit [Loading, Error] when getting data fails from cache', () async {
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(params: Params(tNumberParsed)))
            .thenAnswer((_) async => Left(CacheFailure()));

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      // assert
      final expectations = [Empty(), Loading(), Error(message: CACHE_FAILURE_MESSAGE)];

      expectLater(bloc, emitsInOrder(expectations));
    });
  });

  group('GetTriviaForRandomNumber', () {
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(
            mockGetRandomNumberTrivia());
        // assert
        verify(mockGetRandomNumberTrivia());
      },
    );
    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
          // arrange
        when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForRandomNumber());

        // assert
        final expectations = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];

        expectLater(bloc, emitsInOrder(expectations));
      },
    );

    test('should emit [Loading, Error] when getting data fails from api', () async {
      when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => Left(ServerFailure()));

      // act
      bloc.add(GetTriviaForRandomNumber());

      // assert
      final expectations = [Empty(), Loading(), Error(message: SERVER_FAILURE_MESSAGE)];

      expectLater(bloc, emitsInOrder(expectations));
    });

    test('should emit [Loading, Error] when getting data fails from cache', () async {

      when(mockGetRandomNumberTrivia())
            .thenAnswer((_) async => Left(CacheFailure()));

      // act
      bloc.add(GetTriviaForRandomNumber());

      // assert
      final expectations = [Empty(), Loading(), Error(message: CACHE_FAILURE_MESSAGE)];

      expectLater(bloc, emitsInOrder(expectations));
    });
  });
}
