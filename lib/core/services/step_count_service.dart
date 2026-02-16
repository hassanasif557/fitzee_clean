import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks device step count and persists by date so we can show "steps from device"
/// in daily data collection (e.g. yesterday's steps) and today's steps so far.
class StepCountService {
  static const String _prefixSteps = 'steps_';
  static const String _keyBaseline = 'step_baseline';
  static const String _keyBaselineDate = 'step_baseline_date';

  static StreamSubscription<StepCount>? _subscription;
  static int? _baseline;
  static String? _baselineDateKey;
  static final StreamController<int> _todayStepsController =
      StreamController<int>.broadcast();

  /// Stream of today's step count (updated when device reports new steps).
  static Stream<int> get todayStepsStream => _todayStepsController.stream;

  /// Current today's steps from last update (or 0). Use after [startListening].
  static int _lastTodaySteps = 0;
  static int get lastTodaySteps => _lastTodaySteps;

  /// Request permission for step counting (Android: ACTIVITY_RECOGNITION, iOS: motion).
  static Future<bool> requestPermission() async {
    if (await Permission.activityRecognition.isGranted) return true;
    if (await Permission.activityRecognition.request().isGranted) return true;
    if (await Permission.sensors.request().isGranted) return true;
    return false;
  }

  /// Check if step counting is available (permission + sensor).
  static Future<bool> isAvailable() async {
    try {
      await requestPermission();
      await Pedometer.stepCountStream.first.timeout(
        const Duration(seconds: 3),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get stored step count for a given date (e.g. yesterday for daily data pre-fill).
  static Future<int> getStepsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _prefixSteps + _dateKey(date);
    return prefs.getInt(key) ?? 0;
  }

  /// Get today's steps so far (from last persisted update).
  static Future<int> getTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    return prefs.getInt(_prefixSteps + todayKey) ?? 0;
  }

  /// Start listening to device step count and persist by date.
  static Future<void> startListening() async {
    if (_subscription != null) return;
    try {
      await requestPermission();
      _subscription = Pedometer.stepCountStream.listen(_onStepCount);
    } catch (e) {
      print('StepCountService: Failed to start: $e');
    }
  }

  /// Stop listening (e.g. when leaving screen that shows steps).
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  static void _onStepCount(StepCount event) async {
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    if (_baselineDateKey != todayKey || _baseline == null) {
      final prefs = await SharedPreferences.getInstance();
      final savedDate = prefs.getString(_keyBaselineDate);
      final savedBaseline = prefs.getInt(_keyBaseline);
      if (savedDate == todayKey && savedBaseline != null) {
        _baseline = savedBaseline;
        _baselineDateKey = todayKey;
      } else {
        _baseline = event.steps;
        _baselineDateKey = todayKey;
        await prefs.setInt(_keyBaseline, _baseline!);
        await prefs.setString(_keyBaselineDate, todayKey);
      }
    }

    final baseline = _baseline ?? event.steps;
    int todaySteps = event.steps - baseline;
    if (todaySteps < 0) todaySteps = 0;

    _lastTodaySteps = todaySteps;
    if (!_todayStepsController.isClosed) {
      _todayStepsController.add(todaySteps);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefixSteps + todayKey, todaySteps);
  }

  /// Load baseline from storage (call after app restart so we don't reset today's count).
  static Future<void> _loadBaselineIfNeeded() async {
    if (_baseline != null && _baselineDateKey != null) return;
    final prefs = await SharedPreferences.getInstance();
    final savedBaseline = prefs.getInt(_keyBaseline);
    final savedDate = prefs.getString(_keyBaselineDate);
    final todayKey = _dateKey(DateTime.now());
    if (savedDate == todayKey && savedBaseline != null) {
      _baseline = savedBaseline;
      _baselineDateKey = savedDate;
    }
  }

  /// Initialize and start listening (call when user opens daily data or dashboard).
  static Future<void> ensureListening() async {
    await _loadBaselineIfNeeded();
    await startListening();
  }
}
