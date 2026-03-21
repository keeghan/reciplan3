import 'package:equatable/equatable.dart';

class ImportExportState extends Equatable {
  final bool isBusy;
  final String? successMessage;
  final String? errorMessage;

  const ImportExportState({
    this.isBusy = false,
    this.successMessage,
    this.errorMessage,
  });

  ImportExportState copyWith({
    bool? isBusy,
    String? successMessage,
    String? errorMessage,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return ImportExportState(
      isBusy: isBusy ?? this.isBusy,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isBusy, successMessage, errorMessage];
}
