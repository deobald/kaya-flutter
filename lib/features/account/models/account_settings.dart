import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_settings.freezed.dart';

/// User account settings for Kaya server sync.
@freezed
class AccountSettings with _$AccountSettings {
  static const defaultServerUrl = 'https://savebutton.com';
  const AccountSettings._();

  const factory AccountSettings({
    /// The Kaya server URL (default: https://savebutton.com)
    required String serverUrl,

    /// User's email for authentication
    String? email,

    /// Whether credentials are configured
    @Default(false) bool hasCredentials,
  }) = _AccountSettings;

  factory AccountSettings.defaults() =>
      const AccountSettings(serverUrl: defaultServerUrl);

  /// Whether sync can be performed (credentials are set)
  bool get canSync => hasCredentials && email != null && email!.isNotEmpty;
}
