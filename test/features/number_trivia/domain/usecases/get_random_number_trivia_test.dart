import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  MockNumberTriviaRepository mockNumberRepository;
  GetRandomNumberTrivia usecase;

  setUp(() {
    mockNumberRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberRepository);
  });

  final tNumberTrivia = NumberTrivia(number: 1, text: 'test');

  test(
      'GetRandomNumberTrivia should return random number trivia from repository ',
      () async {
    when(mockNumberRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(tNumberTrivia));

    final result = await usecase();

    expect(result, Right<Failure, NumberTrivia>(tNumberTrivia));

    verify(mockNumberRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockNumberRepository);
  });
}
