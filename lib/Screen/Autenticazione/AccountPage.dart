import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:focus/Util/ImageResizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:focus/Repositories/Repository.dart';
import 'package:focus/Component/AppFormField.dart';
import 'package:focus/Component/PulsanteFocus.dart';
import 'package:focus/Model/PlanType.dart';
import 'package:focus/Screen/Autenticazione/LoginPage.dart';
import 'package:focus/Screen/HomePage.dart';
import 'package:focus/Util/Validazione.dart';

import 'package:focus/main.dart';

class AccountPage extends StatefulWidget {
  static String routeName = "/accountPage";

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isPremiumRegistrationActive = false;
  int activePageIndex = 0;
  PageController controllerPagina = new PageController();
  PlanType pianoSelezionato = PlanType.Base;

  final TextEditingController nomeController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController pswController = new TextEditingController();
  final TextEditingController pswConfermataController =
      new TextEditingController();

  String errorNome;
  String errorEmail;
  String errorPsw;
  String errorPswConfermata;
  final picker = new ImagePicker();
  File avatarFile; // Null di default. Contiene immagine scelta dall'utente
  // per il suo avatar.;

  Future immagineSelezionata() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        avatarFile = new File(pickedFile.path);
      } else {
        print("nessuna immagine selezionata");
      }
    });
  }

  void paginaSelezionata(int i) {
    setState(() => activePageIndex = i);
  }

  /* ALTRO METODO  *************************************/
  /*@override
  void initState() {
    super.initState();
    controllerPagina.addListener(
      () {
        setState(
          () => activePageIndex = controllerPagina.page.toInt(),
        );
      },
    );
  }

  @override
  void dispose() {
    controllerPagina.dispose();
    super.dispose();
  }*/
