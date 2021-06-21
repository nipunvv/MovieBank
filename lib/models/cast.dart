class Cast {
  final int id;
  final String name;
  final String avatar;

  Cast({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      avatar: json['profile_path'] ?? '',
    );
  }

  @override
  String toString() {
    return this.name;
  }
}
