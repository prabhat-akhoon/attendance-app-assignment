class Staff {
  final String id;
  final String employeeId;
  final String name;
  final DateTime createdAt;
  final DateTime? faceEnrolledAt;

  const Staff({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.createdAt,
    this.faceEnrolledAt,
  });

  bool get isFaceEnrolled => faceEnrolledAt != null;

  Staff copyWith({DateTime? faceEnrolledAt}) {
    return Staff(
      id: id,
      employeeId: employeeId,
      name: name,
      createdAt: createdAt,
      faceEnrolledAt: faceEnrolledAt ?? this.faceEnrolledAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'face_enrolled_at': faceEnrolledAt?.millisecondsSinceEpoch,
    };
  }

  factory Staff.fromMap(Map<String, Object?> map) {
    final enrolledAtMs = map['face_enrolled_at'] as int?;
    return Staff(
      id: map['id'] as String,
      employeeId: map['employee_id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      faceEnrolledAt: enrolledAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(enrolledAtMs),
    );
  }
}
