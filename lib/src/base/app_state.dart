/// Marker interfaces used by BaseState subclasses.
abstract class AppErrorState {
  final String errorMessage;
  const AppErrorState(this.errorMessage);
}

abstract class AppSuccessState {
  final String successMessage;
  const AppSuccessState(this.successMessage);
}
