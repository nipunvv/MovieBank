import 'package:movie_bank/models/Movie.dart';

class Credit {
  final String id;
  final String creditType;
  final String job;
  final List<dynamic> knownFor;

  Credit({
    required this.id,
    required this.creditType,
    required this.job,
    required this.knownFor,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'],
      creditType: json['credit_type'] ?? '',
      job: json['job'] ?? '',
      knownFor: json['person']['known_for'],
    );
  }
}
