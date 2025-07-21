enum LoadingState {
  idle,
  loading,
  success,
  error,
}

class AppState {
  final LoadingState loadingState;
  final String? errorMessage;
  final String selectedLanguage;

  AppState({
    this.loadingState = LoadingState.idle,
    this.errorMessage,
    this.selectedLanguage = 'English',
  });

  AppState copyWith({
    LoadingState? loadingState,
    String? errorMessage,
    String? selectedLanguage,
  }) {
    return AppState(
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  bool get isLoading => loadingState == LoadingState.loading;
  bool get hasError => loadingState == LoadingState.error;
  bool get isSuccess => loadingState == LoadingState.success;
}
