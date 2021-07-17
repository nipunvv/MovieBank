import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:js' as js;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/models/cast.dart';
import 'package:movie_bank/models/genre.dart';
import 'package:movie_bank/providers/provider.dart';
import 'package:movie_bank/screens/search_results.dart';
import 'package:movie_bank/widgets/cast_shimmer.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class MovieDetail extends StatefulWidget {
  final Movie movie;
  MovieDetail(this.movie);

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late Movie movie;
  late Future<List<Cast>> cast;
  late Future<List<Movie>> similarMovies;

  @override
  void initState() {
    super.initState();
    setState(() {
      movie = widget.movie;
    });
    cast = fetchCast(widget.movie.id);
    similarMovies = fetchSimilarMovies(widget.movie.id);
  }

  List<Color> colors = [
    Colors.amber,
    Colors.blue.shade400,
    Colors.red.shade400,
    Colors.orange.shade400,
  ];

  Future<List<Cast>> fetchCast(movieId) async {
    String url = "${TMDB_API_URL}movie/$movieId/credits";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      List<Cast> casts = [];
      for (Map<String, dynamic> cast in jsonDecode(response.body)['cast']) {
        Cast c = Cast.fromJson(cast);
        casts.add(c);
      }

      return casts;
    } else {
      throw Exception('Failed to load cast');
    }
  }

  Future<List<Movie>> fetchSimilarMovies(movieId) async {
    String url = "${TMDB_API_URL}movie/$movieId/similar";
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

  List<Movie> getValidMovies(List<Movie>? movies) {
    if (movies == null) return [];
    return movies.where((element) => element.posterPath != '').toList();
  }

  String getSearchableString(String title) {
    return title.replaceAll(RegExp('\\s'), '+');
  }

  Widget getMovieDetails(String type, String content) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Color(0xffd3d3d3),
        border: Border.all(
          color: Color(0xffd3d3d3),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            type == 'language' ? Icons.language : Icons.calendar_today,
            size: 18,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            type == 'language'
                ? LocaleNames.of(context)!.nameOf(content).toString()
                : content.substring(0, 4),
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget getGenres(List<Genre> genres) {
    if (!(movie.genreIds is List)) return Container();
    List<dynamic> genreIds = movie.genreIds;
    List<Genre> genreNames = [];
    genreIds.forEach((id) {
      genreNames =
          genres.where((element) => genreIds.contains(element.id)).toList();
    });

    if (genreNames.length > 0) {
      return Row(children: [
        for (var i = 0; i < genreNames.length; i++)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 3,
            ),
            margin: EdgeInsets.only(
              right: 5,
            ),
            decoration: BoxDecoration(
              color: colors[i % 4],
              border: Border.all(
                color: colors[i % 4],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              genreNames[i].name,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ]);
    }
    return Container();
  }

  Widget ratingContainer(ratingPercentage, voteCount) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff032541),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              child: CircularPercentIndicator(
                radius: 55.0,
                lineWidth: 3.0,
                percent: double.parse(ratingPercentage),
                center: Text(
                  '${(double.parse(ratingPercentage) * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Color(0xff204529),
                progressColor: Color(0xff21d07a),
              ),
            )
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text('From $voteCount votes'),
        ),
      ],
    );
  }

  getBackgrondImage(imageUrl) {
    if (imageUrl == '') {
      return AssetImage('assets/images/avatar.jpg');
    } else {
      return NetworkImage("$TMDB_WEB_URL/w185/$imageUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreModel = Provider.of<GenreProvider>(context);

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
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Hero(
                          tag: 'movie_image${movie.id}',
                          child: CachedNetworkImage(
                            imageUrl: "$TMDB_WEB_URL/w342/${movie.posterPath}",
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: MediaQuery.of(context).size.height * 0.8,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              movie.title.toUpperCase(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              getMovieDetails('language', movie.language),
                              SizedBox(
                                width: 10,
                              ),
                              getMovieDetails('release', movie.releaseDate),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xffd3d3d3),
                                  border: Border.all(
                                    color: Color(0xffd3d3d3),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 18,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    TextButton(
                                      child: Text('Search on Pahe.ph'),
                                      onPressed: () {
                                        js.context.callMethod('open', [
                                          'https://pahe.ph/?s=${getSearchableString(movie.title)}'
                                        ]);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (genreModel.genres.length != 0)
                            getGenres(genreModel.genres),
                          SizedBox(
                            height: 20,
                          ),
                          ratingContainer(
                            (movie.voteAvg / 10).toStringAsFixed(2),
                            movie.voteCount,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'OVERVIEW',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text(
                              movie.overview,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          FutureBuilder<List<Cast>>(
                            future: cast,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<Cast>? casts = snapshot.data;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'CAST',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Quicksand',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        if (casts != null)
                                          for (int i = 0;
                                              i < math.min(casts.length, 8);
                                              i++)
                                            Container(
                                              margin: EdgeInsets.only(
                                                right: 7,
                                              ),
                                              child: Tooltip(
                                                message: casts[i].name,
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage:
                                                      getBackgrondImage(
                                                    casts[i].avatar,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ],
                                    )
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }

                              return CastShimmer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SIMILAR MOVIES',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FutureBuilder<List<Movie>>(
                      future: similarMovies,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Movie>? movies = snapshot.data;
                          return CarouselSlider(
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.height * 0.3,
                              viewportFraction: 0.12,
                              enlargeCenterPage: false,
                              enlargeStrategy: CenterPageEnlargeStrategy.scale,
                              disableCenter: false,
                              aspectRatio: 16 / 9,
                              initialPage: 0,
                            ),
                            items: getValidMovies(movies).map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  if (item.posterPath != '') {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            movie = item;
                                            cast = fetchCast(item.id);
                                            similarMovies =
                                                fetchSimilarMovies(item.id);
                                          });
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "$TMDB_WEB_URL/w185/${item.posterPath}",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            }).toList(),
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
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
