enum UserRole {
  admin,
  staff;

  static UserRole fromDbValue(String value) {
    return UserRole.values.firstWhere((r) => r.name == value);
  }

  String toDbValue() => name;
}
