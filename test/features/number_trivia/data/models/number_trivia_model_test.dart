import 'dart:convert';

import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(
    number: 1,
    text: '1 is one',
  );

  test(
    '''should be a subclass of NumberTrivia entity''',
    () {
      //assert
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    },
  );

  group('fromJson', () {
    test(
      '''should return a valid model when the JSON number
        is an integer''',
      () {
        //arange
        final Map<String, dynamic> jsonMap =
            json.decode(fixtureJson('trivia.json'));
        //act
        final result = NumberTriviaModel.fromJson(jsonMap);
        //assert
        expect(result, tNumberTriviaModel);
      },
    );

    test(
      '''should return a valid model when the JSON number
        is a double''',
      () {
        //arange
        final Map<String, dynamic> jsonMap =
            json.decode(fixtureJson('trivia_double.json'));
        //act
        final result = NumberTriviaModel.fromJson(jsonMap);
        //assert
        expect(result, tNumberTriviaModel);
      },
    );
  });

  group('toJson', () {
    test(
      '''should retun a JSON mapping from''',
      () {
        //act
        final result = tNumberTriviaModel.toJson();
        //assert
        final expectedMap = {
          "text": "1 is one",
          "number": 1,
        };
        expect(result, expectedMap);
      },
    );
  });
}
