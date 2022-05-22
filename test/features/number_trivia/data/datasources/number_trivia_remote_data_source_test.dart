import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/impl/number_trivia_remote_data_source_impl.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSource dataSources;
  late MockHttpClient mockHttpClient;
  setUpAll(
      () => registerFallbackValue(Uri.parse('http:/numbersapi.com/1?json')));

  //
  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSources = NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  void _setUpMockHttpCient200() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer(
      (_) async => http.Response(fixtureJson('trivia.json'), 200),
    );
  }

  void _setUpMockHttpClienError() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer(
      (_) async => http.Response('No Found', 400),
    );
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixtureJson('trivia.json')));
    test(
      '''should perform a GET request on URL with number 
    being the endoin and with application/json header''',
      () async {
        //arange
        _setUpMockHttpCient200();
        //act
        dataSources.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockHttpClient.get(
              Uri.parse('http:/numbersapi.com/$tNumber'),
              headers: {
                'Content-Type': 'application/json',
              },
            ));
      },
    );

    test(
      '''should return NumberTriviaModel when the response code is 200''',
      () async {
        //arange
        _setUpMockHttpCient200();
        //act
        final response = await dataSources.getConcreteNumberTrivia(tNumber);
        //assert
        expect(response, tNumberTriviaModel);
      },
    );

    test(
      '''should throw a ServerException when status code is not 200''',
      () {
        //arange
        _setUpMockHttpClienError();
        //act
        final call = dataSources.getConcreteNumberTrivia;
        //assert
        expect(
            () => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });

  group('getConcreteRandomNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixtureJson('trivia.json')));
    test(
      '''should perform a GET request on URL and with application/json header
      and return random number''',
      () async {
        //arange
        _setUpMockHttpCient200();
        //act
        dataSources.getRandomNumberTrivia();
        //assert
        verify(() => mockHttpClient.get(
              Uri.parse('http:/numbersapi.com/random'),
              headers: {
                'Content-Type': 'application/json',
              },
            ));
      },
    );

    test(
      '''should return NumberTriviaModel when the response code is 200''',
      () async {
        //arange
        _setUpMockHttpCient200();
        //act
        final response = await dataSources.getRandomNumberTrivia();
        //assert
        expect(response, tNumberTriviaModel);
      },
    );

    test(
      '''should throw a ServerException when status code is not 200''',
      () {
        //arange
        _setUpMockHttpClienError();
        //act
        final call = dataSources.getRandomNumberTrivia;
        //assert
        expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
      },
    );
  });
}
