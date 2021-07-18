class Actor {
  final int id;
  final String name;
  final String birthDay;
  final String deathDay;
  final String placeOfBirth;
  final String profilePath;
  final String biography;
  final String imdbId;

  Actor({
    required this.id,
    required this.name,
    required this.birthDay,
    required this.deathDay,
    required this.placeOfBirth,
    required this.profilePath,
    required this.biography,
    required this.imdbId,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['name'],
      birthDay: json['birthday'] ?? '',
      deathDay: json['deathday'] ?? '',
      placeOfBirth: json['place_of_birth'],
      profilePath: json['profile_path'],
      biography: json['biography'],
      imdbId: json['imdb_id'],
    );
  }
}
