import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:movie_bank/widgets/top_bar_contents.dart';
import 'package:http/http.dart' as http;

class MovieDetail extends StatefulWidget {
  final int id;
  MovieDetail(this.id);

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late Future<Movie> futureMovie;

  Future<Movie> fetchMovieDetails() async {
    String url = "${TMDB_API_URL}movie/${widget.id}";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      return Movie.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Movie Details');
    }
  }

  @override
  void initState() {
    super.initState();
    futureMovie = fetchMovieDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 1000),
        child: TopBarContents(1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Movie>(
              future: futureMovie,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Movie? movie = snapshot.data;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: InkWell(
                      onTap: () {},
                      child: Image.network(
                        "$TMDB_WEB_URL${movie!.posterPath}",
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                return SizedBox(
                  height: 100,
                  width: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            SizedBox(
              height: 200,
            ),
            Footer(),
          ],
        ),
      ),
    );
  }
}
