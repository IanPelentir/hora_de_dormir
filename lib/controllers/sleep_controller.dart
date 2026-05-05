class SleepController {
  /// Faixa ideal baseada em adultos (pode evoluir depois)
  static const double _minIdeal = 7.0;
  static const double _maxIdeal = 9.0;

  /// Analisa a qualidade do sono
  static String getSleepQualityFeedback(Duration duration) {
    final hours = duration.inMinutes / 60.0;

    if (hours <= 0) {
      return "No data";
    } else if (hours < 6) {
      return "Poor sleep 😴";
    } else if (hours < _minIdeal) {
      return "Needs improvement ⚠️";
    } else if (hours <= _maxIdeal) {
      return "Good sleep ✅";
    } else if (hours <= 10) {
      return "Great recovery 💪";
    } else {
      return "Oversleeping 💤";
    }
  }

  /// Retorna faixa recomendada baseada na idade (string)
  static String getRecommendedSleep(int age) {
    if (age < 18) {
      return "8–10h";
    } else if (age <= 64) {
      return "7–9h";
    } else {
      return "7–8h";
    }
  }

  /// Retorna valor numérico ideal (para gráfico/metas)
  static double getIdealSleepHours(int age) {
    if (age < 18) return 9;
    if (age <= 64) return 8;
    return 7.5;
  }

  /// Verifica se bateu a meta
  static bool didMeetGoal(Duration duration, int age) {
    final hours = duration.inMinutes / 60.0;
    final ideal = getIdealSleepHours(age);

    return hours >= (ideal - 1) && hours <= (ideal + 1);
  }

  /// Calcula duração com proteção
  static Duration calculateDuration(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      return Duration.zero;
    }
    return end.difference(start);
  }
}