
import 'dart:convert';

import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meta/meta.dart';

import '../models/number_trivia_model.dart';

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

abstract class NumberTriviaLocalDataSource {

  Future<NumberTriviaModel> getLastNumberTrivia();
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

class NumberTriviaLocalDataSourceImpl extends NumberTriviaLocalDataSource {

  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({@required this.sharedPreferences});


  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) async {
    return await sharedPreferences.setString(CACHED_NUMBER_TRIVIA, json.encode(triviaToCache.toJson()));
  }

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPreferences.getString(CACHED_NUMBER_TRIVIA);
    
    if (jsonString != null) {
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString) as Map<String, Object>));
    } else {
      throw CacheException();
    }
  }

}