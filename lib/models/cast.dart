class Cast {
  final int id;
  final String name;
  final String avatar;
  final String creditId;

  Cast({
    required this.id,
    required this.name,
    required this.avatar,
    required this.creditId,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      avatar: json['profile_path'] ?? '',
      creditId: json['credit_id'],
    );
  }

  @override
  String toString() {
    return this.name;
  }
}
