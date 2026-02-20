import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that safely ignores [notifyListeners] calls
/// after it has been disposed.
///
/// This prevents "A [ChangeNotifier] was used after being disposed" 
/// exceptions which frequently occur when asynchronous operations 
/// (like Streams or Futures) emit data after a widget is unmounted 
/// and the controller is destroyed.
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;

  /// Returns true if [dispose] has been called on this object.
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}
