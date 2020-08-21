import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/presentation/util/input_convertor.dart';

void main() {
  InputConverter convertor;

  setUp(() {
    convertor = InputConverter();
  });

  
  test('.stringToUnsignedInteger returns unsiged integer', () {
    
    // act
    final result = convertor.stringToUnsignedInteger('2');

    // assert
    expect(result, Right<InvalidInputFailure, int>(2));
  });

  test('.stringToUnsignedInteger returns InvalidInputFailure when input is not integer', () {
    
    // act
    final result = convertor.stringToUnsignedInteger('abs');

    // assert
    expect(result, Left<InvalidInputFailure, int>(InvalidInputFailure()));
  });

  test('.stringToUnsignedInteger should return a failure when the string is a negative integer', () {
    // act
    final result = convertor.stringToUnsignedInteger('-1');

    // assert
    expect(result, Left<InvalidInputFailure, int>(InvalidInputFailure()));
  });
}