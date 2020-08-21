import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../features/number_trivia/domain/repositories/number_trivia_repository.dart';
import '../entities/number_trivia.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';

class GetConcreteNumberTrivia extends UseCase<NumberTrivia, Params> {
  final NumberTriviaRepository repository;
  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call({Params params}) async {
    return await repository.getConcreteNumberTrivia(params.number);
  }
  
}

class Params extends Equatable {
  final int number;
  Params(this.number);
  @override
  List<Object> get props => [number];
  
}
