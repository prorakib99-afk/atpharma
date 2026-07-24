import 'dart:async';

final class SessionExpiryNotifier {
  SessionExpiryNotifier();

  final StreamController<void> _controller = StreamController<void>.broadcast(
    sync: true,
  );

  Stream<void> get stream => _controller.stream;

  bool get isDisposed => _controller.isClosed;

  void notifySessionExpired() {
    if (_controller.isClosed) {
      return;
    }

    _controller.add(null);
  }

  Future<void> dispose() async {
    if (_controller.isClosed) {
      return;
    }

    await _controller.close();
  }
}
