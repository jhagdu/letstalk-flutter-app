//Importing Required Module
import 'package:flutter/material.dart';

//Class for First Main Animation Screen
class MainAnimationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Color.fromRGBO(255, 195, 0, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Image(
              image: AssetImage('assets/gifs/ppr_plane2.gif'),
            ),
          ),
          Container(
            child: Text(
              'Let\'s Talk',
              textScaleFactor: 4,
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Text(
              'Stay Connected',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
