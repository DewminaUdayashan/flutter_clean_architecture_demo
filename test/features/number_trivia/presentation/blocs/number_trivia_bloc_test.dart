import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture/core/error/failure.dart';
import 'package:clean_architecture/core/usecases/usecase.dart';
import 'package:clean_architecture/core/utils/input_converter.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/presentation/blocs/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCocreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetCocreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetCocreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  blocTest(
    'emits [] when nothing is added',
    build: () => bloc,
    expect: () => [],
  );

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(
      number: tNumberParsed,
      text: 'test',
    );

    setUpAll(() {
      registerFallbackValue(const Params(number: tNumberParsed));
    });

    test(
      '''should call the input converter to validate the string and convert''',
      () async {
        //arange
        when(() => mockInputConverter.stringToUnsignedInt(any()))
            .thenAnswer((_) => const Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //act
        bloc.add(const GetTriviaConcreteNumber(tNumberString));

        ///we have to wait until the event pass and handle in the bloc
        await untilCalled(() => mockInputConverter.stringToUnsignedInt(any()));
        verify(() => mockInputConverter.stringToUnsignedInt(tNumberString));
        //assert
      },
    );

    blocTest(
      'should emit [Loading, Error] when the input is invalid',
      setUp: () => when(() => mockInputConverter.stringToUnsignedInt(any()))
          .thenAnswer((_) => Left(InvalidInputFailure())),
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaConcreteNumber(tNumberString)),
      expect: () => [
        Loading(),
        const Error(kInvalidInputFailureMsg),
      ],
    );

    test(
      '''should get data from the concrete usecase''',
      () async {
        //arange
        when(() => mockInputConverter.stringToUnsignedInt(any()))
            .thenAnswer((_) => const Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //act
        bloc.add(const GetTriviaConcreteNumber(tNumberString));
        await untilCalled(() => mockGetConcreteNumberTrivia(any()));
        //assert
        verify(() =>
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
      },
    );

    blocTest(
      'should emit [loading,  loaded ] when data is gotten successfully',
      setUp: () {
        when(() => mockInputConverter.stringToUnsignedInt(any()))
            .thenAnswer((_) => const Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaConcreteNumber(tNumberString)),
      wait: const Duration(seconds: 2),
      expect: () => [
        Loading(),
        const Loaded(tNumberTrivia),
      ],
    );

    blocTest(
      'should emit [loading,  error ] when data is getting unsuccessfully',
      setUp: () {
        when(() => mockInputConverter.stringToUnsignedInt(any()))
            .thenAnswer((_) => const Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaConcreteNumber(tNumberString)),
      wait: const Duration(seconds: 2),
      expect: () => [
        Loading(),
        const Error(kServerFailureMsg),
      ],
    );

    blocTest(
      'should emit [loading,  error ]with proper message for the error when getting data fails',
      setUp: () {
        when(() => mockInputConverter.stringToUnsignedInt(any()))
            .thenAnswer((_) => const Right(tNumberParsed));
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaConcreteNumber(tNumberString)),
      wait: const Duration(seconds: 2),
      expect: () => [
        Loading(),
        const Error(kCacheFailureMsg),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(
      number: 1,
      text: 'test',
    );
    setUpAll(() {
      registerFallbackValue(NoParams());
    });
    // setUpAll(() {
    //   registerFallbackValue(const Params(number: 1));
    // });

    test(
      '''should get data from the random usecase''',
      () async {
        //arange
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        //act
        bloc.add(GetTriviaRandomNumber());
        await untilCalled(() => mockGetRandomNumberTrivia(any()));
        //assert
        verify(() => mockGetRandomNumberTrivia(any()));
      },
    );

    blocTest(
      'should emit [loading,  loaded ] when data is gotten successfully',
      setUp: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) => bloc.add(GetTriviaRandomNumber()),
      wait: const Duration(seconds: 2),
      expect: () => [
        Loading(),
        const Loaded(tNumberTrivia),
      ],
    );

    blocTest(
      'should emit [loading,  error ] when data is getting unsuccessfully',
      setUp: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) => bloc.add(GetTriviaRandomNumber()),
      wait: const Duration(seconds: 2),
      expect: () => [
        Loading(),
        const Error(kServerFailureMsg),
      ],
    );

    blocTest(
      'should emit [loading,  error ] with proper message for the error when getting data fails',
      setUp: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) => bloc.add(GetTriviaRandomNumber()),
      wait: const Duration(seconds: 2),
      expect: () => [
        Loading(),
        const Error(kCacheFailureMsg),
      ],
    );
  });
}

//5.51