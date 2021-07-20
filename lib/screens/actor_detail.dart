import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/models/actor.dart';
import 'package:movie_bank/screens/search_results.dart';
import 'package:http/http.dart' as http;

class ActorDetail extends StatefulWidget {
  final int actorId;
  final Function changeMovie;
  ActorDetail(this.actorId, this.changeMovie);

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

  dynamic getImage(movie) {
    if (movie.posterPath == '') {
      return Container(
        color: Colors.grey.shade200,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 5,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie,
                  size: 28,
                ),
                Text(
                  movie.title,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: "$TMDB_WEB_URL/w185/${movie.posterPath}",
      fit: BoxFit.cover,
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
              height: MediaQuery.of(context).size.height,
              color: Colors.grey.shade400,
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
                            if (actor.biography != '')
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
              child: FutureBuilder<List<Movie>>(
                future: movies,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Movie>? movies = snapshot.data;
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'MOVIES',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: SizedBox(
                              child: GridView.count(
                                crossAxisCount: 5,
                                mainAxisSpacing: 1.0,
                                childAspectRatio: 0.67,
                                children: List.generate(
                                  movies!.length,
                                  (index) {
                                    return Container(
                                      width: 185,
                                      height: 360,
                                      padding: EdgeInsets.all(15),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: InkWell(
                                          onTap: () {
                                            widget.changeMovie(movies[index]);
                                            Navigator.pop(context);
                                          },
                                          child: Hero(
                                            tag:
                                                'movie_image${movies[index].id}',
                                            child: getImage(movies[index]),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
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
          ],
        ),
      ),
    );
  }
}
