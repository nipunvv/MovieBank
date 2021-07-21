import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/screens/search_results.dart';
import 'package:movie_bank/widgets/movie_list.dart';
import 'package:http/http.dart' as http;

class GenreMovies extends StatefulWidget {
  final int genreId;
  final String genreName;

  GenreMovies(this.genreId, this.genreName);

  @override
  _GenreMoviesState createState() => _GenreMoviesState();
}

class _GenreMoviesState extends State<GenreMovies> {
  late Future<List<Movie>> movies;

  Future<List<Movie>> fetchMoviesByGenre(genreid) async {
    String url =
        "${TMDB_API_URL}discover/movie?language=en-US&sort_by=popularity.desc&with_genres=$genreid";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      List<Movie> movies = [];
      for (Map<String, dynamic> movie in jsonDecode(response.body)['results']) {
        movies.add(Movie.fromJson(movie));
      }

      return movies;
    } else {
      throw Exception('Failed to load similar movies');
    }
  }

  @override
  void initState() {
    super.initState();
    movies = fetchMoviesByGenre(widget.genreId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.genreName} Movies'),
        backgroundColor: Color(0xff161b2e),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchResults(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FutureBuilder<List<Movie>>(
          future: movies,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Movie> movies = snapshot.data ?? [];
              return Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: MovieList(movies),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error fetching movies'),
              );
            }
            return Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
