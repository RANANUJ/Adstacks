class Employee {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final String email;
  final DateTime? birthday;
  final DateTime? anniversary;
  final int? yearsAtCompany;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.email,
    this.birthday,
    this.anniversary,
    this.yearsAtCompany,
  });

  /// Check if employee has birthday today
  bool isBirthdayToday() {
    if (birthday == null) return false;
    final now = DateTime.now();
    return birthday!.month == now.month && birthday!.day == now.day;
  }

  /// Check if employee has work anniversary today
  bool isAnniversaryToday() {
    if (anniversary == null) return false;
    final now = DateTime.now();
    return anniversary!.month == now.month && anniversary!.day == now.day;
  }
}
