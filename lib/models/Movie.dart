class Movie {
  final int id;
  final String language;
  final String title;
  final String overview;
  final String posterPath;
  final String backDropPath;
  final double voteAvg;
  final double voteCount;
  final String releaseDate;
  dynamic genreIds;

  Movie({
    required this.id,
    required this.language,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backDropPath,
    required this.voteAvg,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      language: json['original_language'],
      title: json['original_title'],
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backDropPath: json['backdrop_path'] ?? '',
      voteAvg: json['vote_average'],
      voteCount: json['vote_count'],
      releaseDate: json['release_date'] ?? '',
      genreIds: json['genre_ids'],
    );
  }
}
