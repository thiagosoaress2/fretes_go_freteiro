import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

//https://www.youtube.com/watch?v=Q61d-Ag13eU
//login face
//https://pub.dev/packages/flutter_facebook_login/example
//https://developers.facebook.com/apps/591100448911207/settings/basic/?business_id=726448124758695

class NewLoginPage extends StatefulWidget {
  int sit;
  NewLoginPage(this.sit);
  //sit 1 é login normal. Sit 2 é o login já vindo para registrar

  @override
  _NewLoginPageState createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {

  final FirebaseAuth mAuth = FirebaseAuth.instance;
  User firebaseUser;

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  int sizeOfPassword=8;

  double _heightPercent;
  double _widthPercent;

  bool isLoading=false;
  bool _btnIsEnabled=true;

  bool _emailIsOk=false;
  bool _passwordIsOk=false;
  bool _nameIsOk=false;
  bool _emailRecoveryIsOk=false;
  FocusNode _emailFocusNode;
  FocusNode _passwordFocusNode;
  FocusNode _nameFocusNode;

  String _emailMsg='no';

  bool _passIsObscure=true;

  bool _showLoginScreen=true;
  bool _showNewUserScreen=false;
  bool _showLostPasswordScreen=false;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailRecoveryController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  //static final FacebookLogin facebookSignIn = new FacebookLogin(); migrado pra newAuthServices

  @override
  Widget build(BuildContext context) {


    print('sit abaixo');
    print(widget.sit);

    if(_heightPercent==null){
      _heightPercent = MediaQuery.of(context).size.height;
      _widthPercent = MediaQuery.of(context).size.width;

      if(widget.sit==2){
        setState(() {
          _showNewUserScreen=true;
          _showLoginScreen=false;
        });

      }
    }

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget widget, NewAuthService newAuthService){
            return Scaffold(
              key: _scaffoldKey,
              body: Container(
                height: _heightPercent,
                width: _widthPercent,
                color: CustomColors.blue,
                child:_showLoginScreen==true ? _loginScreen(newAuthService, userModel) : _showNewUserScreen==true ? _newUserScreen(newAuthService, userModel) : _showLostPasswordScreen==true ? _lostPassWordScreen(newAuthService) : Container(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _loginScreen(NewAuthService newAuthService, UserModel userModel){

    return  Stack(
      children: [

        //barra
        _whiteBarArtistic(0.28),

        //fundo branco de baixo
        _whiteBackground(0.42),

        Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  //SizedBox(height: _heightPercent*0.05,),
                  //_logo(),

                  SizedBox(height: _heightPercent*0.12,),

                  //texto saudação
                  _greetingsText(),

                  SizedBox(height: _heightPercent*0.19,),

                  //textfields
                  _buttonsWithbackgroundWhiteLogin(newAuthService, userModel),

                ],
              ),

            )),

        isLoading==true ? Center(
          child: CircularProgressIndicator(),
        ) : Container(),

        //back btn
        _arrowBack(),



      ],
    );

  }

  Widget _newUserScreen(NewAuthService newAuthService, UserModel userModel){

    return  Stack(
      children: [

        //barra
        _whiteBarArtistic(0.28),

        //fundo branco de baixo
        _whiteBackground(0.42),

        Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  //SizedBox(height: _heightPercent*0.05,),
                  //_logo(),

                  SizedBox(height: _heightPercent*0.12,),

                  //texto saudação
                  _greetingsText(),

                  SizedBox(height: _heightPercent*0.19,),

                  //textfields
                  _buttonsWithbackgroundWhiteNewUser(newAuthService, userModel),

                ],
              ),

            )),

        isLoading==true ? Center(
          child: CircularProgressIndicator(),
        ) : Container(),

