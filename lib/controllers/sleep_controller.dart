import 'package:flutter/material.dart';
import '../models/sleep_model.dart';

class SleepController extends ChangeNotifier {
  final List<SleepModel> _sleepList = [];

  List<SleepModel> get sleepList => List.unmodifiable(_sleepList);

  static const double _minIdeal = 7.0;
  static const double _maxIdeal = 9.0;

  void addSleep(DateTime start, DateTime end) {
    final duration = calculateDuration(start, end);

    final model = SleepModel(
      sleepStart: start,
      sleepEnd: end,
      duration: duration,
      createdAt: DateTime.now(),
    );

    _sleepList.insert(0, model);
    notifyListeners();
  }

  static String getSleepQualityFeedback(Duration duration) {
    final hours = duration.inMinutes / 60.0;

    if (hours <= 0) return "Sem dados";
    if (hours < 6) return "Sono ruim 😴";
    if (hours < _minIdeal) return "Precisa melhorar ⚠️";
    if (hours <= _maxIdeal) return "Sono bom ✅";
    if (hours <= 10) return "Recuperação excelente 💪";
    return "Sono excessivo 💤";
  }

  static String getRecommendedSleep(int age) {
    if (age < 18) return "8–10h";
    if (age <= 64) return "7–9h";
    return "7–8h";
  }

  static double getIdealSleepHours(int age) {
    if (age < 18) return 9;
    if (age <= 64) return 8;
    return 7.5;
  }

  static bool didMeetGoal(SleepModel model, int age) {
    final hours = model.duration.inMinutes / 60.0;
    final ideal = getIdealSleepHours(age);

    return hours >= (ideal - 1) && hours <= (ideal + 1);
  }

  static Duration calculateDuration(DateTime start, DateTime end) {
    return end.isBefore(start)
        ? end.add(const Duration(days: 1)).difference(start)
        : end.difference(start);
  }
}