import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:movie_bank/widgets/top_bar_contents.dart';
import 'package:http/http.dart' as http;

class MovieDetail extends StatefulWidget {
  final Movie movie;
  MovieDetail(this.movie);

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late Movie movie;

  @override
  void initState() {
    super.initState();
    setState(() {
      movie = widget.movie;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 1000),
        child: TopBarContents(1),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.indigo[800],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Image.network(
                      "$TMDB_WEB_URL${movie!.backDropPath}",
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.8,
                      color: const Color.fromRGBO(255, 255, 255, 0.5),
                      colorBlendMode: BlendMode.modulate,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        movie.language,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Text(
                          movie.overview,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Quicksand',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
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
