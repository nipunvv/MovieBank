import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/screens/movie_detail.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:http/http.dart' as http;

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  final myController = TextEditingController();
  List<Movie> results = [];
  bool isSearching = false;

  searchMovies(String keyword) async {
    setState(() {
      isSearching = true;
    });
    String url = "${TMDB_API_URL}search/movie?query=$keyword";
    final response = await http.get(
      Uri.parse(url),
      headers: {HttpHeaders.authorizationHeader: "Bearer $TMDB_API_KEY"},
    );

    if (response.statusCode == 200) {
      List<Movie> movies = [];
      Movie m;
      for (Map<String, dynamic> movie in jsonDecode(response.body)['results']) {
        m = Movie.fromJson(movie);
        if (m.releaseDate != '' && m.posterPath != '') movies.add(m);
      }

      setState(() {
        isSearching = false;
        results = movies;
      });
    } else {
      throw Exception('Failed to load Movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 1000),
        child: Container(
          height: 70,
          color: Color(0xff161b2e),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      'MOVIE BANK',
                      style: TextStyle(
                        color: Colors.blueGrey[100],
                        fontSize: 20,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 250,
                      height: 30,
                      child: Center(
                        child: TextField(
                          controller: myController,
                          showCursor: true,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            searchMovies(value);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 5.0,
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(left: 5),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: new CircleBorder(),
                          onTap: () {
                            searchMovies(myController.text);
                          },
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isSearching)
            Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          SizedBox(
            height: 50,
          ),
          if (!isSearching)
            results.length > 0
                ? CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.6,
                      viewportFraction: 0.2,
                      enlargeCenterPage: false,
                      enlargeStrategy: CenterPageEnlargeStrategy.scale,
                      disableCenter: false,
                      aspectRatio: 16 / 9,
                      initialPage: 0,
                      enableInfiniteScroll: results.length > 5 ? true : false,
                    ),
                    items: results.map((item) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetail(
                                      item,
                                    ),
                                  ),
                                );
                              },
                              child: Image.network(
                                "$TMDB_WEB_URL/w342/${item.posterPath}",
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  )
                : Center(
                    child: Text('No Results'),
                  ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 76,
        child: Footer(),
      ),
    );
  }
}
