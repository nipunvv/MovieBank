import 'dart:convert';
import 'dart:io';

import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/genre.dart';
import 'package:http/http.dart' as http;

Future<List<Genre>> fetchGenres() async {
  String url = "${TMDB_API_URL}genre/movie/list";
  final response = await http.get(
    Uri.parse(url),
    headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
  );

  if (response.statusCode == 200) {
    List<Genre> genres = [];
    for (Map<String, dynamic> genre in jsonDecode(response.body)['genres']) {
      genres.add(Genre.fromJson(genre));
    }

    return genres;
  } else {
    throw Exception('Failed to load genres');
  }
}
