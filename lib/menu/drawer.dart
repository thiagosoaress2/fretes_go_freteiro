import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/pages/login_choose_view.dart';
import 'file:///C:/Users/Thiago/flutterProjectsII/fretes_go_freteiro/lib/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/move_day_page.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class MenuDrawer extends StatefulWidget {

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}



class _MenuDrawerState extends State<MenuDrawer> {

  //Future<User> user = AuthService().currentUser();
  //FirebaseAuth mAuth = FirebaseAuth.instance;
  //FirebaseUser firebaseUser;

  //bool loggedIn = false;
  Map<String, dynamic> userData = Map();


  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService){
            return Drawer(
                child: ListView(
                    padding:EdgeInsets.only(top: 16.0),
                    children: [
                      DrawerHeader(  //cabeçalho
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          //child:Text(userModel.Uid != "" ? userModel.FullName : "Você não está logado"),
                          child: WidgetsConstructor().makeSimpleText(userModel.Uid != "" ? userModel.FullName : "Você não está logado", Colors.white, 15.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),
                      InkWell( //só exibir o botão de loggin se não estiver logado
                        onTap: (){ //click

                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => LoginChooseView()));


                        },
                        child: userModel.Uid == "" ? Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: _drawLine(Icons.person, "Login", Theme.of(context).primaryColor, context),
                        ) : Container(),
                      ),
                      InkWell( //toque com animação
                        onTap: (){ //click

                          /*
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => SelectItensPage()));

                       */

                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: _drawLine(Icons.airport_shuttle, "Quero me mudar", Theme.of(context).primaryColor, context),
                        ),
                      ),

                      InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                            Navigator.of(context).pop();
                            newAuthService.SignOut();
                            newAuthService.updateAuthStatus(false);
                            SharedPrefsUtils().clearPrefs();

                            /*
                        //LoginModel().signOut();
                        AuthService(mAuth).signOut(userModel);
                        Navigator.of(context).pop();

                         */
                          });
                        },
                        child: userModel.Uid != "" ? Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.exit_to_app, "Sair da conta", Theme.of(context).primaryColor, context),) : Container(),

                      ),

                      InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                          builder: (context) => TruckerInfosCadUserInfo()));

                          });
                        },
                        child: Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.exit_to_app, "Preencher info trucker", Theme.of(context).primaryColor, context),),

                      ),

                      InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                            SharedPrefsUtils().clearPrefs();
                            userModel.updateUid("");
                            newAuthService.SignOut();
                            newAuthService.updateAuthStatus(false);


                          });
                        },
                        child: Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.exit_to_app, "Logout novo completo", Theme.of(context).primaryColor, context),),

                      ),


                    ]
                )
            );
          },
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    //isLoggedIn();
  }



}


Widget _drawLine(IconData icon, String text, Color color, BuildContext context){

  return Material(
    color: Colors.transparent,
    child: Column(
      children: <Widget>[
        Container(
          height: 60.0,
          child: Row(
            children: <Widget>[
              Icon(
                icon, size: 32.0,
                color : Theme.of(context).primaryColor,
              ),
              SizedBox(width: 32.0,),
              Text(
                text, style: TextStyle(fontSize: 16.0,
                color : Theme.of(context).primaryColor,

              ),
              ),
            ],
          ),
        ),
        Divider(),
      ],
    ),
  );

}
