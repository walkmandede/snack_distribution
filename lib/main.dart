import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:snack_distribution/homePage.dart';

void main() {
  // RenderErrorBox.backgroundColor = Colors.transparent;
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return MaterialApp(
      title: 'Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          caption: TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          bodyText1: TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          bodyText2: TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          button: TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          headline1:  TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          headline2:  TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          headline3:  TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          overline:  TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          subtitle1:  TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
          subtitle2:  TextStyle(
              fontSize: 14/MediaQuery.textScaleFactorOf(context)
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

