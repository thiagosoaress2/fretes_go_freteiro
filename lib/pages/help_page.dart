import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/avaliation_page.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

ScrollController _scrollController;


class _HelpPageState extends State<HelpPage> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  double heightPercent;
  double widthPercent;

  bool _showPerguntaFrequente=false;
  bool _showContacts=false;
  bool _showExcludePopup=false;

  bool _isLoading=false;

  bool _lockButton=false;

  @override
  Widget build(BuildContext context) {

    if(heightPercent==null){
      heightPercent = MediaQuery
          .of(context)
          .size
          .height;
      widthPercent = MediaQuery
          .of(context)
          .size
          .width;
    }

    return ScopedModelDescendant<UserModel>(
        builder: (BuildContext context, Widget child, UserModel userModel) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('Página de ajuda', style: TextStyle(color: CustomColors.blue),),
              centerTitle: true,
              automaticallyImplyLeading: true,
              leading: IconButton(icon: Icon(Icons.arrow_back, color: CustomColors.blue, size: 45,), onPressed: (){

                if(_lockButton==false){

                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => HomePage()));

                }

              },),
            ),
            key: _scaffoldKey,
            body: Container(
              width: widthPercent,
              height: heightPercent,
              child: Stack(
                children: [

                  ListView(
                    controller: _scrollController,
                    children: [
                      SizedBox(height: heightPercent*0.05,),
                      //container amarelo com texto explicativo
                      Padding(padding: EdgeInsets.all(widthPercent*0.05),
                        child: Container(
                          color: CustomColors.yellow,
                          child: Column(
                            children: [
                              Padding(padding: EdgeInsets.all(widthPercent*0.05), child: Text('Olá ${userModel.Apelido}, esta página é uma ferramenta de suporte. Aqui você pode encontrar as melhores formas de nos contactar.', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),),
                            ],
                          ),
                        ),),
                      SizedBox(height: heightPercent*0.05,),
                      //codigo do cliente
                      Text('Seu código de cliente:\n${userModel.Uid}', textAlign: TextAlign.center, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
                      SizedBox(height: heightPercent*0.02,),
                      //botão 1 - perguntas frequentes
                      Padding(padding: EdgeInsets.fromLTRB(widthPercent*0.10, widthPercent*0.10, widthPercent*0.10, 0.0),
                        child:Container(
                          child: RaisedButton(
                            color: CustomColors.blue,
                            onPressed: (){
                              setState(() {
                                _showPerguntaFrequente=!_showPerguntaFrequente;
                              });

                            },
                            child: Row(
                              children: [
                                Icon(Icons.list, color: Colors.white, size: 45,),
                                SizedBox(width: widthPercent*0.05,),
                                Text('Perguntas frequentes', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //parte de perguntas frequenstes
                      _showPerguntaFrequente== true ? Padding(padding: EdgeInsets.fromLTRB(widthPercent*0.10, 0.0, widthPercent*0.10, widthPercent*0.10),
                        child: Container(
                          child: _PerguntasFrequentes(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: CustomColors.blue,
                              width: 2.0, //                   <--- border width here
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2.0)),

                          ),
                        ),
                      ) : Container(),
                      //botão 2 - Nossos contatos
                      Padding(padding: EdgeInsets.fromLTRB(widthPercent*0.10, widthPercent*0.10, widthPercent*0.10, 0.0),
                        child:Container(
                          child: RaisedButton(
                            color: CustomColors.brown,
                            onPressed: (){
                              setState(() {
                                _showContacts = !_showContacts;
                              });

                            },
                            child: Row(
                              children: [
                                Icon(Icons.phone, color: Colors.white, size: 45,),
                                SizedBox(width: widthPercent*0.05,),
                                Text('Contatos', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //parte dos contatos
                      _showContacts== true ? Padding(padding: EdgeInsets.fromLTRB(widthPercent*0.10, 0.0, widthPercent*0.10, widthPercent*0.10),
                        child: Container(
                          child: _Contatos(),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: CustomColors.blue,
                              width: 2.0, //                   <--- border width here
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2.0)),

                          ),
                        ),
                      ) : Container(),
                      //botão 3 - Excluir conta
                      Padding(padding: EdgeInsets.fromLTRB(widthPercent*0.10, widthPercent*0.10, widthPercent*0.10, 0.0),
                        child:Container(
                          child: RaisedButton(
                            color: Colors.red,
                            onPressed: (){
                              setState(() {
                                _showExcludePopup=true;
                              });

                            },
                            child: Row(
                              children: [
                                Icon(Icons.delete_forever_rounded, color: Colors.white, size: 45,),
                                SizedBox(width: widthPercent*0.05,),
                                Text('Excluir conta', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //popup para exlcuir user
                  _showExcludePopup==true ? _ExcludePopup() : Container(),

                  _isLoading==true ? Center(child: CircularProgressIndicator(),) : Container(),

                ],
              ),
            ),
          );
    });

  }

  Widget _PerguntasFrequentes(){
    return Padding(padding: EdgeInsets.all(widthPercent*0.05),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CloseButton(
              onPressed: (){
                setState(() {
                  _showPerguntaFrequente=false;
                });
              },
            )
          ],
        ),
        SizedBox(height: heightPercent*0.05,),
        Text('Sem perguntas frequentes por enquanto', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
      ],
    ),
    );
  }

  Widget _Contatos(){
    return Padding(padding: EdgeInsets.all(widthPercent*0.05),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(
                onPressed: (){
                  setState(() {
                    _showContacts=false;
                  });
                },
              )
            ],
          ),
          SizedBox(height: heightPercent*0.05,),
          Text('Telefone: xxxxxxxxx', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
          SizedBox(height: heightPercent*0.02,),
          Text('Whatsapp: xxxxxxxxx', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
          SizedBox(height: heightPercent*0.02,),
          Text('E-mail: xxxx@xxx.com', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),

        ],
      ),
    );
  }

  Widget _ExcludePopup(){

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget widget, NewAuthService newAuthService){
            return Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: heightPercent*0.03,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CloseButton(
                        onPressed: (){
                          if(_lockButton==false){
                            setState(() {
                              _showExcludePopup=false;
                            });
                          }

                        },
                      ),
                    ],
                  ),

                  Container(
                    width: widthPercent*0.8,
                    height: heightPercent*0.15,
                    color: CustomColors.yellow,
                    child: Align(
                      child: Text('Atenção!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(6)),),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Ao clicar em excluir você vai apagar todo seu registro no aplicativo com excessão das avaliações', textAlign: TextAlign.center, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3)),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text('Depois não será possível recupera-los.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),
                    ),
                  ),

                  SizedBox(height: heightPercent*0.05,),

                  Container(
                    width: widthPercent*0.9,
                    height: heightPercent*0.10,
                    child: RaisedButton(
                      onPressed: (){

                        if(_lockButton==false){

                          _lockButton=true;


                          void onSucessDelete(){
                            print('apagou');
                            _displaySnackBar(context, 'As informações foram excluídas. Desconectando você');

                            Future.delayed(Duration(seconds: 4)).then((_) {
                              setState(() {
                                _isLoading=false;
                              });
                              newAuthService.SignOut();
                              SharedPrefsUtils().clearPrefs();
                              Navigator.of(context).pop();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => HomePage()));
                            });



                          }

                          void onFailureDelete(){
                            print('O usuário precisa fazer novo login para excluir esta conta.');
                            //desconectar e chamar o login novamente.
                            //mostrar uma janela informando e explicando processo
                          }

                          setState(() {
                            _isLoading=true;
                          });

                          FirestoreServices().deleteUserData(userModel.Uid, () {onSucessDelete();});
                          //newAuthService.deleteUserAccount(() {onSucessDelete();}, () {onFailureDelete();});

                        }

                      },
                      color: Colors.red,
                      child: Text('Excluir minha conta', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),
                      ),
                    ),
                  ),




                ],
              ),
            );
          },
        );
      },
    );

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
