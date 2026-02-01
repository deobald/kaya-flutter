import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Service to monitor network connectivity state.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _onlineController = StreamController<bool>.broadcast();

  bool _isOnline = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService();

  bool get isOnline => _isOnline;
  Stream<bool> get onlineStream => _onlineController.stream;

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(results);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = _hasConnection(results);

      if (_isOnline != wasOnline) {
        _onlineController.add(_isOnline);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(results);
    return _isOnline;
  }

  void dispose() {
    _subscription?.cancel();
    _onlineController.close();
  }
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  final service = ConnectivityService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
}

/// Stream provider for connectivity changes
@riverpod
Stream<bool> connectivityStream(Ref ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onlineStream;
}

/// Provider for current online status
@riverpod
bool isOnline(Ref ref) {
  final service = ref.watch(connectivityServiceProvider);
  // Also listen to stream to update when connectivity changes
  ref.listen(connectivityStreamProvider, (prev, next) {});
  return service.isOnline;
}
