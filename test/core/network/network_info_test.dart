import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';

import 'network_info_test.mocks.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

@GenerateMocks([MockInternetConnectionChecker])
void main() {
  late NetworkInfoImpl networkInfo;
  late MockMockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockMockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockInternetConnectionChecker);
  });

  group("isConnected", () {
    test(
      'should forward the call to InternetConnectionChecke.hasConnection',
      () async {
        //arrange
        final tHasConnectionFuture = Future.value(true);
        when(mockInternetConnectionChecker.hasConnection)
            .thenAnswer((_) async => tHasConnectionFuture);
        //act
        final result = await networkInfo.isConnected;
        //assert
        verify(mockInternetConnectionChecker.hasConnection);
        expect(result, true);
      },
    );
  });
}
