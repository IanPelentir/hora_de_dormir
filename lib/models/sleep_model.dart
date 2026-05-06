class SleepModel {
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final Duration duration;
  final DateTime createdAt;

  SleepModel({
    required this.sleepStart,
    required this.sleepEnd,
    required this.duration,
    required this.createdAt,
  });

  factory SleepModel.fromMap(Map<String, dynamic> data) {
    final start = DateTime.parse(data['sleepStart'].toString());
    final end = DateTime.parse(data['sleepEnd'].toString());

    return SleepModel(
      sleepStart: start,
      sleepEnd: end,
      duration: end.difference(start),
      createdAt: DateTime.parse(data['createdAt'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sleepStart': sleepStart.toIso8601String(),
      'sleepEnd': sleepEnd.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inMinutes, // opcional (só para display)
    };
  }
}