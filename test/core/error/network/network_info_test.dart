import 'package:clean_architecture/core/network/network_info.dart';
import 'package:data_connection_checker_nulls/data_connection_checker_nulls.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  late NetworkInfo networkInfoImpl;
  late MockDataConnectionChecker mockDataConnectionChecker;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockDataConnectionChecker);
  });

  group('isConnected', () {
    test(
      '''should forward the call to DataConnectionChecker.hasConnection''',
      () async {
        //arange
        //? this is special
        //? get thenAnswer to a variable and check it with actual
        //? results later
        //? cuz we can send just 'true' from networkInfoImpl.isConnected &
        //? that will pass the test even no connected
        //? when we used the save future object to determine expectation
        //? it can't be manipulated as before
        final tHasConnectionFuture = Future.value(true);
        when(() => mockDataConnectionChecker.hasConnection)
            .thenAnswer((_) => tHasConnectionFuture);
        //act
        final result = networkInfoImpl.isConnected;
        //assert
        verify(() => mockDataConnectionChecker.hasConnection);
        expect(result, tHasConnectionFuture);
      },
    );
  });
}
