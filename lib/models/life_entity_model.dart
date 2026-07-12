class LifeEntity {
  final String id;
  final String userId;
  final String entityType;
  final String title;
  final String? description;
  final bool isCompleted;
  final double currentValue;
  final double? targetValue;
  final String? metricLabel;
  final DateTime createdAt;

  LifeEntity({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.currentValue,
    this.targetValue,
    this.metricLabel,
    required this.createdAt,
  });

  factory LifeEntity.fromJson(Map<String, dynamic> json) => LifeEntity(
    id: json['id'],
    userId: json['user_id'],
    entityType: json['entity_type'],
    title: json['title'],
    description: json['description'],
    isCompleted: json['is_completed'] ?? false,
    currentValue: (json['current_value'] ?? 0).toDouble(),
    targetValue: json['target_value'] != null ? (json['target_value']).toDouble() : null,
    metricLabel: json['metric_label'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
