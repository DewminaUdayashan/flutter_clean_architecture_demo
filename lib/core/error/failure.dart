import 'package:equatable/equatable.dart';

/// repos catch [exceptions] and transform them into [Failure]
abstract class Failure extends Equatable {}

//general failures
class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class CacheFailure extends Failure {
  @override
  List<Object?> get props => [];
}
