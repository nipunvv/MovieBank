import 'package:flutter/material.dart';

class TopBarContents extends StatefulWidget {
  final double opacity;

  TopBarContents(this.opacity);

  @override
  _TopBarContentsState createState() => _TopBarContentsState();
}

class _TopBarContentsState extends State<TopBarContents> {
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
                          showCursor: false,
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
                            print('SEARCHING');
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
