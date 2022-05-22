// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepository);
  });

  const tEnterNumber = 10;
  const tNumberTrivia = NumberTrivia(
    number: 1,
    text: 'test text',
  );

  test(
    '''should get trivia for the given number
      from the repository''',
    () async {
      //arange
      when(() => mockNumberTriviaRepository.getConcreteNumberTrivia(any()))
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      //act

      ///we can call to [call] method of the instance like this. it is dart feature
      final result = await usecase(const Params(number: tEnterNumber));
      //assert
      expect(result, const Right(tNumberTrivia));
      verify(() =>
          mockNumberTriviaRepository.getConcreteNumberTrivia(tEnterNumber));
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}
// ctrl + ; + a