import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      // If no connectivity at all, return false
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // For mobile, wifi, ethernet, etc., we assume internet is available
      // Note: This doesn't guarantee actual internet access, but checks network connectivity
      // For a more robust check, you could ping a server, but this is usually sufficient
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // If there's an error checking connectivity, assume no internet
      return false;
    }
  }

  /// Stream of connectivity changes
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}
