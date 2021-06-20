import 'package:flutter/material.dart';
import 'package:movie_bank/apis/api.dart';
import 'package:movie_bank/models/genre.dart';

class GenreProvider with ChangeNotifier {
  List<Genre> genres = [];
  bool loading = false;

  getPostData() async {
    loading = true;
    genres = await fetchGenres();
    loading = false;

    notifyListeners();
  }
}
