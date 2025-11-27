import 'package:equatable/equatable.dart';

class LogModel extends Equatable {
  final String id;
  final String userId;
  final String profileId;
  final String logName;
  final Map<String, dynamic>? additionalData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LogModel({
    required this.id,
    required this.userId,
    required this.profileId,
    required this.logName,
    this.additionalData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      profileId: json['profile_id'] as String,
      logName: json['log_name'] as String,
      additionalData: json['additional_data'] != null
          ? Map<String, dynamic>.from(json['additional_data'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'profile_id': profileId,
      'log_name': logName,
      'additional_data': additionalData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LogModel copyWith({
    String? id,
    String? userId,
    String? profileId,
    String? logName,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      logName: logName ?? this.logName,
      additionalData: additionalData ?? this.additionalData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        profileId,
        logName,
        additionalData,
        createdAt,
        updatedAt,
      ];
}
