import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/impl/number_trivia_local_data_source_impl.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreference extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaDataSourceImpl dataSource;
  late MockSharedPreference mockSharedPreference;

  setUp(() {
    mockSharedPreference = MockSharedPreference();
    dataSource = NumberTriviaDataSourceImpl(mockSharedPreference);
  });
  final jsonFixture = fixtureJson('cached_trivia.json');
  final tNumberTriviaModel =
      NumberTriviaModel.fromJson(json.decode(jsonFixture));
  group('getLastNumberTrivia', () {
    test(
      '''should return NumberTriviaModal from sharedPreferences
        when there is one in the cache''',
      () async {
        //arange
        when(() => mockSharedPreference.getString(any()))
            .thenReturn(jsonFixture);
        //act
        final result = await dataSource.getLastNumberTrivia();
        //assert
        verify(() => mockSharedPreference.getString(kCachedNumberTrivia));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      '''should throw CacheException when there is not a cached value''',
      () async {
        //arange
        when(() => mockSharedPreference.getString(any())).thenReturn(null);
        //act
        final call = dataSource.getLastNumberTrivia;
        //assert
        expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    const tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'test',
    );
    test(
      '''should call SharedPreferences to cache the data''',
      () {
        //arange
        when(() => mockSharedPreference.setString(any(), any()))
            .thenAnswer((_) async => true);
        //act
        dataSource.cacheNumberTrivia(tNumberTriviaModel);
        //assert
        final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
        verify(() => mockSharedPreference.setString(
            kCachedNumberTrivia, expectedJsonString));
      },
    );
  });
}
