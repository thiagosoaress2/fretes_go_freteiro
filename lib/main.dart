import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:scoped_model/scoped_model.dart';

import 'login/services/new_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //inicia aqui o fireflutter
  runApp(MyApp());

}


class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _initialized = false;

  bool _error = false;

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if(_error) {
      return somethingGetWrong();
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Center(child: CircularProgressIndicator(),);
    }

    return myStartPage();
  }

}


Widget somethingGetWrong() {
  return Text("Algo errado com o fireFlutter");
}

Widget myStartPage(){

  NewAuthService newAuthService = NewAuthService();
  UserModel userModel = UserModel();

  return ScopedModel<NewAuthService>(
      model: newAuthService,

      child: ScopedModel<UserModel>(
        model: userModel,

        child: MaterialApp(
          title: 'Fretes Go',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          //home: HomePage(),
          home: HomePage(), //inicie suas páginas aqui
        ),
      ),
  );
}


