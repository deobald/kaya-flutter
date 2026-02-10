import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kaya/core/services/logger_service.dart';
import 'package:kaya/features/account/models/account_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'account_repository.g.dart';

const _keyServerUrl = 'kaya_server_url';
const _keyEmail = 'kaya_email';
const _keyPassword = 'kaya_password';
const _defaultServerUrl = AccountSettings.defaultServerUrl;

/// Repository for managing account settings and credentials.
class AccountRepository {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;
  final LoggerService? _logger;

  AccountRepository(this._prefs, this._secureStorage, this._logger);

  /// Loads account settings from storage.
  Future<AccountSettings> loadSettings() async {
    final serverUrl = _prefs.getString(_keyServerUrl) ?? _defaultServerUrl;
    final email = _prefs.getString(_keyEmail);
    final password = await _secureStorage.read(key: _keyPassword);

    return AccountSettings(
      serverUrl: serverUrl,
      email: email,
      hasCredentials: email != null && password != null && password.isNotEmpty,
    );
  }

  /// Saves the server URL.
  Future<void> saveServerUrl(String url) async {
    await _prefs.setString(_keyServerUrl, url);
    _logger?.i('Server URL updated');
  }

  /// Saves the email.
  Future<void> saveEmail(String email) async {
    await _prefs.setString(_keyEmail, email);
    _logger?.i('Email updated');
  }

  /// Saves the password securely.
  Future<void> savePassword(String password) async {
    await _secureStorage.write(key: _keyPassword, value: password);
    _logger?.i('Password updated');
  }

  /// Gets the stored password.
  Future<String?> getPassword() async {
    return await _secureStorage.read(key: _keyPassword);
  }

  /// Clears all credentials.
  Future<void> clearCredentials() async {
    await _prefs.remove(_keyEmail);
    await _secureStorage.delete(key: _keyPassword);
    _logger?.i('Credentials cleared');
  }

  /// Gets the server URL.
  String getServerUrl() {
    return _prefs.getString(_keyServerUrl) ?? _defaultServerUrl;
  }

  /// Gets the email.
  String? getEmail() {
    return _prefs.getString(_keyEmail);
  }
}

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
}

@Riverpod(keepAlive: true)
Future<AccountRepository> accountRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final secureStorage = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  return AccountRepository(prefs, secureStorage, logger);
}

/// Notifier for account settings state
@Riverpod(keepAlive: true)
class AccountSettingsNotifier extends _$AccountSettingsNotifier {
  @override
  Future<AccountSettings> build() async {
    final repo = await ref.watch(accountRepositoryProvider.future);
    return await repo.loadSettings();
  }

  Future<void> updateServerUrl(String url) async {
    final repo = await ref.read(accountRepositoryProvider.future);
    await repo.saveServerUrl(url);
    ref.invalidateSelf();
  }

  Future<void> updateEmail(String email) async {
    final repo = await ref.read(accountRepositoryProvider.future);
    await repo.saveEmail(email);
    ref.invalidateSelf();
  }

  Future<void> updatePassword(String password) async {
    final repo = await ref.read(accountRepositoryProvider.future);
    await repo.savePassword(password);
    ref.invalidateSelf();
  }

  Future<void> clearCredentials() async {
    final repo = await ref.read(accountRepositoryProvider.future);
    await repo.clearCredentials();
    ref.invalidateSelf();
  }
}
