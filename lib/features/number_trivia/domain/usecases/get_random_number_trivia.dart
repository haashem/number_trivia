
import 'package:dartz/dartz.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

import '../entities/number_trivia.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../features/number_trivia/domain/repositories/number_trivia_repository.dart';


class GetRandomNumberTrivia extends UseCase<NumberTrivia, Params> {
   final NumberTriviaRepository repository;
  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call({Params params}) async {
    
    return await repository.getRandomNumberTrivia();
  }
  
}