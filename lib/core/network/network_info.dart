import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Abstraction over network connectivity checking.
abstract class NetworkInfo {
  /// Returns `true` if the device is connected to the internet.
  Future<bool> get isConnected;

  /// Stream of connectivity status changes.
  Stream<InternetConnectionStatus> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;

  @override
  Stream<InternetConnectionStatus> get onStatusChange =>
      connectionChecker.onStatusChange;
}
