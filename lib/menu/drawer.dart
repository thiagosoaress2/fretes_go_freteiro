import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/pages/new_login_page.dart';
import 'file:///C:/Users/Thiago/flutterProjectsII/fretes_go_freteiro/lib/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/avaliation_page.dart';
import 'package:fretes_go_freteiro/pages/help_page.dart';
import 'package:fretes_go_freteiro/pages/historic_page.dart';
import 'package:fretes_go_freteiro/pages/move_day_page.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';

class MenuDrawer extends StatefulWidget {

  @override
  _MenuDrawerState createState() => _MenuDrawerState();
}



Widget ImageProfile (String url){

  return Container(

    height: 200,


    child:  CachedNetworkImage(
      imageUrl: url,
      fadeInDuration: Duration(milliseconds: 1000) ,
      placeholder: (context, url) => Container( child: Center(child: CircularProgressIndicator(),),),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fill,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),),

  );
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
                    children: [


                      DrawerHeader(  //cabeçalho
                        child: Align(
                          alignment: Alignment.center,
                          //child:Text(userModel.Uid != "" ? userModel.FullName : "Você não está logado"),
                          //child: WidgetsConstructor().makeSimpleText(userModel.Uid != "" ? userModel.FullName : "Você não está logado", Colors.white, 15.0),
                          //child: userModel.Uid == '' ? WidgetsConstructor().makeSimpleText("Você não está logado", Colors.white, 15.0) : userModel.Image != '' ? CircleAvatar(radius: 130.0, backgroundColor: Colors.white, child: CircleAvatar(radius: 120.0, backgroundImage: NetworkImage(userModel.Image)), ) : WidgetsConstructor().makeSimpleText(userModel.Apelido, Colors.white, 15.0)
                            child: userModel.Uid == '' ? WidgetsConstructor().makeSimpleText("Você não está logado", Colors.white, 15.0) : userModel.Image != '' ? ImageProfile(userModel.Image)  : WidgetsConstructor().makeSimpleText(userModel.Apelido, Colors.white, 15.0)
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                      ),

                      InkWell( //só exibir o botão de loggin se não estiver logado
                        onTap: (){ //click

                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => NewLoginPage(1)));

                        },
                        child: userModel.Uid == "" ? Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: _drawLine(Icons.person, "Login", Theme.of(context).primaryColor, context),
                        ) : Container(),
                      ),


                      //preencher informações
                      userModel.Uid != '' ? InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                          Navigator.of(context).pop();
                          Navigator.push(context, MaterialPageRoute(
                          builder: (context) => TruckerInfosCadUserInfo()));

                          });
                        },
                        child: Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.info, "Preencher informações", Theme.of(context).primaryColor, context),),

                      ) : Container(),

                      //extrato
                      userModel.Uid != '' ? InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => HistoricPage(userModel.Uid)));

                          });
                        },
                        child: Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.assessment, "Extrato", Theme.of(context).primaryColor, context),),

                      ) : Container(),

                      //ajuda
                      userModel.Uid != '' ? InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => HelpPage()));

                          });
                        },
                        child: Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.help, "Ajuda", Theme.of(context).primaryColor, context),),

                      ) : Container(),

                      //logout
                      userModel.Uid != '' ? InkWell( //toque com animação
                        onTap: (){ //click
                          setState(() {

                            SharedPrefsUtils().clearPrefs();
                            userModel.updateUid("");
                            newAuthService.SignOut();
                            newAuthService.updateAuthStatus(false);
                            Navigator.of(context).pop();


                          });
                        },
                        child: Container(margin: EdgeInsets.only(left: 20.0), child:_drawLine(Icons.exit_to_app, "Sair desta conta", Theme.of(context).primaryColor, context),),

                      ) : Container(),


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
