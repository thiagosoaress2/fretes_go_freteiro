import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/avaliation_class.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

bool showLandPage=true;
bool showCompleteAvaliation=false;
bool showLastPageConfirmationPage=false;

bool showConfirmationPopup=false;

bool isLoading=true;

AvaliationClass _avaliationClass = AvaliationClass('', '', 0, 0);

String name='no123';

double heightPercent;
double widthPercent;

double avaliation=0.0;


class AvaliationPage extends StatefulWidget {
  MoveClass moveClass = MoveClass();

  AvaliationPage(this.moveClass);

  @override
  _AvaliationPageState createState() => _AvaliationPageState();
}

class _AvaliationPageState extends State<AvaliationPage> with AfterLayoutMixin<AvaliationPage> {


  @override
  Future<void> afterFirstLayout(BuildContext context) async {

      loadAvaliationClass();

    }


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

    print(widget.moveClass.userId);
    //AvaliationClass _avaliationClass = AvaliationClass('', widget.moveClass.idPedido, 0, 0);
    _avaliationClass.userId = widget.moveClass.idPedido;


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel){

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(

            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              iconSize: 20.0,
              onPressed: () {
                _goBack(context);
              },
            ),

            title: Text('Avaliação'), centerTitle: true,
          ),

          body: Stack(
            children: [

              showLandPage==true
                  ? _landPage(userModel) : Container(),

              showCompleteAvaliation==true
                  ? _avaliationPage() : Container(),

              showLastPageConfirmationPage==true
                  ? _postAvaliationPage()
                  : Container(),

              isLoading==true
                  ? Center(child:  CircularProgressIndicator(),)
                  : Container(),

            ],

          ),

        );
      },
    );
  }

  //PAGES
  Widget _landPage(UserModel userModel){

    void _onConfirmPopup(){
      _quickAvaliation(avaliation, widget.moveClass, userModel);
      setState(() {
        showConfirmationPopup=false;
      });
    }

    void _onCancelPopup(){
      setState(() {
        showConfirmationPopup=false;
      });
    }

    return ListView(
      children: [

        Stack(
          children: [

            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                if(name!='no123') WidgetsConstructor().makeText('Avaliando '+name, Colors.black, 18.0, 25.0, 20.0, 'no'),

                //texto como voce avalia o cliente
                _linhaComTextoExplicativo(),

                //row com legenda 'muito bom e muito ruim'
                _linhaComLegenda(),

                //linha com as estrelas
                _estrelas(),

                //texto mostrando pro user o que ele selecionou
                if(avaliation!=0) _avalTip(),


                _btnAvaliar(),

                SizedBox(height: heightPercent*0.05,),


              ],
            ),



            if(showConfirmationPopup==true) WidgetsConstructor().customPopUp('Confirmação', 'Confirmar avaliação.', 'Confirmar', 'Cancelar', widthPercent, heightPercent, () {_onConfirmPopup();}, (){_onCancelPopup();}),

            if(showConfirmationPopup==true) _popupPage(userModel),


          ],
        )

      ],
    );
  }

  Widget _avaliationPage(){


    void _finishVote(){
      print('finish him');
    }

    void _next(){
      print('next');
    }


    void starCallback(int number){
      print(number);
    }

    return ListView(
      children: [

        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            WidgetsConstructor().makeText('Avaliação completa', Colors.blue, 18.0, 25.0, 20.0, 'center'),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  Container(color: Colors.white, width: widthPercent, height: heightPercent*0.3,
                  child: Stack(
                    children: [

                      Column(
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              WidgetsConstructor().makeText('Como você avalia a pontualidade: ', Colors.black, 17.0, 10.0, 20.0, 'center'),
                            ],
                          ),

                          SizedBox(height: 25.0,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              GestureDetector(
                                child: startsLine(),
                                onTap: (){
                                  starCallback(1);
                                },
                              ),


                            ],
                          )


                        ],
                      ),

                      Positioned(

                      child: IconButton(icon: Icon(Icons.arrow_forward_rounded, color: Colors.blue,), onPressed: () {_next();}),
                      bottom: 1.0,
                      right: 10.0,
                      ),

                    ],
                  ),
                  ),
                  Container(color: Colors.blue, width: widthPercent, height: heightPercent*0.25,),
                  Container(color: Colors.yellow, width: widthPercent, height: heightPercent*0.25,),

                ],
              ),
            ),

            SizedBox(height: 35.0,),

            WidgetsConstructor().makeButtonWithCallBack(Colors.blue, Colors.white, 100.0, 60.0, 2.0, 4.0, 'Finalizar', Colors.white, 16.0, () {_finishVote();}),





          ],
        ),

      ],
    );
  }

  Widget _linhaComTextoExplicativo(){

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        child: Text('Como você classifica o relacionamento com ${name} durante o serviço?',
            textAlign: TextAlign.center,
            style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
      ),
    );
  }

  Widget _linhaComLegenda(){

    return Padding(
      padding: EdgeInsets.fromLTRB(50.0, heightPercent*0.02, 50.0, 10.0),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Muito ruim',
              style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.4))),
          Text('Muito bom',
              style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(1.4))),
        ],
      ),
    );

  }

  Widget _estrelas(){
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 1.0, 10.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //estrela 1
          GestureDetector(
              onTap: (){
                setState(() {
                  avaliation=1;
                });
                print(avaliation);
              },
              child: avaliation==0
                  ? Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                  : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
          ),

          //estrela 2
          GestureDetector(
              onTap: (){
                setState(() {
                  avaliation=2;
                  print(avaliation);
                });

              },
              child: avaliation==2 || avaliation==3 || avaliation == 4 || avaliation==5
                  ? Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
                  : Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
          ),

          //estrela 3
          GestureDetector(
              onTap: (){
                setState(() {
                  avaliation=3;
                });

              },
              child: avaliation<=2
                  ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                  : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
          ),

          //estrela 4
          GestureDetector(
              onTap: (){
                setState(() {
                  avaliation=4;
                });

              },
              child: avaliation<=3
                  ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                  : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
          ),

          //estrela 5
          GestureDetector(
              onTap: (){
                setState(() {
                  avaliation=5;
                });

              },
              child: avaliation<=4
                  ?Icon(Icons.star_border, color: Colors.yellow[600], size: 60.0,)
                  : Icon(Icons.star, color: Colors.yellow[600], size: 60.0,)
          ),
        ],
      ),
    );
  }

  Widget _avalTip(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(_returnMeTheRightWord() , style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.5), color: CustomColors.brown),),
        ),
      ],
    );
  }

  Widget _btnAvaliar(){

    return Padding(
      padding: EdgeInsets.fromLTRB(widthPercent*0.10, 0.0, widthPercent*0.10, 0.0),
      child: Container(
        width: widthPercent*0.85,
        height: heightPercent*0.08,
        child: RaisedButton(
          onPressed: (){

            if(avaliation!=0){
              setState(() {
                showConfirmationPopup=true;
              });
            } else {
              _displaySnackBar(context, 'Classifique ${name} antes de finalizar.');
            }


          },
          color: CustomColors.yellow,
          child: Text('Finalizar avaliação', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
        ),
      ),
    );
  }

  //Functions
  String _returnMeTheRightWord(){

    if(avaliation==0 || avaliation==null){
      return '';
    } else if(avaliation==1){
      return 'Muito ruim';
    } else if(avaliation==2){
      return 'Ruim';
    } else if(avaliation==3){
      return 'Satisfatório';
    } else if(avaliation==4){
      return 'Bom';
    }  else {
      return 'Excelente';
    }

  }



  Widget _postAvaliationPage(){

    void _onClickOkButton(){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));
    }

    return ListView(
      children: [

        SizedBox(height: heightPercent*0.2,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Text('Obrigado por avaliar '+name, textAlign: TextAlign.center,
                style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.0), color: CustomColors.blue),
              ),
            ),
          ],
        ),

        SizedBox(height: heightPercent*0.02,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widthPercent*0.8,
              child: Text('As avaliações ajudam muito.. Você colaborou com toda a comunidade que utiliza nosso serviço.', textAlign: TextAlign.center,
                style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(2.0), color: Colors.black),
              ),
            ),
          ],
        ),

        SizedBox(height: heightPercent*0.3,),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: widthPercent*0.75,
              height: heightPercent*0.10,
              child: RaisedButton(
                onPressed: (){
                  _onClickOkButton();
                },
                color: CustomColors.blue,
                child: Text('Finalizar', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(4.0), color: Colors.white),
                ),
              ),
            )
          ],
        )


      ],
    );
  }








  //WIDGETS
  Widget startsLine(){
    return Container(

      child: Row(
        children: [

          Icon(Icons.star_border, color: Colors.yellow[600], size: 40.0,),

        ],
      ),

    );
  }


  //Functions
  _completeAvaliation(){
    setState(() {
      showCompleteAvaliation=true;
      showLandPage=false;
    });
  }

  _goBack(BuildContext context) {

    if(showLandPage==true){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => HomePage()));
    } else if(showCompleteAvaliation==true){
      avaliation=0;
      showConfirmationPopup=false;
      setState(() {
        showCompleteAvaliation=false;
        showLandPage=true;
      });
    }


  }

  void _quickAvaliation(double avaliation, MoveClass moveClass, UserModel userModel){
    _avaliationClass.newRate = AvaliationClass.Empty().calculateAvaliation(avaliation, _avaliationClass.avaliations, _avaliationClass.userRate);
    FirestoreServices().saveUserAvaliation(_avaliationClass);

    //se o user já tiver finalizado, fechar ticket senao deixar um anuncio de que o freteiro ja acabou
    if(moveClass.situacao=='user_finished'){
      moveClass.freteiroId = userModel.Uid;
      FirestoreServices().FinishAmove(moveClass); //aqui apaga e cria um histórico
    } else {
      FirestoreServices().updateMoveSituationTruckerQuit('trucker_finished', userModel.Uid, moveClass);

    }

    showLandPage=false;
    showCompleteAvaliation=false;
    setState(() {
      showLastPageConfirmationPage=true;
    });
  }

  Widget _popupPage(UserModel userModel){

    return Container(
      height: heightPercent,
      width: widthPercent,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          SizedBox(height: heightPercent*0.03,),

          //btn fechar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(
                onPressed: (){
                  setState(() {
                    showConfirmationPopup = false;
                  });
                },
              )
            ],
          ),

          SizedBox(height: heightPercent*0.05,),

          //imagem central
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                width: widthPercent*0.5,
                height: heightPercent*0.25,
                child: Image.asset('images/avalation/aval.png', fit: BoxFit.fill,),
              ),
            ],
          ),

          SizedBox(height: heightPercent*0.03,),

          //texto: voce classificou o serviço como
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: widthPercent,
                child: Text('Você classificou o serviço como:', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.0), color: CustomColors.blue),
                ),
              ),
            ],
          ),

          SizedBox(height: heightPercent*0.02,),

          //texto: classificação
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: widthPercent,
                child: Text(_returnMeTheRightWord(), textAlign: TextAlign.center,
                  style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(4.5), color: CustomColors.brown),
                ),
              ),
            ],
          ),

          SizedBox(height: heightPercent*0.10,),

          //botão confirmar*
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: widthPercent*0.80,
                height: heightPercent*0.10,
                child: RaisedButton(
                  onPressed: (){
                    _quickAvaliation(avaliation, widget.moveClass, userModel);
                    setState(() {
                      showConfirmationPopup=false;
                    });
                  },
                  color: CustomColors.yellow,
                  child: Text('Avaliar e encerrar',
                    style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.5), color: Colors.white),
                  ),
                ),
              )

            ],
          ),

          SizedBox(height: heightPercent*0.05,),

          //botão voltar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: widthPercent*0.80,
                height: heightPercent*0.10,
                child: RaisedButton(
                  onPressed: (){
                    setState(() {
                      showConfirmationPopup=false;
                    });
                  },
                  color: Colors.redAccent,
                  child: Text('Voltar',
                    style: TextStyle(fontSize: ResponsiveFlutter.of(context).fontSize(3.5), color: Colors.white),
                  ),
                ),
              )

            ],
          ),



        ],
      ),
    );
  }

  Future<void> loadAvaliationClass() async {


    void _onSucessLoadAvaliationClass(){

      setState(() {
        name = _avaliationClass.userName;
        isLoading=false;
      });

    }


    await FirestoreServices().loadAvaliationClass(_avaliationClass, () {_onSucessLoadAvaliationClass();});

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