        //back btn
        _arrowBack(),

      ],
    );

  }

  Widget _lostPassWordScreen(NewAuthService newAuthService){

    return  Stack(
      children: [

        //barra
        _whiteBarArtistic(0.28),

        //fundo branco de baixo
        _whiteBackground(0.42),

        Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: SingleChildScrollView(
              child: Column(
                children: [

                  //SizedBox(height: _heightPercent*0.05,),
                  //_logo(),

                  SizedBox(height: _heightPercent*0.12,),

                  //texto saudação
                  _greetingsText(),

                  SizedBox(height: _heightPercent*0.19,),

                  //textfields
                  _buttonsWithbackgroundWhiteLostPassword(newAuthService),

                ],
              ),

            )),

        isLoading==true ? Center(
          child: CircularProgressIndicator(),
        ) : Container(),

        //back btn
        _arrowBack(),

      ],
    );

  }

  Widget _arrowBack(){
    return Positioned(
        top: _heightPercent*0.08,
        left: _widthPercent*0.05,
        child: GestureDetector(
          onTap: (){
            _closePage();
          },
          child: Icon(Icons.arrow_back, color: Colors.white, size: 35,),
        )
    );

  }

  Widget _logo(){
    return Container(
      width: _widthPercent*0.20,
      height: _heightPercent*0.10,
      child: Center(
        child: FittedBox(
          child: Image.asset('images/logopure.png'),
          fit: BoxFit.fill,
        ),
      ),
    );

  }

  Widget _greetingsText(){

    return Center(
      child: Text(_showLoginScreen==true ? 'Bem vindo\nde volta' : _showNewUserScreen==true ? 'Primeira vez\npor aqui?' : 'Vamos recuperar\nsua senha!', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(4.0)),),

    );
  }

  Widget _whiteBarArtistic(double top){

    return Positioned(
      top: _heightPercent*top,
      left: 0.0,
      right: 0.0,
      child: Container(
          width: _widthPercent,
          height: _heightPercent*0.22,
          child: FittedBox(
            child: Image.asset('images/home/barrabranca.png'),
            fit: BoxFit.fill,
          )
      ),
    );
  }

  Widget _whiteBackground(double top){
    return Positioned(
      top: _heightPercent*top,
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        width: _widthPercent,
        color: Colors.white,
      ),
    );
  }

  Widget _btnLogin(){
    return Container(
      height: _heightPercent*0.07,
      width: _widthPercent*0.4,
      child: RaisedButton(
        color: _showLoginScreen==true ? CustomColors.blue : Colors.grey[300],
        child: Text('login', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
        onPressed: (){
          setState(() {
            _showLoginScreen=true;
            _showNewUserScreen=false;
            _showLostPasswordScreen=false;
          });
        },
      ),
    );
  }

  Widget _btnCriarConta(){
    return Container(
      height: _heightPercent*0.07,
      width: _widthPercent*0.4,
      child: RaisedButton(
        color: _showNewUserScreen==true ? CustomColors.blue : Colors.grey[300],
        child: Text('Criar conta', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
        onPressed: (){
          setState(() {
            _showNewUserScreen=true;
            _showLoginScreen=false;
            _showLostPasswordScreen=false;
          });
        },
      ),
    );
  }

  Widget _buttonsWithbackgroundWhiteLogin(NewAuthService newAuthService, UserModel userModel){
    return Container(
      width: _widthPercent,
      color: Colors.white,
      child: Column(
        children: [

          SizedBox(height: 10.0,),
          //linha com botões
          Row(
            children: [
              SizedBox(width: _widthPercent*0.08,),
              _btnLogin(),
              SizedBox(width: _widthPercent*0.04,),
              _btnCriarConta(),
              SizedBox(width: _widthPercent*0.08,),
            ],
          ),
          SizedBox(height: _heightPercent*0.02,),
          _textFieldslogin(),

          _esqueceuSenhaText(),

          SizedBox(height: _heightPercent*0.08,),
          _btnEntrar(newAuthService, userModel),
          //_ouEntreComFacebook(newAuthService, userModel),
        ],
      ),
    );
  }


  Widget _textFieldslogin(){
    return Container(
      width: _widthPercent*0.75,
      child: Focus(
        child: Column(
          children: [
            //email
            TextFormField(

              controller: _emailController,
              focusNode: _emailFocusNode,
              validator: (value){
                if(value.isEmpty){
                  return 'Informe o e-mail';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: 'E-mail cadastrado',
                labelText: 'E-mail',
                suffixIcon: _emailIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                ),
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,

            ),
            //password
            TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(sizeOfPassword),
                ],

                validator: (value){
                  if(value.isEmpty){
                    return 'Informe a senha';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Sua senha deve conter ${sizeOfPassword} dígitos',
                  labelText: 'Senha',
                  suffixIcon: _passwordIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.yellow, width: 2.0)
                  ),
                ),
                textInputAction: TextInputAction.done
            )

          ],
        ),
        onFocusChange: (hasFocus) {
          if(hasFocus) {

            print('ganhou focus');
          } else {

            if(!_emailController.text.contains('@')){
              _emailMsg = 'Ops, falta o simbolo @';
            } else if(!_emailController.text.contains('.com')){
              _emailMsg = 'Algo errado com o e-mail';
            } else {
              _emailMsg = 'no';
            }

          }
        },
      ),

      //editTextForEmail(emailController, 'E-mail', null),
    );
  }

  Widget _textFieldsNewUser(){
    return Container(
      width: _widthPercent*0.75,
      child: Focus(
        child: Column(
          children: [

            //nome
            TextFormField(

              controller: _nameController,
              focusNode: _nameFocusNode,
              validator: (value){
                if(value.isEmpty){
                  return 'Informe o seu nome';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: 'Nome completo',
                labelText: 'Nome completo',
                suffixIcon: _nameIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                ),
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,

            ),
            //email
            TextFormField(

              controller: _emailController,
              focusNode: _emailFocusNode,
              validator: (value){
                if(value.isEmpty){
                  return 'Informe o e-mail';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: 'E-mail',
                labelText: 'E-mail',
                suffixIcon: _emailIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                ),
              ),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,

            ),
            //password
            TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _passIsObscure,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(sizeOfPassword),
                ],

                validator: (value){
                  if(value.isEmpty){
                    return 'Informe a senha';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Sua senha deve conter ${sizeOfPassword} dígitos',
                  labelText: 'Senha',
                  suffixIcon: _passwordIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.yellow, width: 2.0)
                  ),
                ),
                textInputAction: TextInputAction.done
            ),

            Row(
              children: [

                Checkbox(value: !_passIsObscure, onChanged: (value) {
                  setState(() {
                    _passIsObscure=!_passIsObscure;
                  });}),
                Text('Mostrar senha', textAlign: TextAlign.center , style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),

              ],
            ),

          ],
        ),
        onFocusChange: (hasFocus) {
          if(hasFocus) {

            print('ganhou focus');
          } else {

            if(!_emailController.text.contains('@')){
              _emailMsg = 'Ops, falta o simbolo @';
            } else if(!_emailController.text.contains('.com')){
              _emailMsg = 'Algo errado com o e-mail';
            } else {
              _emailMsg = 'no';
            }

          }
        },
      ),

      //editTextForEmail(emailController, 'E-mail', null),
    );
  }

  Widget _textFieldsLostPass(){
    return Container(
      width: _widthPercent*0.75,
      child: Focus(
        child: Column(
          children: [

            //email
            TextFormField(

              controller: _emailRecoveryController,
              validator: (value){
                if(value.isEmpty){
                  return 'Informe o e-mail';
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: 'Informe o e-mail',
                labelText: 'E-mail de recuperação',
                suffixIcon: _emailRecoveryIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

                ),
              ),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.emailAddress,
            ),


          ],
        ),
        onFocusChange: (hasFocus) {
          if(hasFocus) {

            print('ganhou focus');
          } else {

            print('perdeu focus');
            if(!_emailController.text.contains('@')){
              _emailMsg = 'Ops, falta o simbolo @';
            } else if(!_emailController.text.contains('.com')){
              _emailMsg = 'Algo errado com o e-mail';
            } else {
              _emailMsg = 'no';
            }

          }
        },
      ),

      //editTextForEmail(emailController, 'E-mail', null),
    );
  }

  Widget _buttonsWithbackgroundWhiteNewUser(NewAuthService newAuthService, UserModel userModel){
    return Container(
      width: _widthPercent,
      color: Colors.white,
      child: Column(
        children: [

          SizedBox(height: 10.0,),
          //linha com botões
          Row(
            children: [
              SizedBox(width: _widthPercent*0.08,),
              _btnLogin(),
              SizedBox(width: _widthPercent*0.04,),
              _btnCriarConta(),
              SizedBox(width: _widthPercent*0.08,),
            ],
          ),
          SizedBox(height: _heightPercent*0.02,),

          _textFieldsNewUser(),

          SizedBox(height: _heightPercent*0.03,),

          _btnRegistrar(newAuthService, userModel),

        ],
      ),
    );
  }

  Widget _buttonsWithbackgroundWhiteLostPassword(NewAuthService newAuthService){
    return Container(
      width: _widthPercent,
      color: Colors.white,
      child: Column(
        children: [

          SizedBox(height: 10.0,),
          //linha com botões
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: _widthPercent*0.035,),
              CloseButton(
                color: CustomColors.blue,
                onPressed: (){
                  setState(() {
                    _showLoginScreen=true;
                    _showNewUserScreen=false;
                    _showLostPasswordScreen=false;
                  });

                },
              )
            ],
          ),
          SizedBox(height: _heightPercent*0.02,),

          Padding(
              padding: EdgeInsets.all(_widthPercent*0.05),
              child: Text('Informe abaixo o e-mail cadastrado para recuperar a senha. Verifique sua caixa de spam.', textAlign: TextAlign.center , style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(1.8)),),
          ),

          _textFieldsLostPass(),

          SizedBox(height: _heightPercent*0.08,),

          _btnReenviarEmail(newAuthService),

        ],
      ),
    );
  }

  Widget _esqueceuSenhaText(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: (){
            setState(() {
              _showLostPasswordScreen=true;
              _showNewUserScreen=false;
              _showLoginScreen=false;
            });
          },
          child: Column(
            children: [
              SizedBox(height: _heightPercent*0.02,),
              Text('Esqueceu a senha?', textAlign: TextAlign.center , style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
              SizedBox(height: _heightPercent*0.005,),
            ],
          ),
        ),

        SizedBox(width: _widthPercent*0.11,),
      ],
    );
  }

  Widget _btnEntrar(NewAuthService newAuthService, UserModel userModel){
    return Container(
      width: _widthPercent*0.40,
      height: _heightPercent*0.10,
      child: RaisedButton(
        color: CustomColors.yellow,
        onPressed: (){
          _entrarClick(newAuthService, userModel);
        },
        child: Text('Entrar', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.5)),),
      ),
    );
  }

  Widget _ouEntreComFacebook(NewAuthService newAuthService, UserModel userModel){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        SizedBox(height: _heightPercent*0.01,),
        Text('Ou', textAlign: TextAlign.center , style: TextStyle(color: Colors.blueGrey, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
        SizedBox(height: _heightPercent*0.01,),

        Container(
        width: _widthPercent*0.8,
        height: _heightPercent*0.08,
        child: RaisedButton(
          onPressed: (){
            _facebookLoginClick(newAuthService, userModel);
          },
          color: CustomColors.facebookblue,
          child: Text('Entre com Facebook', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
          ),
        ),

    ],

    );
  }

  Widget _btnRegistrar(NewAuthService newAuthService, UserModel userModel){
    return Container(
      width: _widthPercent*0.4,
      height: _heightPercent*0.08,
      child: RaisedButton(
        color: CustomColors.yellow,
        onPressed: (){
          _RegistrarClick(newAuthService, userModel);
        },
        child: Text('Registrar', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
      ),
    );
  }

  Widget _btnReenviarEmail(NewAuthService newAuthService){
    return Container(
      width: _widthPercent*0.6,
      height: _heightPercent*0.10,
      child: RaisedButton(
        color: CustomColors.yellow,
        onPressed: (){
          _recoverPasswordClick(newAuthService);
        },
        child: Text('Enviar e-mail', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
      ),
    );
  }

  /*
  Widget _logo(){
    return Positioned(
        top: _heightPercent*0.08,
        left: _widthPercent*0.41,
        right: _widthPercent*0.41,
        child: Center(
          child: FittedBox(
            child: Image.asset('images/logopure.png'),
            fit: BoxFit.fill,
          ),
        ),
    );

  }

  Widget _greetingsText(double top){

    return Positioned(
      top: _heightPercent*top,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: Text(_isItALogin==true ? 'Bem vindo\nde volta' : 'Novo usuário', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(4.5)),),
      )
    );
  }

  Widget _whiteBarArtistic(double top){

    return Positioned(
      top: _heightPercent*top,
      left: 0.0,
      right: 0.0,
      child: Container(
          width: _widthPercent,
          height: _heightPercent*0.22,
          child: FittedBox(
            child: Image.asset('images/home/barrabranca.png'),
            fit: BoxFit.fill,
          )
      ),
    );
  }

  Widget _whiteBackground(double top){
    return Positioned(
      top: _heightPercent*top,
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
          width: _widthPercent,
          color: Colors.white,
      ),
    );
  }

  Widget _btnLogin(double top){
    return Positioned(
      top: _heightPercent*top,
      left: _widthPercent*0.08,
      child: Container(
        height: _heightPercent*0.07,
        width: _widthPercent*0.4,
        child: RaisedButton(
          color: _isItALogin==true ? CustomColors.blue : Colors.grey[300],
          child: Text('login', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
          onPressed: (){
            setState(() {
              _isItALogin=true;
            });
          },
        ),
      ),
    );
  }

  Widget _btnCriarConta(double top){
    return Positioned(
      top: _heightPercent*top,
      right: _widthPercent*0.08,
      child: Container(
        height: _heightPercent*0.07,
        width: _widthPercent*0.4,
        child: RaisedButton(
          color: _isItALogin==false ? CustomColors.blue : Colors.grey[300],
          child: Text('Criar conta', textAlign: TextAlign.center , style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
          onPressed: (){
            setState(() {
              _isItALogin=false;
            });
          },
        ),
      ),
    );
  }

  Widget _emailTextField(double top){

    return Container(
      height: _heightPercent*0.29,
      width: _widthPercent*0.75,
      child: Focus(
        child: TextFormField(

          controller: _emailController,
          focusNode: _emailFocusNode,
          validator: (value){
            if(value.isEmpty){
              return 'Informe o e-mail';
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            hintText: 'E-mail cadastrado',
            labelText: 'E-mail',
            suffixIcon: _emailIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,

        ),
        onFocusChange: (hasFocus) {
          if(hasFocus) {

            print('ganhou focus');
          } else {

            if(!_emailController.text.contains('@')){
              _emailMsg = 'Ops, falta o simbolo @';
            } else if(!_emailController.text.contains('.com')){
              _emailMsg = 'Algo errado com o e-mail';
            } else {
              _emailMsg = 'no';
            }

          }
        },
      ),

      //editTextForEmail(emailController, 'E-mail', null),
    );
  }

  Widget _passwordTextField(double top){

    return Container(
      height: _heightPercent*0.29,
      width: _widthPercent*0.75,
      child: Focus(
        child: TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: true,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
            ],

            validator: (value){
              if(value.isEmpty){
                return 'Informe a senha';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Sua senha deve conter 6 dígitos',
              labelText: 'Senha',
              suffixIcon: _passwordIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: CustomColors.yellow, width: 2.0)
              ),
            ),
            textInputAction: TextInputAction.done
        ),

      ),
      //editTextForEmail(emailController, 'E-mail', null),
    );
  }

*/

  /*
  Widget _emailTextField(double top){

    return Positioned(
        top: _heightPercent*top,
        right: _widthPercent*0.085,
      left: _widthPercent*0.085,
        child: Container(
      height: _heightPercent*0.29,
      width: _widthPercent*0.75,
      child: Focus(
        child: TextFormField(

          controller: _emailController,
          focusNode: _emailFocusNode,
          validator: (value){
            if(value.isEmpty){
              return 'Informe o e-mail';
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            hintText: 'E-mail cadastrado',
            labelText: 'E-mail',
            suffixIcon: _emailIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CustomColors.yellow, width: 2.0),

            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,

        ),
        onFocusChange: (hasFocus) {
          if(hasFocus) {

            print('ganhou focus');
          } else {

            if(!_emailController.text.contains('@')){
              _emailMsg = 'Ops, falta o simbolo @';
            } else if(!_emailController.text.contains('.com')){
              _emailMsg = 'Algo errado com o e-mail';
            } else {
              _emailMsg = 'no';
            }

          }
        },
      ),
        ),
      //editTextForEmail(emailController, 'E-mail', null),
    );
  }

  Widget _passwordTextField(double top){

    return Positioned(
      top: _heightPercent*top,
      right: _widthPercent*0.085,
      left: _widthPercent*0.085,
      child: Container(
        height: _heightPercent*0.29,
        width: _widthPercent*0.75,
        child: Focus(
          child: TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: true,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
              ],

              validator: (value){
                if(value.isEmpty){
                  return 'Informe a senha';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Sua senha deve conter 6 dígitos',
                labelText: 'Senha',
                suffixIcon: _passwordIsOk==true ? Icon(Icons.done, color: CustomColors.yellow,) : null,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.yellow, width: 2.0)
                ),
              ),
              textInputAction: TextInputAction.done
          ),

      ),
      //editTextForEmail(emailController, 'E-mail', null),
    ),
    );
  }
   */

  //métodos
  @override
  void initState() {



    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();

    _emailController.addListener(() {
      if(_emailController.text.contains('@') && _emailController.text.contains('.com')){
        setState(() {
          _emailIsOk=true;
        });
      } else {
        setState(() {
          _emailIsOk=false;
        });
      }
    });

    _passwordController.addListener(() {
      if(_passwordController.text.length==sizeOfPassword){
        setState(() {
          _passwordIsOk=true;
          print('foi');
        });
      } else {
        setState(() {
          print('n foi');
          _passwordIsOk=false;
        });
      }
    });

    _nameController.addListener(() {
      if(_nameController.text.length>=5 && _nameController.text.contains(' ')){
       setState(() {
         _nameIsOk=true;
       });
      } else {
        setState(() {
          _nameIsOk=false;
        });
      }
    });

    _emailRecoveryController.addListener(() {
      if(_emailRecoveryController.text.contains('@') && _emailRecoveryController.text.contains('.com')){
        setState(() {
          _emailRecoveryIsOk=true;
        });
      } else {
        setState(() {
          _emailRecoveryIsOk=false;
        });
      }
    });

  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailRecoveryController.dispose();
    super.dispose();
  }

  void _closePage(){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
  }

  void _entrarClick(NewAuthService newAuthService, UserModel userModel){

    if(_passwordIsOk==false){
      _displaySnackBar(context, "Ops, verifique a senha. Ela deve possuir ${sizeOfPassword} dígitos.");
    } else if(_emailIsOk==false) {
      _displaySnackBar(context, "Ops, verifique o e-mail.");
    } else {
      setState(() {
        isLoading=true;
      });

      void _onSucess(){


        void _userExists(){

          isLoading = false;
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Achamos você. Redirecionando."), backgroundColor: Colors.blue, duration: Duration(seconds: 2),)
          );
          Future.delayed(Duration(seconds: 2)).then((_){
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => HomePage()));

          });


        }

        void _userDontExists(){
          setState(() {
            isLoading=false;
          });
          //se caiu aqui é pq o user não fez cadastro como motorista.
          _displaySnackBar(context, 'Este e-mail está sendo usado por um usuário no aplicativo de clientes. Você precisa de um novo cadastro com um outro e-mail.');
        }

        FirestoreServices().getUserInfoFromCloudFirestore(userModel, (){ _userExists();}, () { _userDontExists();});

      }

      void _onFailure(){
        setState(() {
          isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text(newAuthService.ErroLoginCode), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
        );

      }

      newAuthService.SignInWithEmailAndPassword(userModel, _emailController.text, _passwordController.text, () {_onSucess(); }, () {_onFailure(); });


    }

    }

  void _recoverPasswordClick(NewAuthService newAuthService){

    void _onSucess(){
      isLoading = false;
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Um e-mail com as instruções foi enviado para "+_emailRecoveryController.text), backgroundColor: Theme.of(context).primaryColor, duration: Duration(seconds: 5),)
      );
      setState(() {
        _showLoginScreen=true;
        _showNewUserScreen=false;
        _showLostPasswordScreen=false;
      });

    }

    void _onFailure(){
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Ops, algo deu errado. Verifique se o e-mail está correto e se possui conexão com a internet."), backgroundColor: Colors.red, duration: Duration(seconds: 10),)
      );

    }

    if(_emailRecoveryIsOk==true){
      newAuthService.recoverPassword(_emailRecoveryController.text, () {_onSucess(); }, () {_onFailure();});
    } else {
      _displaySnackBar(context, 'Ops, algo errado com o formato do e-mail');
    }

  }

  void _RegistrarClick(NewAuthService newAuthService, UserModel userModel){

    if(_passwordIsOk==false){
      _displaySnackBar(context, "Ops, verifique a senha. Ela deve possuir ${sizeOfPassword} dígitos.");
    } else if(_emailIsOk==false) {
      _displaySnackBar(context, "Ops, verifique o e-mail.");
    } else if(_nameIsOk==false) {
      _displaySnackBar(context, "Precisamos do seu nome.");
    } else if(_btnIsEnabled==false){
      //travar para nao criar dois;
    } else {
      _btnIsEnabled=false;

      setState(() {
        isLoading=true;
      });

      void _onSucess(){
        isLoading = false;
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Pronto! Redirecionando."), backgroundColor: Colors.blue, duration: Duration(seconds: 2),)
        );
        Future.delayed(Duration(seconds: 2)).then((_){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => HomePage()));

        });

      }

      void _onFailure(){
        setState(() {
          isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text(newAuthService.ErroLoginCode), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
        );

      }

      void _onFailure_unknown(){
        setState(() {
          isLoading = false;
        });
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Ocorreu um erro"), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
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

        isLoading = false;

        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Este e-mail já está em uso. Redirecionando para o login."), backgroundColor: Colors.red, duration: Duration(seconds: 5),)
        );

        Future.delayed(Duration(seconds: 2)).then((_){

          _passwordController.text='';
          setState(() {
            _showLoginScreen=true;
            _showLostPasswordScreen=false;
            _showNewUserScreen=false;
          });

        });

      }

      newAuthService.SignUpNewUserWithEmailAndPassword(userModel, _nameController.text, _emailController.text, _passwordController.text, () {_onSucess(); }, () {_onFailure_unknown();}, () {_onFailure_weakPass(); }, () {_onFailure_userAlreadyExists(); },);

    }
  }

  void _facebookLoginClick(NewAuthService newAuthService, UserModel userModel){



    setState(() {
      isLoading==true;
    });

    void onSucess(){

      //conectou no face e firebase. Agora vamos verificar se o usuário já existe ou se é novo
      void _userExists(){

        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Achamos você. Redirecionando."), backgroundColor: Colors.blue, duration: Duration(seconds: 2),)
        );

        void _finishUserLoginFlow(){
          Future.delayed(Duration(seconds: 2)).then((_){
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => HomePage()));

          });
        }

        newAuthService.CompleteFacebookUserSignIn(userModel, () {_finishUserLoginFlow(); });

      }

      void _userDontExists(){
        //criar novo usuario

        void onSucessCreateNewUser(){
          //usuario novo criado no firebase com dados do facebook.

          _displaySnackBar(context, "Tudo pronto, redirecionando para a página principal");
          Future.delayed(Duration(seconds: 2)).then((_){
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => HomePage()));

          });


        }
        newAuthService.CreateNewFacebookUser(userModel, () {onSucessCreateNewUser(); });
      }

      FirestoreServices().getUserInfoFromCloudFirestore(userModel, (){ _userExists();}, () { _userDontExists();});

    }

    void  onFailureUserCancel(){
      //usuario cancelou no meio
      _displaySnackBar(context, 'Você cancelou o login');
      setState(() {
        isLoading=false;
      });
    }

    void onFailureUnknwon(){
      //erro desconhecido
      _displaySnackBar(context, 'Ocorreu um erro');
      setState(() {
        isLoading=false;
      });
    }

    void newUser(){
      //é um novo usuario
    }

    void onFailureInFireBase(){
      //erro no firebase, talvez seja um e-mail já em uso
      _displaySnackBar(context, 'Este e-mail já está vinculado a um cliente. Por favor utilize outro');
      setState(() {
        isLoading=false;
      });
    }

    newAuthService.SignInWithFacebook(userModel, () { onSucess();}, () { onFailureUserCancel;}, () {onFailureUnknwon; }, () {newUser();}, () { onFailureInFireBase();});


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
