class SleepModel {
  final DateTime sleepStart;
  final DateTime? sleepEnd;
  final Duration? duration;
  final DateTime createdAt;

  SleepModel({
    required this.sleepStart,
    this.sleepEnd,
    this.duration,
    required this.createdAt,
  });
}