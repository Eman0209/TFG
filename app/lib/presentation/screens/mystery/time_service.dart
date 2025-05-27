import 'package:app/presentation/presentation_controller.dart';
import 'package:logging/logging.dart';

class TimerService {

  final Logger _logger = Logger('TimerService');
  
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

  Future<void> persistElapsedTime(PresentationController controller, String routeId) async {
    try {
      stop(); // Ensure stopwatch is stopped
      Duration existingDuration = await controller.getStartedRouteDuration(routeId);
      final totalDuration = (existingDuration) + _stopwatch.elapsed;

      await controller.updateStartedRouteDuration(routeId, totalDuration);
      reset();
    } catch (e) {
      _logger.severe('Error persisting elapsed time: $e');
    }
  }

  Duration get elapsed => _stopwatch.elapsed;

  bool get isRunning => _stopwatch.isRunning;
}
