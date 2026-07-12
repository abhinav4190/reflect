class ReflectionModel {
  final String id;
  final String userId;
  final DateTime recordedAt;
  final String rawText;
  final String? mood;
  final List<dynamic> timeAllocation;
  final List<dynamic> spending;
  final int waterML;
  final String aiSummary;

  ReflectionModel({
    required this.id,
    required this.userId,
    required this.recordedAt,
    required this.rawText,
    this.mood,
    required this.timeAllocation,
    required this.spending,
    required this.waterML,
    required this.aiSummary,
  });

  factory ReflectionModel.fromJson(Map<String, dynamic> json) => ReflectionModel(
    id: json['id'],
    userId: json['user_id'],
    recordedAt: DateTime.parse(json['recorded_at']),
    rawText: json['raw_text'] ?? '',
    mood: json['mood'],
    timeAllocation: json['time_allocation'] ?? [],
    spending: json['spending'] ?? [],
    waterML: json['water_ml'] ?? 0,
    aiSummary: json['ai_summary'] ?? '',
  );
}
