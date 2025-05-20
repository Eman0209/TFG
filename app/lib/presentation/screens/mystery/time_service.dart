class TimerService {
  static final TimerService _instance = TimerService._internal();

  factory TimerService() => _instance;

  late Stopwatch _stopwatch;

  TimerService._internal() {
    _stopwatch = Stopwatch();
  }

  void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
    }
  }

  void stop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  void reset() {
    _stopwatch.reset();
  }

  Duration get elapsed => _stopwatch.elapsed;

  bool get isRunning => _stopwatch.isRunning;
}
