class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final bool isPremiumMember;
  final String wakingHoursStart;
  final String wakingHoursEnd;
  final String reflectionFrequency;
  final String storageMode;
  final bool setupCompleted;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.isPremiumMember,
    required this.wakingHoursStart,
    required this.wakingHoursEnd,
    required this.reflectionFrequency,
    required this.storageMode,
    required this.setupCompleted,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'] ?? '',
    fullName: json['full_name'],
    isPremiumMember: json['is_premium_member'] ?? false,
    wakingHoursStart: json['waking_hours_start'] ?? '07:00:00',
    wakingHoursEnd: json['waking_hours_end'] ?? '23:00:00',
    reflectionFrequency: json['reflection_frequency'] ?? 'hourly',
    storageMode: json['storage_mode'] ?? 'local',
    setupCompleted: json['setup_completed'] ?? false,
  );
}
