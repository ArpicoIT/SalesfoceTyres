enum AppErrorType {
  validation,
  storage,
  sql,
  network,
  api,
  authorization,
  unknown,
}

class AppException implements Exception {
  final AppErrorType type;
  final String message;
  final Object? cause;

  const AppException({
    required this.type,
    required this.message,
    this.cause,
  });

  String get title {
    switch (type) {
      case .validation:
        return 'Validation Error';
      case .storage:
        return 'Storage Error';
      case .sql:
        return 'Database Error';
      case .network:
        return 'Network Error';
      case .api:
        return 'API Error';
      case .authorization:
        return 'Authorization Error';
      case .unknown:
        return 'Unknown Error';
    }
  }

  @override
  String toString() => '$title: $message';

  // VALIDATION
  factory AppException.validationCustomerNotSelected() {
    return const AppException(
      type: .validation,
      message: 'Customer selection is required.',
    );
  }

  factory AppException.validationBankNotSelected(){
    return AppException(
      type: .validation,
      message: 'Bank selection is required.',
    );
  }


  // NETWORK
  // factory AppException.networkNoInternet() {
  //   return const AppException(
  //     type: .network,
  //     message: 'No internet connection.',
  //   );
  // }

  // MISSING FIELDS
  factory AppException.tabCodeMissing() {
    return const AppException(
      type: .validation,
      message: 'TAB code is missing.',
    );
  }



}