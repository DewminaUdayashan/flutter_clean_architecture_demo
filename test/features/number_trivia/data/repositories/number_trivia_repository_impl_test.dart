import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/core/error/failure.dart';
import 'package:clean_architecture/core/network/network_info.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModal = NumberTriviaModel(
      number: tNumber,
      text: 'test trivia',
    );
    const NumberTrivia tNumberTrivia = tNumberTriviaModal;
    setUpAll(() {
      registerFallbackValue(tNumberTriviaModal);
    });
    test(
      '''should check if the device is online''',
      () {
        //arange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModal);
        when(() => mockLocalDataSource.cacheNumberTrivia(any()))
            .thenAnswer((_) async => Future.value);
        //act
        repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    group('device in online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      test(
        '''should return remote data when the call to remote data source is successful''',
        () async {
          //arange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => tNumberTriviaModal);
          when(() => mockLocalDataSource.cacheNumberTrivia(any()))
              .thenAnswer((_) async => Future.value);
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        '''should cache remote data locally when the call to remote data source is successful''',
        () async {
          //arange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => tNumberTriviaModal);
          when(() => mockLocalDataSource.cacheNumberTrivia(any()))
              .thenAnswer((_) async => Future.value);
          //act
          await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verify(
              () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModal));
        },
      );

      test(
        '''should return server failure when the call to remote data source is unsuccessful''',
        () async {
          //arange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenThrow(ServerException());
          // when(() => mockLocalDataSource.cacheNumberTrivia(any()))
          //     .thenAnswer((_) async => Future.value);
          //act
          final Either<Failure, NumberTrivia> result =
              await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        '''should return last locally cached data when cached data is available ''',
        () async {
          //arange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModal);
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );
      test(
        '''should return cache failure when there is no cahche data available ''',
        () async {
          //arange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          //act
          final result = await repository.getConcreteNumberTrivia(tNumber);
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumberTriviaModal = NumberTriviaModel(
      number: 1,
      text: 'test trivia',
    );
    const NumberTrivia tNumberTrivia = tNumberTriviaModal;
    setUpAll(() {
      registerFallbackValue(tNumberTriviaModal);
    });
    test(
      '''should check if the device is online''',
      () {
        //arange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModal);
        when(() => mockLocalDataSource.cacheNumberTrivia(any()))
            .thenAnswer((_) async => Future.value);
        //act
        repository.getRandomNumberTrivia();
        //assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    group('device in online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      test(
        '''should return remote data when the call to remote data source is successful''',
        () async {
          //arange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModal);
          when(() => mockLocalDataSource.cacheNumberTrivia(any()))
              .thenAnswer((_) async => Future.value);
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );

      test(
        '''should cache remote data locally when the call to remote data source is successful''',
        () async {
          //arange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModal);
          when(() => mockLocalDataSource.cacheNumberTrivia(any()))
              .thenAnswer((_) async => Future.value);
          //act
          await repository.getRandomNumberTrivia();
          //assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verify(
              () => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModal));
        },
      );

      test(
        '''should return server failure when the call to remote data source is unsuccessful''',
        () async {
          //arange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          // when(() => mockLocalDataSource.cacheNumberTrivia(any()))
          //     .thenAnswer((_) async => Future.value);
          //act
          final Either<Failure, NumberTrivia> result =
              await repository.getRandomNumberTrivia();
          //assert
          verify(() => mockRemoteDataSource.getRandomNumberTrivia());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        '''should return last locally cached data when cached data is available ''',
        () async {
          //arange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModal);
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(const Right(tNumberTrivia)));
        },
      );
      test(
        '''should return cache failure when there is no cahche data available ''',
        () async {
          //arange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          //act
          final result = await repository.getRandomNumberTrivia();
          //assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
