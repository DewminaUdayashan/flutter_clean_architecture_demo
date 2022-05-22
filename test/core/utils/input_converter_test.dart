import 'package:clean_architecture/core/utils/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
      '''should return an int when input is valid''',
      () {
        //arange
        const str = '124';
        //act
        final result = inputConverter.stringToUnsignedInt(str);
        //assert
        expect(result, const Right(124));
      },
    );

    test(
      '''should return failure when input is invalid''',
      () {
        //arange
        const str = 'abc';
        //act
        final result = inputConverter.stringToUnsignedInt(str);
        //assert
        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      '''should return FormatException when input is negative ''',
      () {
        //arange
        const str = '-123';
        //act
        final result = inputConverter.stringToUnsignedInt(str);
        //assert
        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}
