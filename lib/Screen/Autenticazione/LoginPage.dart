import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:focus/main.dart';
import 'package:focus/Repositories/Repository.dart';
import 'package:focus/Screen/Autenticazione/AccountPage.dart';

import 'package:focus/Util/Validazione.dart';
import 'package:focus/Component/AppFormField.dart';
import 'package:focus/Component/PulsanteFocus.dart';

import '../HomePage.dart';

class LoginPage extends StatefulWidget {
  static String routeName = "/loginPage";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController pswController = new TextEditingController();

  // Variabili di stato per gestire eventuali errori di validazione del form.
  String errorEmail;
  String errorPsw;
  //Variabile di stato per indicare se Repository.login sta caricando
  bool isLoading = false;

  void onSubmitLogin(BuildContext context) async{
    final email = emailController.text.trim();
    final psw = pswController.text.trim();

    // Reset messaggi errore (altrimenti rimarrebbero anche se un campo fosse corretto)
    setState(() {
      errorEmail = null;
      errorPsw = null;
    });

    //validazione!!!
   final valid = validazione( (daValidare) {
      daValidare(email.isEmpty, () => setState(() => errorEmail = "Campo richiesto"));
      daValidare(email.isNotEmpty && !isValidEmail(email), () => setState(()
      => errorEmail = "Email NON valida"));
       daValidare(psw.isEmpty, ()=> setState(() => errorPsw = "Campo richiesto"));
      daValidare(psw.isNotEmpty && psw.length < 5 , ()=> setState(() =>
      errorPsw = "Password troppo corta, almeno 5 caratteri alfanimerici!"));
    } );

    if (!valid) return;
    try{
      setState(() => isLoading = true);
      await getIt.get<Repository>().user.login(email, psw);
      setState(() => isLoading = false);
      await Navigator.pushNamed(context, HomePage.routeName);

    }catch(error){
      print("errore nel login: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          new TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AccountPage.routeName),
            child: new Text(
              "Non hai ancora un "
              "account?",
              style: new TextStyle(color: Colors.black54),
            ),
          )
        ],
        elevation: 0,
      ),
      body: corpoCentrale(context),
    );
  }

  Widget corpoCentrale(BuildContext context) => new SingleChildScrollView(
        child: new Container(
          padding: EdgeInsets.all(10),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new SizedBox(
                height: 30,
              ),
              titolo(),
              new SizedBox(
                height: 10,
              ),
              sottotitolo(),
              new SizedBox(
                height: 40,
              ),
              formLogin(),
              new SizedBox(
                height: 40,
              ),
              new PulsanteFocus(
                child: isLoading ?
                new SizedBox(
                  width: 15,
                  height: 15,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      accentColor: Colors.white,
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                ):
                new Text("Login"),
                backgroundColor: Color(0xFF0661F1),
                onPressed: () => onSubmitLogin(context),
              ),
            ],
          ),
        ),
      );

  Widget titolo() => new Text(
        "Ben Ritornato!",
        style: new TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget sottotitolo() => new Text(
        "Inserisci le tue credenziali per continuare",
        style: new TextStyle(
          color: Colors.black38,
        ),
      );

  Widget formLogin() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new AppFormField(
            label: "Email",
            controller: emailController,
            iconaSx: Icons.person,
            hintText: "email",
            keyboardType: TextInputType.emailAddress,
            error: errorEmail,
          ),
          new SizedBox(height: 30),
          new AppFormField(
            label: "Password",
            controller: pswController,
            iconaSx: Icons.lock,
            hintText: "password",
            obscureText: true,
            error: errorPsw,
          ),
        ],
      );
}
