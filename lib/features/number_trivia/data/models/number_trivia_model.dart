import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../domain/entities/number_trivia.dart';

class NumberTriviaModel extends Equatable {

  final String text;
  final int number;
  NumberTriviaModel({@required this.text, @required this.number});

  factory NumberTriviaModel.fromJson(Map<String, Object> json) {
    return NumberTriviaModel(
      text: json['text'] as String,
      number: (json['number'] as num).toInt(),
    );
  }

  Map<String, Object> toJson() {
    return {'text': text, 'number': number};
  }

  @override
  List<Object> get props => [text, number];
}
