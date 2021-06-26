import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/models/cast.dart';
import 'package:movie_bank/models/genre.dart';
import 'package:movie_bank/providers/provider.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:movie_bank/widgets/top_bar_contents.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:shimmer/shimmer.dart';

class MovieDetail extends StatefulWidget {
  final Movie movie;
  MovieDetail(this.movie);

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late Movie movie;
  late Future<List<Cast>> cast;

  @override
  void initState() {
    super.initState();
    setState(() {
      movie = widget.movie;
    });
    cast = fetchCast();
  }

  List<Color> colors = [
    Colors.amber,
    Colors.blue.shade400,
    Colors.red.shade400,
    Colors.orange.shade400,
  ];

  Future<List<Cast>> fetchCast() async {
    String url = "${TMDB_API_URL}movie/${movie.id}/credits";
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

  @override
  Widget build(BuildContext context) {
    final genreModel = Provider.of<GenreProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 1000),
        child: TopBarContents(1),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          "$TMDB_WEB_URL${movie.posterPath}",
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.height * 0.8,
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
                              Container(
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
                                child: Text(
                                  LocaleNames.of(context)!
                                      .nameOf(movie.language)
                                      .toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
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
                                child: Text(
                                  movie.releaseDate,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                                  backgroundImage: NetworkImage(
                                                    "$TMDB_WEB_URL${casts[i].avatar}",
                                                  ),
                                                ),
                                              ),
                                            )
                                      ],
                                    )
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'CAST',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Quicksand',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      for (int i = 0; i < 5; i++)
                                        Container(
                                          margin: EdgeInsets.only(
                                            right: 7,
                                            top: 10,
                                          ),
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade300,
                                            highlightColor:
                                                Colors.grey.shade100,
                                            child: CircleAvatar(
                                              radius: 30,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
              ),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}
