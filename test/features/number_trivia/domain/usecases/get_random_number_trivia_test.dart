// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:clean_architecture/core/usecases/usecase.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetRandomNumberTrivia usecase;
  late MockNumberTriviaRepository mockNumberTriviaRepository;
  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  const tNumberTrivia = NumberTrivia(
    number: 1,
    text: 'test text',
  );

  test(
    '''should get random trivia
      from the repository''',
    () async {
      //arange
      when(() => mockNumberTriviaRepository.getRandomNumberTrivia())
          .thenAnswer((invocation) async => const Right(tNumberTrivia));
      //act

      ///we can call to [call] method of the instance like this. it is dart feature
      final result = await usecase(NoParams());
      //assert
      expect(result, const Right(tNumberTrivia));
      verify(() => mockNumberTriviaRepository.getRandomNumberTrivia());
      verifyNoMoreInteractions(mockNumberTriviaRepository);
    },
  );
}
// ctrl + ; + a