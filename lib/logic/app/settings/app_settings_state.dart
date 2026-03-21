import 'package:equatable/equatable.dart';

class AppSettingsState extends Equatable {
  final bool hapticsEnabled;

  const AppSettingsState({
    required this.hapticsEnabled,
  });

  AppSettingsState copyWith({
    bool? hapticsEnabled,
  }) {
    return AppSettingsState(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  @override
  List<Object?> get props => [hapticsEnabled];
}