/********************************************/

  void onSubmitAccount() async {
    if (activePageIndex == 0) {
      final nome = nomeController.text.trim();
      final email = emailController.text.trim();
      final psw = pswController.text.trim();
      final pswConfermata = pswConfermataController.text.trim();

      setState(() {
        errorNome = null;
        errorEmail = null;
        errorPsw = null;
        errorPswConfermata = null;
      });

      // Validazione campi form
      final valid = validazione((daValidare) {
        daValidare(
            nome.isEmpty, () => setState(() => errorNome = "Campo richiesto"));
        daValidare(email.isEmpty,
            () => setState(() => errorEmail = "Campo richiesto"));
        daValidare(email.isNotEmpty && !isValidEmail(email),
            () => setState(() => errorEmail = "Email NON valida"));
        daValidare(
            psw.isEmpty, () => setState(() => errorPsw = "Campo richiesto"));
        daValidare(psw.isNotEmpty && psw.length < 5,
            () => setState(() => errorPsw = "Password troppo corta, almeno 5 "
                "caratteri alfanumerici!"));
        daValidare(
            pswConfermata.isEmpty,
            () => setState(() => errorPswConfermata = "Campo richiesto"));
        daValidare(
            psw.isNotEmpty && pswConfermata.isNotEmpty && psw != pswConfermata,
            () => setState(() => errorPswConfermata = "Le due password NON "
                "coincidono!"));
      });

      if (!valid) return;
      // Continua con registration: premium account
      if (isPremiumRegistrationActive && activePageIndex == 0) {
        controllerPagina.animateToPage(1,
            duration: new Duration(milliseconds: 200), curve: Curves.linear);
      } else {
        try {
          print("making http request to register");
          await getIt
              .get<Repository>()
              .user
              .register(nome, email, psw, avatarFile: avatarFile, planType:
          pianoSelezionato);

          await Navigator.popAndPushNamed(context, HomePage.routeName);
        } catch (error) {
          print("errore nella registrazione: $error");
        }
      }

    }
  }

  void getImage() async {
    // Lasciamo selezionare all'utente un file dalla galleria del dispositivo.
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final file = File(pickedFile.path);

    // Ora che abbiamo l'immagine che l'utente vuole usare come avatar non possiamo mandarla direttamente al server.
    // Questo perchè l'immagine potrebbe pesare anche parecchi MB e non ha assolutamente senso per un avatar: quindi dobbiamo ridimensionare l'immagine.
    //
    // Per fare questo (che è un operazione comunque intensiva, maneggiare una foto di 10MB per farla diventare una 300x300 non è mai un operazione da sottovalutare)
    // ci affidiamo al concetto di "Isolate" in dart: https://api.dart.dev/stable/2.10.2/dart-isolate/dart-isolate-library.html.
    //
    // Possiamo immaginare un Isolate come un Thread (o un Processo) separato da quello in cui gira l'App.
    // Ridimensionando l'immagine in questo processo in background avremmo il vantaggio di non bloccare il processo principale, e magari avere anche maggiore velocità di ridimensionamento (essendo che i telefoni moderni hanno diversi thread).
    //
    // Creiamo quindi questo "Isolate" (che poi in verità non è altro che una funzione che viene eseguita in background), e mandiamoli l'immagine da ridimensionare.
    // Quando la funzione avrà finito, otterremmo indietro l'immagine sotto forma di lista di byte (List<int>).
    //
    // Utilizziamo quindi il concetto di Completer (utlizzato anche in Flutter Advanced, nella sezione Google Maps) per bloccare l'esecuzione della funzione fino a quando
    // il processo non finisce.
    Completer<List<int>> completer = Completer<List<int>>();
    ReceivePort isolateToMainStream = ReceivePort();
    isolateToMainStream.listen((data) => completer.complete(data));

    await Isolate.spawn(
        imageResizerIsolate,
        ImageResizerData(
          sendPort: isolateToMainStream.sendPort,
          imageToResize: file,
          size: 300,
          quality: 70,
        ));

    // Infine, creiamo un file temporaneo con un nome univoco (ecco il motivo dell'uso del UUID) in cui salviamo fisicamente l'immagine ridimensionata ricevuta,
    // che poi useremmo per mandarla al server.
    final resizedFile = await completer.future;
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = path.join(tempDir.path, "${Uuid().v4()}.jpg");
    final fileImage = await File(tempFilePath).writeAsBytes(resizedFile);

    setState(() {
      avatarFile = fileImage;
    });
  }

  double prezzoPiano() {
    switch (pianoSelezionato) {
      case PlanType.Base:
        return 9.99;
      case PlanType.Avanzato:
        return 19.99;
      case PlanType.Premium:
        return 29.99;
      default:
        00.00;
    }
  }

  void attivaPianoInviaDati() {
    print("piano attivato ed invia dati al server");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          leading: activePageIndex == 0
              ? new Container(
                  color: Colors.transparent,
                )
              : new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () {
                    controllerPagina.animateToPage(0,
                        duration: new Duration(milliseconds: 200),
                        curve: Curves.linear);
                  }),
          actions: [
            new TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, LoginPage.routeName),
              child: new Text(
                "Hai già un account?",
                style: new TextStyle(color: Colors.black54),
              ),
            )
          ],
          elevation: 0,
        ),
        body: new PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => activePageIndex == 0
              ? corpoCentraleAccount()
              : premiumPage(context),
          itemCount: 2,
          controller: controllerPagina,
          onPageChanged: paginaSelezionata,
        ));
  }

  Widget corpoCentraleAccount() => new SingleChildScrollView(
        child: new Container(
          padding: EdgeInsets.all(10),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new SizedBox(
                height: 20,
              ),
              titolo(),
              new SizedBox(
                height: 10,
              ),
              sottotitolo(),
              new SizedBox(
                height: 40,
              ),
              immagineProfilo(),
              new SizedBox(
                height: 20,
              ),
              formLogin(),
              new SizedBox(
                height: 30,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.all(0),
                title: new Text("Registra un account premium"),
                value: isPremiumRegistrationActive,
                onChanged: (value) =>
                    setState(() => isPremiumRegistrationActive = value),
              ),
              new SizedBox(
                height: 40,
              ),
              pulsanteAccount(),
            ],
          ),
        ),
      );

  Widget titolo() => new Text(
        "Crea il tuo Account",
        style: new TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget sottotitolo() => new Text(
        "Inserisci i dati richiesti per creare il tuo account",
        style: new TextStyle(
          color: Colors.black38,
        ),
      );

  Widget immagineProfilo() => new Center(
        child: new GestureDetector(
          onTap: immagineSelezionata,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircleAvatar(
                                backgroundImage:
                    avatarFile == null ? null : new AssetImage(avatarFile
                        .path), // new FileImage(avatarFile),
                backgroundColor: Colors.grey[300],
                radius: 40,
              ),
              new SizedBox(
                height: 10,
              ),
              new Text(
                "Carica immagine",
                style: new TextStyle(color: Colors.black38),
              ),
            ],
          ),
        ),
      );

  Widget formLogin() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new AppFormField(
            label: "Nome",
            iconaSx: Icons.person,
            hintText: "nome",
            keyboardType: TextInputType.text,
            error: errorNome,
            controller: nomeController,
          ),
          new SizedBox(height: 30),
          new AppFormField(
              label: "Email",
              iconaSx: Icons.person,
              hintText: "email",
              keyboardType: TextInputType.emailAddress,
              error: errorEmail,
              controller: emailController),
          new SizedBox(height: 30),
          new AppFormField(
              label: "Password",
              iconaSx: Icons.lock,
              hintText: "password",
              keyboardType: TextInputType.text,
              obscureText: true,
              error: errorPsw,
              controller: pswController),
          new SizedBox(height: 30),
          new AppFormField(
            label: "Conferma Password",
            iconaSx: Icons.lock,
            hintText: "conferma password",
            keyboardType: TextInputType.text,
            obscureText: true,
            error: errorPswConfermata,
            controller: pswConfermataController,
          ),
        ],
      );

  Widget registraAccountPremium() => new SwitchListTile(
        contentPadding: EdgeInsets.all(0),
        title: new Text("Registra un account premium"),
        value: isPremiumRegistrationActive,
        onChanged: (value) =>
            setState(() => isPremiumRegistrationActive = value),
      );

  Widget pulsanteAccount() => new PulsanteFocus(
        child: new Text(isPremiumRegistrationActive
            ? "Personalizza il tuo "
                "account"
            : "Crea il tuo account"),
        backgroundColor: Color(0xFF0661F1),
        onPressed: onSubmitAccount,
      );

  Widget premiumPage(BuildContext context) => new SingleChildScrollView(
        child: new Container(
          padding: EdgeInsets.all(10),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              new SizedBox(
                height: 20,
              ),
              titoloPremium(),
              new SizedBox(
                height: 10,
              ),
              sottotitoloPremium(),
              new SizedBox(
                height: 40,
              ),
              pianiPremium(),
              pulsantePremium(),
            ],
          ),
        ),
      );

  Widget titoloPremium() => new Text(
        "Personalizza il tuo Piano",
        style: new TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget sottotitoloPremium() => new Text(
        "A secondo del piano scelto avrai diversi vantagi",
        style: new TextStyle(
          color: Colors.black38,
        ),
      );

  Widget pianiPremium() => new Column(
        children: [
          radioTile(
              title: "PianoBase",
              subtitle:
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
              tipoDiPiano: PlanType.Base),
          new SizedBox(
            height: 30,
          ),
          radioTile(
              title: "Piano Avanzato",
              subtitle: "Lorem ipsum dolor sit "
                  "amet, consectetur adipiscing elit, sed do eiusmod tempor",
              tipoDiPiano: PlanType.Avanzato),
          new SizedBox(
            height: 30,
          ),
          radioTile(
              title: "Piano Premium",
              subtitle:
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
              tipoDiPiano: PlanType.Premium),
          new SizedBox(
            height: 30,
          ),
        ],
      );

  Widget radioTile({
    @required String title,
    @required String subtitle,
    @required PlanType tipoDiPiano,
  }) =>
      new RadioListTile(
        dense: false,
        title: new Text(
          title,
          style: new TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: new Text(subtitle),
        value: tipoDiPiano,
        groupValue: pianoSelezionato,
        onChanged: (value) => setState(() => pianoSelezionato = value),
      );

  Widget pulsantePremium() => new PulsanteFocus(
        child: new Text("Attiva il tuo piano | € ${prezzoPiano()}"),
        backgroundColor: Color(0xFF0661F1),
        onPressed: attivaPianoInviaDati,
      );
}
