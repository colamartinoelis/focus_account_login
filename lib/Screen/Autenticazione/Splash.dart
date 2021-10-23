import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:focus/Repositories/Repository.dart';
import 'package:focus/Component/PulsanteFocus.dart';
import 'package:focus/Screen/Autenticazione/LoginPage.dart';
import 'package:focus/Screen/HomePage.dart';
import 'package:focus/main.dart';


class Splash extends StatefulWidget {
  static String routeName = "/splash";

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await getIt.get<Repository>().session.init();
      bool isUserLogged = getIt.get<Repository>().session.isUserLogged();

      if (isUserLogged)
        await Navigator.popAndPushNamed(context, HomePage.routeName);
      else
        await Navigator.popAndPushNamed(context, LoginPage.routeName);
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: [
          new Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: new Image.asset(
              "assets/splashScreen.jpg",
              fit: BoxFit.cover,
            ),
          ),
          new Positioned(
            top: MediaQuery.of(context).size.height / 2,
            left: 0,
            right: 0,
            bottom: 0,
            child: new Container(
                color: Colors.white,
                child: new Padding(
                  padding: EdgeInsets.all(10),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text(
                        "Lavoriamo Insieme",
                        style: new TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -4),
                      ),
                      new SizedBox(
                        height: 20,
                      ),
                      new Text(
                        "Funziona tutto meglio quando si collabora",
                        style: new TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      new SizedBox(
                        height: 60,
                      ),
                      new PulsanteFocus(
                        child: componenteCircolareSplash(context),
                        backgroundColor: Colors.black87,
                        onPressed: () {},
                      ),
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

Widget componenteCircolareSplash(BuildContext context) => new SizedBox(
      height: 20,
      width: 20,
      child: new Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.white),
          child: new CircularProgressIndicator()),
    );
