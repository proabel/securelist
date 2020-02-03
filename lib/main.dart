import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securelist/providers/dbService.dart';
import './pages/authPage.dart';
import './pages/listPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DbService>(builder: (_)=> DbService(),)
      ],
      child: MaterialApp(
        title: 'SecureList',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          primaryColor: const Color(0xFF795548),
          accentColor: const Color(0xFF32a6f9),
          canvasColor: const Color(0xFFfafafa),
        ),
        routes: {
          '/': (context) => ListPage(),
          '/list': (context) => ListPage()
        }
      ),
    );
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     // This is the theme of your application.
    //     //
    //     // Try running your application with "flutter run". You'll see the
    //     // application has a blue toolbar. Then, without quitting the app, try
    //     // changing the primarySwatch below to Colors.green and then invoke
    //     // "hot reload" (press "r" in the console where you ran "flutter run",
    //     // or simply save your changes to "hot reload" in a Flutter IDE).
    //     // Notice that the counter didn't reset back to zero; the application
    //     // is not restarted.
    //     primarySwatch: Colors.brown,
    //     primaryColor: const Color(0xFF795548),
    //     accentColor: const Color(0xFF32a6f9),
    //     canvasColor: const Color(0xFFfafafa),
    //   ),

    // );
  }
}


