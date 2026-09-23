class AttendanceRecord {
  final String id;
  final String staffId;
  final DateTime timestamp;
  final String selfiePath;
  final double latitude;
  final double longitude;
  final String? address;
  final double matchScore;

  const AttendanceRecord({
    required this.id,
    required this.staffId,
    required this.timestamp,
    required this.selfiePath,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.matchScore,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'selfie_path': selfiePath,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'match_score': matchScore,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, Object?> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      staffId: map['staff_id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      selfiePath: map['selfie_path'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      address: map['address'] as String?,
      matchScore: map['match_score'] as double,
    );
  }
}
