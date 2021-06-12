import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MovieBank());
}

class MovieBank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Bank',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(title: 'Movie Bank'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> futureMovie;

  Future<List<Movie>> fetchMovies(int index) async {
    String url =
        "${TMDB_API_URL}movie/${index == 0 ? 'popular' : 'now_playing'}?language=en-US&page=1";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      List<Movie> movies = [];
      for (Map<String, dynamic> movie in jsonDecode(response.body)['results']) {
        movies.add(Movie.fromJson(movie));
      }
      if (index == 1) print('MOVIES ==> $movies');

      return movies;
    } else {
      throw Exception('Failed to load Movie');
    }
  }

  @override
  void initState() {
    super.initState();
    futureMovie = fetchMovies(0);
  }

  void handleCategoryChange(int index) {
    setState(() {
      futureMovie = fetchMovies(index);
    });
  }

  int getItemCount(double screenWidth) {
    if (screenWidth > 1000) {
      return 5;
    } else if (screenWidth > 700) {
      return 4;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Movie App'),
      ),
      body: Container(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              FlutterToggleTab(
                width: 20,
                borderRadius: 20,
                height: 30,
                initialIndex: 0,
                selectedBackgroundColors: [Colors.blue],
                selectedTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unSelectedTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                labels: ["Popular", "Latest"],
                selectedLabelIndex: (index) {
                  handleCategoryChange(index);
                },
              ),
              Expanded(
                child: FutureBuilder<List<Movie>>(
                  future: futureMovie,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Movie>? movies = snapshot.data;
                      return GridView.count(
                        crossAxisCount: getItemCount(screenWidth),
                        mainAxisSpacing: 0,
                        shrinkWrap: true,
                        children: List.generate(movies!.length, (index) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Card(
                              child: GridTile(
                                child: Image.network(
                                  "$TMDB_WEB_URL${movies[index].posterPath}",
                                ),
                              ),
                            ),
                          );
                        }),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
