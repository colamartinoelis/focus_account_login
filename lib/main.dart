import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:focus/Repositories/Repository.dart';

import 'package:focus/Screen/Autenticazione/LoginPage.dart';
import 'package:focus/Screen/Autenticazione/AccountPage.dart';
import 'package:focus/Screen/Autenticazione/Splash.dart';
import 'package:focus/Screen/HomePage.dart';







final getIt = GetIt.instance;

void main() {
  getIt.registerSingleton<Repository>(Repository());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        Splash.routeName: (_) => new Splash(),
        LoginPage.routeName: (context) => new LoginPage(),
        AccountPage.routeName: (_) => new AccountPage(),
        HomePage.routeName: (_) => new HomePage(),
      },
      initialRoute: Splash.routeName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
      ),
    );
  }
}
