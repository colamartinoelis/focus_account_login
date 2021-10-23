import 'package:flutter/material.dart';
import 'package:focus/Repositories/Repository.dart';
import 'package:focus/Screen/Autenticazione/LoginPage.dart';

import '../main.dart';

class HomePage extends StatelessWidget {
  static String routeName = "/homePage";
  void logout(BuildContext context) async {
    getIt.get<Repository>().session.logout();
    await Navigator.popAndPushNamed(context, LoginPage.routeName);
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: FutureBuilder(
          future: getIt.get<Repository>().user.getProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator());
            else {
              final user = snapshot.data;
              return Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                SizedBox(width: 15),
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: new Text(
                    user.fullName,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: -1),
                  ),
                  subtitle: Text(user.email, style: TextStyle(fontSize: 10)),
                )
              ]);
            }
          },
        ),
        actions: [
          new IconButton(icon: new Icon(Icons.logout), onPressed: ()=> logout
            (context)),
        ],
        elevation: 3,
      ),
      body: new Center(
        child: new Text("Body3"),
      ),
    );
  }
}
