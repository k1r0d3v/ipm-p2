/// Business logic base interface.
abstract class Bloc { }

/// Business logic base interface without state,
/// equivalent to [InheritedWidget] but with a unified access
/// with [StatefulBloc].
abstract class StatelessBloc implements Bloc { }

/// Business logic base interface with state.
abstract class StatefulBloc implements Bloc { 
  Future<void> init();
  Future<void> dispose();
}
