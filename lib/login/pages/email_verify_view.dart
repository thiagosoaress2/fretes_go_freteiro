import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';


class EmailVerify extends StatefulWidget {
  @override
  _EmailVerifyState createState() => _EmailVerifyState();
}


class _EmailVerifyState extends State<EmailVerify> {


  bool isLoading=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double heightPercent = height*0.65;
    double widthPercent = width*95;




    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {
            return Scaffold(
              key: _scaffoldKey,
              body: Container(
                  color: CustomColors.blue,
                  height: height,
                  width: width,
                  child: Padding(
                    padding: EdgeInsets.all(width*0.10),
                    child:  Padding(
                      padding: EdgeInsets.all(10.0),
                      child:  Column(
                        children: [
                          SizedBox(height: heightPercent*0.05,),
                          Text('Verificação pendente', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                          SizedBox(height: heightPercent*0.05,),
                          Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.35,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Icon(Icons.email_outlined, color: Colors.white, size: 100,),
                                  top: 0.0,
                                  bottom: 0.0,
                                  left: 0.0,
                                  right: 0.0,
                                ),
                                Positioned(
                                    top: 0.0,
                                    right: 0.0,
                                    left: widthPercent*0.0024,
                                    child: Icon(Icons.error, color: Colors.redAccent,))
                              ],
                            ),
                          ),
                          SizedBox(height: heightPercent*0.10,),
                          isLoading==true ? WidgetsConstructor().makeLoading():
                          Text('Você precisa verificar seu e-mail para completar o registro', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2))),
                          SizedBox(height: heightPercent*0.05,),
                          Text("Um e-mail foi enviado para "+userModel.Email+" com um link para verificar sua conta. Geralmente o envio é imediato, mas se você não tiver recebido este e-mail dentro de poucos minutos, por favor verifique sua caixa de spam.", style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                          SizedBox(height: heightPercent*0.2,),
                          Container(
                            height: heightPercent*0.1,
                            width: widthPercent*0.4,
                            child: RaisedButton(
                              color: Colors.blue,
                              onPressed: (){
                                newAuthService.sendUserVerifyMail();
                                _displaySnackBar(context, "Um novo e-mail foi enviado. Caso não encontre, verifique a caixa de spam.", Colors.blue);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Reenviar e-mail', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2))),
                                  Icon(Icons.refresh, color: Colors.white,),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: heightPercent*0.05,),
                          Container(
                            height: heightPercent*0.15,
                            width: widthPercent*0.4,
                            child: RaisedButton(
                              color: CustomColors.yellow,
                              onPressed: (){

                                _displaySnackBar(context, "Verificando...", Colors.blue);
                                newAuthService.loadUser();
                                setState(() {
                                  isLoading=true;
                                });

                                _verify(newAuthService);

                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Já confirmei', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                                  Icon(Icons.done, color: Colors.white, size: 35,),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  )
              ),
            );
          },
        );
      },
    );
  }

  void _verify(NewAuthService newAuthService){

    newAuthService.loadUser();
    Future.delayed(Duration(seconds: 3)).then((_) {

      if(newAuthService.isUserEmailVerified()==true){
        _displaySnackBar(context, 'Confirmado! Redirecionando', Colors.blue);
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()));
      } else {
        //repetir o processo pra evitar o erro recorrente
        //antes dava erro mas ao clicar novamente ele encontrava . Agora vai fazer automático
        newAuthService.loadUser();

        if(newAuthService.isUserEmailVerified()==true){
          _displaySnackBar(context, 'Confirmado! Redirecionando', Colors.blue);
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => HomePage()));
        } else {
          _displaySnackBar(context, "O e-mail ainda não foi verificado. Verifique a caixa de spam caso não tenha recebido. Caso você já tenha confirmado, aguardo uns instantes e tente novamente'", Colors.red);
        }

      }

    });

  }



  _displaySnackBar(BuildContext context, String msg, Color color) {

    final snackBar = SnackBar(
      backgroundColor: color,
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

}
