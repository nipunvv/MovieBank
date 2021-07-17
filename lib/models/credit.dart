class Credit {
  final int id;
  final String creditType;
  final String job;

  Credit({
    required this.id,
    required this.creditType,
    required this.job,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'],
      creditType: json['credit_type'] ?? '',
      job: json['job'] ?? '',
    );
  }
}
