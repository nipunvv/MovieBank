import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/models/actor.dart';
import 'package:movie_bank/screens/search_results.dart';
import 'package:http/http.dart' as http;

class ActorDetail extends StatefulWidget {
  final int actorId;
  ActorDetail(this.actorId);

  @override
  _ActorDetailState createState() => _ActorDetailState();
}

class _ActorDetailState extends State<ActorDetail> {
  late Future<List<Movie>> movies;
  late Future<Actor> actorDetails;

  @override
  void initState() {
    super.initState();
    actorDetails = fetchActorDetails(widget.actorId);
    movies = fetchMoviesOfActor(widget.actorId);
  }

  Future<Actor> fetchActorDetails(int actorId) async {
    String url = "${TMDB_API_URL}person/$actorId";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      Actor actor = Actor.fromJson(jsonDecode(response.body));
      return actor;
    } else {
      throw Exception('Failed to load actor details');
    }
  }

  Future<List<Movie>> fetchMoviesOfActor(int actorId) async {
    String url = "${TMDB_API_URL}person/$actorId/movie_credits";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      List<Movie> movies = [];
      for (Map<String, dynamic> movie in jsonDecode(response.body)['cast']) {
        movies.add(Movie.fromJson(movie));
      }

      return movies;
    } else {
      throw Exception('Failed to load movies');
    }
  }

  String getAge(Actor actor) {
    int bornOn = int.parse(actor.birthDay.substring(0, 4));
    DateTime now = DateTime.now();
    int currentYear = now.year;
    return (currentYear - bornOn).toString();
  }

  TextStyle getStyle() {
    return TextStyle(
      fontFamily: 'Quicksand',
      fontWeight: FontWeight.normal,
      fontSize: 14,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MOVIE BANK'),
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
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: FutureBuilder<Actor>(
                future: actorDetails,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Actor? actor = snapshot.data;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(
                                "$TMDB_WEB_URL/w154/${actor!.profilePath}",
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              actor.name,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Table(
                              children: [
                                if (actor.deathDay == '')
                                  TableRow(
                                    children: [
                                      Text(
                                        'Age',
                                        style: getStyle(),
                                      ),
                                      Text(
                                        getAge(actor),
                                        style: getStyle(),
                                      ),
                                    ],
                                  ),
                                TableRow(
                                  children: [
                                    Text(
                                      'Born on',
                                      style: getStyle(),
                                    ),
                                    Text(
                                      actor.birthDay,
                                      style: getStyle(),
                                    ),
                                  ],
                                ),
                                if (actor.deathDay != '')
                                  TableRow(
                                    children: [
                                      Text(
                                        'Died on',
                                        style: getStyle(),
                                      ),
                                      Text(
                                        actor.deathDay,
                                        style: getStyle(),
                                      ),
                                    ],
                                  ),
                                TableRow(
                                  children: [
                                    Text(
                                      'Place of birth',
                                      style: getStyle(),
                                    ),
                                    Text(
                                      actor.placeOfBirth,
                                      style: getStyle(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'About',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              actor.biography,
                              style: getStyle(),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
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
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: double.infinity,
              child: Container(
                color: Colors.blue,
                child: FutureBuilder<List<Movie>>(
                  future: movies,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Movie>? movies = snapshot.data;
                      return Text('MOVIES');
                    } else {
                      return Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
