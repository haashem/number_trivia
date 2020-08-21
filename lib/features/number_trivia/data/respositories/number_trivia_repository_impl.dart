import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/platform/network_info.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../datasources/number_trivia_local_data_source.dart';
import '../datasources/number_trivia_remote_data_source.dart';

typedef Future<NumberTriviaModel> _ConcreteOrRandomChooser();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl(
      {@required this.remoteDataSource,
      @required this.localDataSource,
      @required this.networkInfo});

  Future<Either<Failure, NumberTrivia>> _getTrivia(_ConcreteOrRandomChooser getConcreteOrRandom) async {
    if (await networkInfo.isConnected) {
      try {
        final numberTrivia =
            await getConcreteOrRandom();
        // cache number
        localDataSource.cacheNumberTrivia(numberTrivia);
        return Right(mapToNumberTrivia(numberTrivia));
      } on ServerException {
        return Left(ServerFailure());
      }
    }
    {
      try {
        final numberTrivia = await localDataSource.getLastNumberTrivia();
        // cache number
        return Right(mapToNumberTrivia(numberTrivia));
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) {
    return _getTrivia(() => remoteDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return _getTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }

  NumberTrivia mapToNumberTrivia(NumberTriviaModel model) {
    return NumberTrivia(number: model.number, text: model.text);
  }
}
