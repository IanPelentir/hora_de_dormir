class SleepModel {
  final String userId;
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final Duration duration;
  final DateTime createdAt;

  SleepModel({
    required this.userId,
    required this.sleepStart,
    required this.sleepEnd,
    required this.duration,
    required this.createdAt,
  });

  /// 📝 Getter Inteligente para Formatação
  /// Resolve o problema de "não apresentar nada" ou "zero"
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}min";
    } else if (minutes > 0) {
      return "${minutes}min";
    } else {
      // Útil para você testar agora sem precisar esperar 1 minuto
      return "${seconds}s"; 
    }
  }

  /// 📊 Getter para Gráficos (em horas decimais, ex: 7.5)
  double get durationInHours => duration.inSeconds / 3600.0;

  /// 🔄 Converte para salvar no Firebase (Map)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sleepStart': sleepStart.toIso8601String(),
      'sleepEnd': sleepEnd.toIso8601String(),
      // Salvamos em segundos para maior precisão nos testes e histórico
      'durationInSeconds': duration.inSeconds, 
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 🔄 Converte do Firebase para o objeto SleepModel
  factory SleepModel.fromMap(Map<String, dynamic> map) {
    return SleepModel(
      userId: map['userId'] ?? 'desconhecido',
      sleepStart: map['sleepStart'] != null 
          ? DateTime.parse(map['sleepStart']) 
          : DateTime.now(),
      sleepEnd: map['sleepEnd'] != null 
          ? DateTime.parse(map['sleepEnd']) 
          : DateTime.now(),
      // Tenta ler segundos primeiro, se não existir (registros antigos), tenta minutos
      duration: map['durationInSeconds'] != null
          ? Duration(seconds: map['durationInSeconds'])
          : Duration(minutes: map['durationInMinutes'] ?? 0),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}