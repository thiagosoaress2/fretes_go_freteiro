import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fretes_go_freteiro/models/cad_infos_model.dart';
import 'package:fretes_go_freteiro/models/home_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/utils/notificationHelper.dart';
import 'package:scoped_model/scoped_model.dart';

import 'login/services/new_auth_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  await initNotifications(flutterLocalNotificationsPlugin);

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
  HomeModel homeModel = HomeModel();
  CadInfosModel cadInfoModel = CadInfosModel();

  return ScopedModel<NewAuthService>(
      model: newAuthService,

      child: ScopedModel<UserModel>(
        model: userModel,

        child: ScopedModel<HomeModel>(
          model: homeModel,

          child: ScopedModel<CadInfosModel>(
            model: cadInfoModel,

            child: MaterialApp(

              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: [const Locale('pt', 'BR')],

              title: 'Fretes Go',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              //home: HomePage(),
              home: HomePage(), //inicie suas páginas aqui
            ),
          ),
        ),
      ),
  );
}


