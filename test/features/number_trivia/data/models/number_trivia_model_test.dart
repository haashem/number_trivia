import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';


void main() {
  
  final tNumberTriviaModel = NumberTriviaModel(text: 'Test Text', number: 1);

  group('from json', (){

    test('should return a valid model when JSON number is regarded as int', () {
      // arrange
      final Map<String, Object> jsonMap = json.decode(fixture('trivia.json')) as Map<String, Object>;

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);
      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should return a valid model when JSON number is regarded as double', () {
      // arrange
      final Map<String, Object> jsonMap = json.decode(fixture('trivia_double.json')) as Map<String, Object>;

      // act
      final result = NumberTriviaModel.fromJson(jsonMap);
      // assert
      expect(result, tNumberTriviaModel);
    });
  });  

  group('toJson', () {
      test('should contain a JSON map containing the proper data', () {
        // arrange
        
        // act
        final result = tNumberTriviaModel.toJson();

        // assert
        final expectedJsonMap = {
          'text': 'Test Text',
          'number': 1
        };
        expect(result, expectedJsonMap);
      });
    });
  
}