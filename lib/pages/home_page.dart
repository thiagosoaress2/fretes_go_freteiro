import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/pages/email_verify_view.dart';
import 'file:///C:/Users/Thiago/flutterProjectsII/fretes_go_freteiro/lib/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/menu/drawer.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  //FirebaseAuth mAuth = FirebaseAuth.instance;
  //FirebaseUser firebaseUser;

  FirebaseAuth auth = FirebaseAuth.instance;
  bool userIsLoggedIn=false;
  bool loadingController=false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  
  UserModel userModelGLobal;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        userModelGLobal = userModel;
        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {

            if(loadingController==false){
              checkUserStatus(userModel, newAuthService);
            }

            return Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add_circle, size: 50.0,), onPressed: goToRegEntrepeneurPage,),
                appBar: AppBar(title: WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),
                  backgroundColor: Colors.blue,
                  centerTitle: true,
                ),
                drawer: MenuDrawer(),
                body: Center(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        userModel.Uid != "" ? Text("Logado") : Text("Nao logado"),
                        Center(
                            child: InkWell(
                              onTap: (){


                                if(userModel.Uid != ""){

                                  /*
                                  Navigator.of(context).pop();
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => SelectItensPage()));

                                   */

                                } else {
                                  _displaySnackBar(context, "Você precisa fazer login para acessar");
                                }


                              },
                              child: Container(
                                width: 250.0,
                                height: 250.0,
                                padding: const EdgeInsets.all(20.0),//I used some padding without fixed width and height
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,// You can use like this way or like the below line
                                  //borderRadius: new BorderRadius.circular(30.0),
                                  color: Colors.redAccent,
                                ),
                                child: Center(
                                    child: Text("Quero me mudar", textAlign: TextAlign.center, style:TextStyle(color: Colors.white, fontSize: 30.0),
                                    )// You can add a Icon instead of text also, like below.
                                  //child: new Icon(Icons.arrow_forward, size: 50.0, color: Colors.black38)),
                                ),//..........
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                )
            );
          },
        );
      },
    );
  }

  goToRegEntrepeneurPage(){



  }

  void isLoggedIn(UserModel userModel) async {

    /*
    firebaseUser = await AuthService(mAuth).isLoggedIn();
    if(firebaseUser != null){

      bool isVerify = await AuthService(mAuth).checkEmailVerify(firebaseUser);

      //verifica primeiro se já tem e-mail verificado
      if(isVerify == true){
        AuthService(mAuth).updateUserInfo(userModel); //carrega os dados
      } else {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => EmailVerify()));
      }


    }

     */

  }

  @override
  void initState() {
    super.initState();

  }

  void loadInitialData(){

  }

  void isUserLoggedIn() {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {

        userIsLoggedIn=false;

      } else {

        userIsLoggedIn = true;


      }
    });
  }

  void loadUserData(UserModel userModel, NewAuthService newAuthService){

    if(newAuthService.AuthStatus==true){
      if(newAuthService.isUserEmailVerified()==true){
        updateUserInfo(userModel, newAuthService, context);
      } else {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => EmailVerify()));
      }
    }
  }

  Future<void> checkUserStatus(UserModel userModel, NewAuthService newAuthService) async {

    await newAuthService.checkFBconnection();
    if(newAuthService.AuthStatus==true){
      newAuthService.loadUser(); //carrega o firebase user na model. Para acessar use getFirebaseUser
    }
    loadUserData(userModel, newAuthService);
    loadingController=true;

  }

  _displaySnackBar(BuildContext context, String msg) {

    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: "Ok",
        onPressed: (){
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void updateUserInfo(UserModel userModel, NewAuthService newAuthService, BuildContext context) async {
    var _uid = userModel.Uid;
    if(_uid !=""){
      //ja foram carregados os dados.
      print("valor uid é "+userModel.Uid);
      userModelGLobal = userModel;
    } else {
      User user = newAuthService.getFirebaseUser;
      userModel.updateUid(user.uid);
      await FirestoreServices().getUserInfoFromCloudFirestore(userModel, () {_userIsOk(); }, () {_userNotReg(context); },);

      //aqui precisa carregar o resto dos dados mas ainda n to mexendo no firestore
      //precisamos carregar os dados do user. Inicialmente pegamos do firestore...depois talvez pegaremos do sharedprefs
      //FirebaseUser firebaseUser = await _auth.currentUser();
      //FirestoreServices().loadCurrentUserData(firebaseUser, _auth, userModel);
    }


  }


  Future<void> _userIsOk() async {
    //user já fez o cadastro de freteiro
    print('find user');
    //agora vamos ver se já concluiu o cadastro
    await FirestoreServices().getUserInfoCheckWhatIsMissing(userModelGLobal, () {goToPage2OfUserInfos(context); }, () {goToPage3OfUserInfos(context); });

  }

  void _userNotReg(BuildContext context){
    //tem que fazer o cadastro de freteiro
    print("falta cadastro");
    goToPage1OfUserInfos(context);
  }

  void goToPage1OfUserInfos(BuildContext context){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TruckerInfosCadUserInfo()));
  }

  void goToPage2OfUserInfos(BuildContext context){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TruckerInfosCadInfoProfs()));
  }

  void goToPage3OfUserInfos(BuildContext context){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TruckerInfosCadCarInfo()));
  }

}







