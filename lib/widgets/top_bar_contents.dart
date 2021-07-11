import 'package:flutter/material.dart';

class TopBarContents extends StatefulWidget {
  final double opacity;
  final Function searchMovies;

  TopBarContents(this.opacity, this.searchMovies);

  @override
  _TopBarContentsState createState() => _TopBarContentsState();
}

class _TopBarContentsState extends State<TopBarContents> {
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return PreferredSize(
      preferredSize: Size(screenSize.width, 1000),
      child: Container(
        color: Color(0xff161b2e).withOpacity(widget.opacity),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              if (widget.opacity == 1)
                Row(
                  children: [
                    Container(
                      width: 250,
                      height: 30,
                      child: Center(
                        child: TextField(
                          controller: myController,
                          showCursor: false,
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            widget.searchMovies(value);
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
                                vertical: 15.0, horizontal: 5.0),
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
                            widget.searchMovies(myController.text);
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
    );
  }
}
