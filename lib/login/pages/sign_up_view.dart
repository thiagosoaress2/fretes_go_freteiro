import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/pages/sign_in_view.dart';
import 'file:///C:/Users/Thiago/flutterProjectsII/fretes_go_freteiro/lib/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/utils/widgets_auth.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:scoped_model/scoped_model.dart';


class SignUpView extends StatefulWidget {
  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {

  final FirebaseAuth mAuth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();

  bool isLoading = false;

  bool passwordIsOk = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  @override
  void initState() {
    passwordController.addListener((){
      if(passwordController.text == passwordConfirmationController.text && passwordController.text.length==6 ){
        setState(() {
          passwordIsOk=true;
        });
      }else{
        setState(() {
          passwordIsOk=false;
        });
      }

    });

    passwordConfirmationController.addListener((){
      if(passwordController.text == passwordConfirmationController.text && passwordConfirmationController.text.length==6 ){

        setState(() {
          passwordIsOk=true;
        });
      }else{
        setState(() {
          passwordIsOk=false;
        });
      }

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService){
            return Scaffold(
              appBar: AppBar(
                title: WidgetsConstructor().makeSimpleText("Login", Colors.white, 18.0),
                centerTitle: true,
              ),
              key: _scaffoldKey,
              body: ListView(
                children: [

                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          Padding(
                              padding: EdgeInsets.all(20.0),
                              child: WidgetsConstructor().makeFormEditText(nameController, "Nome completo (conforme documento)", 'Informe o nome')
                          ),

                          Padding(
                              padding: EdgeInsets.all(20.0),
                              child: WidgetsAuth().editTextForEmail(emailController, "E-mail", null)
                          ),

                          passwordIsOk == true
                              ? WidgetsConstructor().makeSimpleText("Esta senha está boa", Colors.blue, 12.0)
                              : Container(),

                          Padding(
                              padding: EdgeInsets.all(20.0),
                              child: WidgetsAuth().editTextForPassword(passwordController, "Senha", null)
                          ),

                          Padding(
                              padding: EdgeInsets.all(20.0),
                              child: WidgetsAuth().editTextForPassword(passwordConfirmationController, "Confirme a senha", null)
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30.0,),
                  Container(
                    child: RaisedButton(
                      color: Colors.lightBlue,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          if (passwordController.text.length <=5){
                            _displaySnackBar(context, "A senha deve conter pelo menos seis dígitos");
                          } else {
                            if (passwordController.text == passwordConfirmationController.text){
                              //register(() {_onSucess();}, () {_onFailure();});

                              /*
                             Map<String, dynamic> userData = {
                               "name" : nameController.text,
                               "email" : emailController.text,
                             };
                              */

                              //firebaseUser = AuthService(mAuth).signUp(userData, passwordController.text, userModel, () {_onSucess();}, () {_onFailure();});
                              newAuthService.SignUpNewUserWithEmailAndPassword(userModel, nameController.text, emailController.text, passwordController.text, () {_onSucess(); }, () {_onFailure_unknown();}, () {_onFailure_weakPass(); }, () {_onFailure_userAlreadyExists(); },);

                            } else {
                              _displaySnackBar(context, "As senhas informadas não são iguais");
                            }
                          }

                        }
                      },
                      child: Text('Registrar'),
                    ),
                  ),
                  isLoading==true ? WidgetsConstructor().makeLoading() : Container()
                ],
              ),
            );
          },
        );
      },
    );
  }


  //https://firebase.flutter.dev/docs/overview/


  void _onSucess(){
    /*
   setState(() {
     isLoading = false;
   });
  */

    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Usuário criado com sucesso!"), backgroundColor: Theme.of(context).primaryColor, duration: Duration(seconds: 2),)
    );
    Future.delayed(Duration(seconds: 2)).then((_){

      Navigator.of(context).pop();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TruckerInfosCadUserInfo())
      );

    });

  }

  void _onFailure_unknown(){
    setState(() {
      isLoading = false;
    });
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Ocorreu um erro. Você já possui uma conta? Faça login"), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
    );

  }

  void _onFailure_weakPass(){
    setState(() {
      isLoading = false;
    });
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Senha muito fraca."), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
    );

  }

  void _onFailure_userAlreadyExists(){
    setState(() {
      isLoading = false;
    });
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Este e-mail já está em uso. Redirecionando o login."), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
    );

    Future.delayed(Duration(seconds: 2)).then((_){

      Navigator.of(context).pop();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInView())
      );

    });

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

}

