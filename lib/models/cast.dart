class Cast {
  final int id;
  final String name;
  final String avatar;
  final String creditId;
  final String character;
  final String department;
  final String job;

  Cast({
    required this.id,
    required this.name,
    required this.avatar,
    required this.creditId,
    required this.character,
    required this.department,
    required this.job,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      avatar: json['profile_path'] ?? '',
      creditId: json['credit_id'],
      character: json['character'],
      department: json['department'] ?? '',
      job: json['job'] ?? '',
    );
  }

  @override
  String toString() {
    return this.name;
  }
}
