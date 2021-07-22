import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movie_bank/constants/constants.dart';
import 'package:movie_bank/models/Movie.dart';
import 'package:movie_bank/screens/movie_detail.dart';
import 'package:movie_bank/widgets/footer.dart';
import 'package:http/http.dart' as http;
import 'package:movie_bank/widgets/search_bar.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<Movie> results = [];
  bool isSearching = false;
  String selectedGenre = 'Action';
  String selectedOrderBy = 'Popularity';
  String selectedRating = '9+';

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
        child: SearchBar(searchMovies),
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
            height: 10,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 30,
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                        borderSide: BorderSide(
                          color: Colors.blue.shade800,
                        ),
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 5.0,
                      ),
                      labelText: 'Query',
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: 30,
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          value: selectedGenre,
                          underline: SizedBox(),
                          style: TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.black,
                          isExpanded: true,
                          items: <String>[
                            'Action',
                            'Adventure',
                            'Animation',
                            'Comedy',
                            'Crime',
                            'Documentary',
                            'Drama',
                            'Family',
                            'Fantasy',
                            'History',
                            'Horror',
                            'Music',
                            'Mystery',
                            'Romance',
                            'Science Fiction',
                            'Thriller',
                            'TV Movie',
                            'War',
                            'Western',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          hint: Text(
                            "Select genre",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGenre = newValue!;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: 30,
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          value: selectedRating,
                          underline: SizedBox(),
                          style: TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.black,
                          isExpanded: true,
                          items: <String>[
                            '9+',
                            '8+',
                            '7+',
                            '6+',
                            '5+',
                            '4+',
                            '3+',
                            '2+',
                            '1+',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          hint: Text(
                            "Rating",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRating = newValue!;
                            });
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: 30,
                        margin: EdgeInsets.only(right: 5),
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                              borderSide:
                                  BorderSide(color: Colors.blue.shade800),
                            ),
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 5.0,
                            ),
                            labelText: 'Year',
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: 30,
                        margin: EdgeInsets.only(right: 5),
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          focusColor: Colors.white,
                          value: selectedOrderBy,
                          underline: SizedBox(),
                          style: TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.black,
                          isExpanded: true,
                          items: <String>[
                            'Popularity',
                            'Release date',
                            'Title',
                            'Rating',
                            'Vote count',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          hint: Text(
                            "Please choose a langauage",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedOrderBy = newValue!;
                            });
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.blue.shade600,
                        ),
                        child: IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.search),
                          onPressed: () {},
                        ),
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
