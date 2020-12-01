import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretes_go_freteiro/classes/banishment_class.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_bank_data.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/pages/email_verify_view.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/menu/drawer.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/avaliation_page.dart';
import 'package:fretes_go_freteiro/pages/move_day_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/date_utils.dart';
import 'package:fretes_go_freteiro/utils/globals_constants.dart';
import 'package:fretes_go_freteiro/utils/notificationMeths.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:date_format/date_format.dart';
import 'package:async/async.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage> {

  //FirebaseAuth mAuth = FirebaseAuth.instance;
  //FirebaseUser firebaseUser;

  FirebaseAuth auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  UserModel userModelGLobal;
  NewAuthService _newAuthService;
  String userId;

  bool userIsLoggedIn;
  bool needCheck=true;

  bool showJobPopUp=false;
  bool showJobConfirmationPopup=false;
  bool showJobDeclinationPopup=false;
  bool showJobCancelmentByUser=false;

  String popUpsCode='no';

  bool showCustomPupUp1Btn=false;
  bool showCustomPopup=false;
  bool msgWasShown=false;

  bool isLoading=false;

  double heightPercent;
  double widthPercent;

  Map mapSelected;
  int indexSelected;

  double distance;

  String popupStrTxt; //texto da popup costumizavel
  String popupStrTitle;
  int indexPosition;

  Query query;
  bool queryWasLoaded=false;

  //now trying this
  //https://brainsandbeards.com/blog/how-to-add-local-notifications-to-flutter-app <<este funcionou

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  QuerySnapshot _querySnapshot;

  @override
  void initState() {
    super.initState();

    /* LOGIN PATH
    Is user logged in? yes ---------is email verified? yes ----------- there is file in sharedPrefs? yes ----load it then check if need cad infos trucker? yes --- go cad pages
                       no---do nothing                --no, go verify                                no ------load it from Firestore---then check if need cad infos trucker? yes ----go cad pages
     */

  }


  @override
  void dispose() {
    super.dispose();
    needCheck=true;
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    // isto é exercutado após todo o layout ser renderizado

    await checkFBconnection();
    if(userIsLoggedIn==true){
      checkEmailVerified(userModelGLobal, _newAuthService);
    }






  }

  void updateQuery(String id){
    query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('id_freteiro', isEqualTo: id);
  }

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery
        .of(context)
        .size
        .height;
    widthPercent = MediaQuery
        .of(context)
        .size
        .width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        userModelGLobal = userModel;
        if(userModel.Uid != '' && queryWasLoaded==false){
          queryWasLoaded=true;
          updateQuery(userModel.Uid);
        }
        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {
            _newAuthService = newAuthService;

            //Query query;

            /*
            if(needCheck==true){
              needCheck=false;
                //se nao está logado n precisa verificar nada. Pois ele pode fazer login quando quiser
              if(userIsLoggedIn==true){
                checkEmailVerified(userModel, newAuthService);
              }
            }

             */

            //final Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('id_freteiro', isEqualTo: userModel.Uid);


            return Scaffold(
                key: _scaffoldKey,
                floatingActionButton: FloatingActionButton(backgroundColor: Colors.blue, child: Icon(Icons.add_circle, size: 50.0,), onPressed: () { },),
                appBar: AppBar(title: WidgetsConstructor().makeSimpleText("Página principal", Colors.white, 15.0),
                  backgroundColor: Colors.blue,
                  centerTitle: true,
                  actions: [
                    IconButton(icon: Icon(Icons.add_alert_outlined),)
                  ],
                ),
                drawer: MenuDrawer(),
                body: Stack(
                  children: [

                    Center(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            userIsLoggedIn == true ? Text("Logado") : Text("Nao logado"),
                            SizedBox(height: 25.0,),

                            userModel.Uid == ""
                                ? Container()
                                : StreamBuilder<QuerySnapshot>(
                              stream: query.snapshots(),
                              builder: (context, stream){

                                if (stream.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                if (stream.hasError) {
                                  return Center(child: Text(stream.error.toString()));
                                }

                                QuerySnapshot querySnapshot = stream.data;

                                return
                                  querySnapshot.size == 0
                                      ? Center(child: Text("Sem serviços para você por enquanto"),)
                                      : Expanded(child: ListView.builder(
                                      itemCount: querySnapshot.size,
                                      //itemBuilder: (context, index) => Trucker(querySnapshot.docs[index]),
                                      itemBuilder: (context, index) {


                                        if(index+1==querySnapshot.size){
                                          //significa que é o ultimo load. Posso fazer verificação para abrir proxima página sem apresentar erros

                                          Future.delayed(Duration(seconds: 4)).whenComplete(() => checkIfExistMovegoingNow(querySnapshot, userModel));
                                        }

                                        Map<String, dynamic> map = querySnapshot.docs[index].data();
                                        return GestureDetector(
                                          onTap: (){

                                            setState(() {
                                              isLoading=true;
                                            });

                                            if(map['alert'].toString().contains('trucker')  && map['alert_saw']== false){
                                              FirestoreServices().updateAlertView(map['moveId']); //coloca como visto e remove o alerta
                                            }

                                            indexSelected = index;
                                            mapSelected = map;
                                            calculateDistance();


                                            /*
                                            if(map['situacao'].toString()=='trucker_finished'){

                                            } else {

                                            }
                                             */

                                            //update screen
                                            setState(() {
                                              showJobPopUp=true;
                                              isLoading=false;
                                            });



                                          },
                                          //child: Text(map['name']),
                                          child: ListLine(map),

                                        );
                                        //return Trucker(querySnapshot.docs[index]);

                                      }

                                  ),
                                  );

                              },
                            ),

                          ],
                        ),
                      ),
                    ),

                    showJobPopUp==true
                        ? Container(
                      decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0),

                      child: JobPopUp(),
                    )
                        : Container(),

                    showJobConfirmationPopup==true
                        ? popUpConfirmJob()
                        : Container(),

                    showJobDeclinationPopup==true
                        ? popUpDeclinationJob()
                        : Container(),

                    showJobCancelmentByUser==true
                        ? popupShowUserHasCancelledJob(userModel)
                        : Container(),

                    //reconstruindo os popups
                    popUpsCode=='no'
                    ? Container()
                    : popUpsCode=='pago_little_negative'
                      ? WidgetsConstructor().customPopUp('Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Ir para mudança', 'Mudança não ocorreu', widthPercent, heightPercent, () {_pago_passou_abrirMove(_querySnapshot);}, () {_pago_passou_mudancaNocorreu();})
                      : popUpsCode=='pago_much_negative'
                          ? WidgetsConstructor().customPopUp('Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', 'Finalizar mudança', widthPercent, heightPercent,
                            () {_pago_passouMuito_mudancaNaoOcorreu();}, () {_pago_passouMuito_finalizar();})
                          : popUpsCode=='pago_reminder'
                            ? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
                            () {_pago_reminder_irParaMove(_querySnapshot);}, () {_pago_reminder_depois();})
                            : popUpsCode=='pago_moveTime'
                              ? WidgetsConstructor().customPopUp('Hora de mudança', 'Você tem uma mudança agora.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
                              () {_pago_moveTime_irParaMove(_querySnapshot);}, () {_pago_moveTime_depois();})
                              : popUpsCode=='accepted_little_negative'
                                ? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança que iniciou às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.', 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
                                () {_accepted_passou_aguardar();}, () {_accepted_passou_cancelarMove();})
                                : popUpsCode == 'accepted_much_negative'
                                  ? WidgetsConstructor().customPopUp1Btn('Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.', Colors.blue, widthPercent, heightPercent,
                                  () {_accepted_passouMuito_cancelar();})
                                  : popUpsCode=='accepted_reminder'
                                    ? WidgetsConstructor().customPopUp1Btn('Lembrete', 'Você tem uma mudança agendada para daqui a pouco às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.', Colors.blue, widthPercent, heightPercent,
                                    () {_accepted_reminder();})
                                    : popUpsCode=='accepted_moveTime'
                                      ? WidgetsConstructor().customPopUp('Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança..', 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
                                      () {_accepted_moveTime_aguardar();}, () {_accepted_moveTime_cancelarMove();})
                                      : popUpsCode=='_pago_passouMuito_mudancaNaoOcorreu_alert'
                                        ? WidgetsConstructor().customPopUp('Atenção', 'Você está informando que não realizou a mudança.', 'Não prestei o serviço', 'Eu prestei este serviço', widthPercent, heightPercent, () {_pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[indexPosition]['moveId'], userModel.Uid);}, () {_pago_passouMuito_mudancaNaoOcorreuCancelCallback();})
                                        : popUpsCode=='user_informs_trucker_didnt_finished_move'
                                          ? WidgetsConstructor().customPopUp('Atenção', 'O cliente informou que você ainda não finalizou o serviço.', 'Vou voltar para terminar', 'Não vou voltar e concordo não receberei pelo serviço', widthPercent, heightPercent, () {_user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[indexPosition]['moveId'], userModel);}, () {_user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
                                            : popUpsCode=='user_informs_trucker_didnt_make_move'
                                              ? WidgetsConstructor().customPopUp1Btn('Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.", Colors.red, widthPercent, heightPercent, () { _user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
                                              : Container(),


                    isLoading==true
                        ? Center(child: CircularProgressIndicator(),)
                        : Container(),

                    /*
                    GestureDetector(
                      onTap: (){

                        DateTime moveDate = DateUtils().convertDateFromString('08/11/2020');
                        print(moveDate);
                        moveDate = DateUtils().addMinutesAndHoursFromStringToAdate(moveDate, '22:01');
                        /*
                        var string = "21:58";
                        var ar = string.split(":");
                        int hourNew = int.parse(ar.first);
                        int minuteNew = int.parse(ar.last);
                        moveDate = DateTime(moveDate.year, moveDate.month, moveDate.day, hourNew, minuteNew);
                        print(moveDate);
                         */

                        NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, userModel.Uid, "Atenção: Mudança amanhã as 15:00 horas", moveDate);
                      },
                      child: Container(height: 100.0, width: 100.0, color: Colors.pink,),
                    )

                     */

                  ],
                )
            );
          },
        );
      },
    );
  }







  Future<void> checkIfExistMovegoingNow(QuerySnapshot querySnapshot, UserModel userModel) async {

    /*
    Flow:
    situacao = accepted - tá na hora - noa pagou, cancelar.
                        - é daqui a pouco - nao pagou, aguardar ou cancelar.
                        - ja passou um pouco - nao pagou, aguardar ou cancelar.
                        - passou há mt tempo - nao pagou, cancelar.

     situacao = pago - tá na hora - ir para mudança ou aguardar
                     - é daqui a pouco - ir para mudança ou aguardar
                     - ja passou um pouco - ir para mudança ou mudança n aconteceu?
                     - ja passou há mt tempo - finalizar
     */

    if(msgWasShown==false){
      msgWasShown=true;
      _querySnapshot = querySnapshot;

      int i = 0;
      while(i<querySnapshot.size){

        indexPosition=i;

        //caso o user tenha relatado problemas
        if(querySnapshot.docs[i]['situacao'] == 'user_informs_trucker_didnt_make_move'){
          setState(() {
            popUpsCode='user_informs_trucker_didnt_make_move';
          });
        }
        if(querySnapshot.docs[i]['situacao'] == 'user_informs_trucker_didnt_finished_move'){
          setState(() {
            popUpsCode='user_informs_trucker_didnt_finished_move';
          });
        }

        //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
        if(querySnapshot.docs[i]['situacao'] == 'user_informs_trucker_didnt_finished_move_goingback'){
          _displaySnackBar(context, 'Você está voltando para concluir a mudança. Abrindo a mudança');

          MoveClass moveClass = MoveClass();

          void _onSucess(){
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveDayPage(moveClass)));
          }


          FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});

        }

        //caso esteja pago, procedimenros abaixo
        if(querySnapshot.docs[i]['situacao'] == 'pago'){


          DateTime scheduledDate = DateUtils().convertDateFromString(querySnapshot.docs[i]['selectedDate']);
          DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, querySnapshot.docs[i]['selectedTime']);
          final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

          if(dif.isNegative) {
            //a data já expirou

            if(dif>-240){

              setState(() {
                popUpsCode='pago_little_negative';
              });

              //neste caso o user fechou o app e abriu novamente

            } else {

              //a mudança já se encerrou há tempos
              setState(() {
                popUpsCode='pago_much_negative';
              });
            }


          } else if(dif<=120 && dif>15){

            print('entrou no pago_reminder');
            setState(() {
              popUpsCode='pago_reminder';
            });
            //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

          } else if(dif<=15){


            print('entrou no pago_moveTime');
            setState(() {
              popUpsCode='pago_moveTime';
            });

          } else {

            //do nothing, falta mt ainda

          }



        }


        //caso esteja aceito mas o user ainda não pagou
        if(querySnapshot.docs[i]['situacao'] == 'accepted'){

          DateTime scheduledDate = DateUtils().convertDateFromString(querySnapshot.docs[i]['selectedDate']);
          DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, querySnapshot.docs[i]['selectedTime']);
          final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

          if(dif.isNegative) {


              //a data já expirou

              if (dif > -240) {
                setState(() {
                  popUpsCode = 'accepted_little_negative';
                });

                //neste caso o user fechou o app e abriu novamente

              } else {
                //a mudança já se encerrou há tempos
                setState(() {
                  popUpsCode = 'accepted_much_negative';
                });
              }





          } else if(dif<=120 && dif>15){

            setState(() {
              popUpsCode='accepted_reminder';
            });
            //exibe a popup informando que está na hora mas o user ainda n pagou


          } else if(dif<=15){

            setState(() {
              popUpsCode='accepted_moveTime';
            });


          } else {

            //do nothing, falta mt ainda

          }


        }

        i++;
      }

    }



    /*
    if(map['situacao'] == 'accepted'){

      DateTime scheduledDate = DateUtils().convertDateFromString(map['selectedDate']);
      DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, map['selectedTime']);
      final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

      if(dif.isNegative){
        //a data já expirou
        print('expirou');
      } else if(dif<=15){
        //ta na hora da mudança. Abrir a pagina de mudança

        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MoveDayPage())

        );


      } else {
        print('falta mt');
      }

    }


     */
  }
  /*
  FUNCOES DE CALLBACK PARA CADA SITUAÇÃO QUE EXIBE POPUP
   */

  //opção 1 - mudança tá paga, mas já passou. Exibe opções abaixo
  //popUpsCode=='pago_little_negative'
  void _pago_passou_finalizar(){
      //finalizar uma mudança
    print('finalizar mudança');
  }

  Future<void> _pago_passou_abrirMove(QuerySnapshot querySnapshot) async {

    setState(() {
      isLoading = true;
    });

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      setState(() {
        isLoading=false;
      });

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_passou_mudancaNocorreu(){
    print('mudança nunca ocorreu');
    //lidar com isso no bd. pegar os motivos e provavelmente punir o freteiro
    setState(() {
      popUpsCode='_pago_passouMuito_mudancaNaoOcorreu_alert';
    });
  }

  //opção 2 - mudança tá paga, mas já passou há mt tempo. Exibe opções
  //popUpsCode=='pago_much_negative'
  void _pago_passouMuito_finalizar(){
    print('finalizar');
  }

  void _pago_passouMuito_mudancaNaoOcorreu(){

    setState(() {
      popUpsCode='_pago_passouMuito_mudancaNaoOcorreu_alert';
    });
  }

  void _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(String moveId, String truckerId){

    setState(() {
      isLoading=true;
    });

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, 'trucker desistiu após pagamento do user');
      isLoading=false;
      setState(() {
        popUpsCode='no';
      });
    }

    void _onFail(){
      isLoading=false;
      _displaySnackBar(context, "Ocorreu um erro. Tente nvoamente");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});
  }

  void _pago_passouMuito_mudancaNaoOcorreuCancelCallback(){
    setState(() {
      popUpsCode='no';
    });
  }

  //opção 3 - mudança tá paga e começa logo.
  //popUpsCode=='pago_reminder'
  Future<void> _pago_reminder_irParaMove(QuerySnapshot querySnapshot) async {

    setState(() {
      isLoading = true;
    });

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      setState(() {
        isLoading=false;
      });

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_reminder_depois(){
    setState(() {
      popUpsCode='no';
    });
  }

  //opção 4 - mudança tá paga e tá na hora de fazer
  //opUpsCode=='pago_moveTime'
  Future<void> _pago_moveTime_irParaMove(QuerySnapshot querySnapshot) async {

    setState(() {
      isLoading = true;
    });

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      setState(() {
        isLoading=false;
      });

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_moveTime_depois(){
    setState(() {
      popUpsCode='no';
    });
  }


  //agora opções quando o user ainda não pagou
  //já deu a hora mas passou pouco, o user ainda nao pagou.
  //popUpsCode=='accepted_little_negative'
  void _accepted_passou_aguardar(){
    setState(() {
      popUpsCode='no';
    });
  }

  void _accepted_passou_cancelarMove(){

    void _onCancelSucess(){
      queryWasLoaded=false;
      setState(() {
        popUpsCode='no';
      });
      _displaySnackBar(context, 'Você cancelou a mudança.');
    }

    void _onCancelFailure(){
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }

    print('cancelar mudança');
    FirestoreServices().truckerQuitBecauseOfOutageOfPayment(_querySnapshot.docs[indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});
  }


  //usuario nao pagou e já passou muito do tempo
  //popUpsCode == 'accepted_much_negative'
  void _accepted_passouMuito_cancelar(){

    //precisa avaliar mal o user
    void _onCancelSucess(){
      _displaySnackBar(context, 'Você cancelou a mudança.');
      setState(() {
        popUpsCode='no';
      });
    }

    void _onCancelFailure(){
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
      setState(() {
        popUpsCode='no';
      });
    }

    print('cancelar mudança');
    FirestoreServices().truckerQuitBecauseOfOutageOfPayment(_querySnapshot.docs[indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});

  }

  //reminder - o user ainda nao pagou mas a mudança começaria em breve
  //popUpsCode=='accepted_reminder'
  void _accepted_reminder() {
    setState(() {
      popUpsCode='no';
    });
  }

  //deu a hora mas o user nao pagou. DEixar o motorista escolher
  //popUpsCode=='accepted_moveTime'
  void _accepted_moveTime_aguardar(){
    setState(() {
      popUpsCode='no';
    });
  }

  void _accepted_moveTime_cancelarMove(){

    //avaliar mal o user
    void _onCancelSucess(){
      _displaySnackBar(context, 'Você cancelou a mudança.');
    }

    void _onCancelFailure(){
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }


    FirestoreServices().truckerQuitBecauseOfOutageOfPayment(_querySnapshot.docs[indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});
  }

  void _user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(String moveId, UserModel userModel){

    //acho que nesta opção não precisa punir o freteiro, ele já vai ser mal avaliado pelo user.
    FirestoreServices().updateMoveSituation('user_informs_trucker_didnt_finished_move_goingback', moveId);
    MoveClass moveClass = MoveClass();

    void _onSucess(){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(moveClass)));
    }

    FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});
  }

  void _user_informed_truckerDidntFinishedMoveCancel(String truckerId, String moveId){

    setState(() {
      isLoading=true;
    });

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, GlobalsConstants.punishmentEntry2);
      FirestoreServices().createBanishmentEntry(truckerId, GlobalsConstants.banishmentInform1, GlobalsConstants.banishementTime1);
      _displaySnackBar(context, "Você está punido com o banimento da plataforma por uma semana. Nesta semana você pode concluir as mudanças que estão agendadas mas não aparecerá para novos clientes até encerrar o prazo.");

      isLoading=false;
      setState(() {
        popUpsCode='no';
      });
    }

    void _onFail(){
      isLoading=false;
      _displaySnackBar(context, "Ocorreu um erro. Tente nvoamente");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});

  }

  void _user_informed_truckerDidndShowUp(String truckerId, String moveId){

    setState(() {
      isLoading=true;
    });

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, GlobalsConstants.punishmentEntry3);
      FirestoreServices().createBanishmentEntry(truckerId, GlobalsConstants.banishmentInform2, GlobalsConstants.banishementTime2);
      _displaySnackBar(context, "Você está punido com o banimento da plataforma por ${GlobalsConstants.banishementTime2.toString()} semanas. Neste tempo você pode concluir as mudanças que estão agendadas mas não aparecerá para novos clientes até encerrar o prazo.");

      isLoading=false;
      setState(() {
        popUpsCode='no';
      });
    }

    void _onFail(){
      isLoading=false;
      _displaySnackBar(context, "Ocorreu um erro");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});

  }


  /*
  FIM DAS FUNÇÕES DE CALLBACK DOS POPUPS
   */





  Widget ListLine(Map map){

    return Padding(padding: EdgeInsets.all(10.0),
      child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
          child: Column(
            children: [
              //icone notificação
              map['alert'].toString().contains('trucker')  && map['alert_saw']== false
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.add_alert,
                    color: Colors.pink,
                    size: 24.0,
                    semanticLabel: 'Novidades',
                  ),
                ],
              ) : Container(),

              Row(
                children: [
                  WidgetsConstructor().makeText("Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
                  WidgetsConstructor().makeText(MoveClass().formatSituationToHuman(map['situacao']), Colors.black, 15.0, 10.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Origem: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_origem'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Destino: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['endereco_destino'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Ajudantes: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['ajudantes'].toString(), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

              Row(
                children: [
                  WidgetsConstructor().makeText("Data: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedDate'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              Row(
                children: [
                  WidgetsConstructor().makeText("Horário: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText(map['selectedTime'], Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),
              map['situacao']=='accepted'
                  ? WidgetsConstructor().makeText("Você aceitou este serviço", Colors.blue, 15.0, 10.0, 5.0, null)
                  : Container(),

            ],
          )
      ),
    );
  }

  Widget JobPopUp() {

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(
                onPressed: (){
                  setState(() {
                    showJobPopUp=false;
                    showJobConfirmationPopup=false;
                    showJobDeclinationPopup=false;
                  });
                },
              )
            ],
          ),
          SizedBox(height: 10.0,),
          Row(
            children: [
              WidgetsConstructor().makeText("Detalhes", Colors.blue, 18.0, 10.0, 20.0, "center"),
            ],
          ),
          SizedBox(height: 20.0,),
          Text('Origem: '+mapSelected['endereco_origem']),
          Text('Destino: '+mapSelected['endereco_destino']),
          distance != null
              ?Text('Distancia: '+distance.toStringAsFixed(2)+"km")
              :Text('Calculando'),
          SizedBox(height: 20.0,),
          Text('Ajudantes requisitados: '+mapSelected['ajudantes'].toString()),
          Text('Data: '+mapSelected['selectedDate'].toString()),
          Text('Horário: '+mapSelected['selectedTime'].toString()),
          Text('Observações : '+mapSelected['ps']),
          mapSelected['escada'] == true
              ? Text('Lances de escada: '+mapSelected['lances_escada'].toString())
              : Container(),
          Text('Valor: R\$'+mapSelected['valor'].toStringAsFixed(2)),
          SizedBox(height: 20.0,),
          //botoes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  setState(() {
                    showJobDeclinationPopup=true;
                  });
                },
                child: WidgetsConstructor().makeButton(Colors.redAccent, Colors.white, mapSelected['situacao'] == 'accepted' ? widthPercent*0.8 : widthPercent*0.4, 60.0, 2.0, 5.0, mapSelected['situacao'] == 'accepted' ? "Desistir" : "Negar", Colors.white, 17.0),
              ),

              GestureDetector(
                onTap: (){
                  setState(() {
                    showJobConfirmationPopup=true;
                  });
                },
                child:
                mapSelected['situacao'] == 'accepted' //se tiver aceitado este botão n aparece mais, apenas o de cancelar
                    ? Container()
                    : WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.4, 60.0, 2.0, 5.0, "Aceitar", Colors.white, 17.0),
              ),


            ],
          )

        ],
      ),
    );

  }

  Widget popUpConfirmJob(){

    return Container(
      height: heightPercent,
      width: widthPercent,
      color: Colors.white,
      child: Center(
        child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
          height: heightPercent*0.65,
          width: widthPercent*0.8,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                //btn close
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: (){
                        setState(() {
                          showJobConfirmationPopup=false;
                        });
                      },
                    )
                  ],
                ),
                SizedBox(height: 30.0,),
                WidgetsConstructor().makeText("Atenção", Colors.blue, 18.0, 0.0, 25.0, "center"),
                WidgetsConstructor().makeText("Você confirma que deseja aceitar este serviço nestas condições?", Colors.black, 15.0, 0.0, 25.0, "center"),
                SizedBox(height: heightPercent*0.2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isLoading=true;
                        });

                        ConfirmJob();

                      },
                      child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.6, 60.0, 2.0, 5.0, "Pegar serviço", Colors.white, 18.0),
                    )

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget popUpDeclinationJob(){

    return Container(
      height: heightPercent,
      width: widthPercent,
      color: Colors.white,
      child: Center(
        child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.red, 2.0, 3.0),
          height: heightPercent*0.65,
          width: widthPercent*0.8,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                //btn close
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: (){
                        setState(() {
                          showJobDeclinationPopup=false;
                        });
                      },
                    )
                  ],
                ),
                SizedBox(height: 30.0,),
                WidgetsConstructor().makeText("Atenção", Colors.red, 18.0, 0.0, 25.0, "center"),
                WidgetsConstructor().makeText("Você tem certeza que deseja negar este serviço?", Colors.black, 15.0, 0.0, 25.0, "center"),
                SizedBox(height: heightPercent*0.2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){

                        DenyJob();

                      },
                      child: WidgetsConstructor().makeButton(Colors.red, Colors.white, widthPercent*0.6, 60.0, 2.0, 5.0, "Rejeitar serviço", Colors.white, 18.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }

  Widget popupShowUserHasCancelledJob(UserModel userModel){

    return Center(
      child: Container(
        width: widthPercent*0.8,
        height: heightPercent*0.4,
        decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.grey, 3.0, 5.0),
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
          child: Column(
            children: [
              WidgetsConstructor().makeText("Atenção", Colors.red, 20.0, 30.0, 40.0, "center"),
              WidgetsConstructor().makeText("Um usuário cancelou a mudança", Colors.blue, 16.0, 10.0, 40.0, "center"),
              SizedBox(height: heightPercent*0.039),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: widthPercent*0.25,
                    height: heightPercent*0.10,
                    decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 0.5, 5.0),
                    child: GestureDetector(
                      onTap: (){

                        FirestoreServices().deleteCancelmentsNotify(userModel.Uid);
                        //agora cancelar as notificacoes locais (lembretes)
                        //notificação de 24h de antecedencia
                        NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, userModel.MoveIdCancelment);
                        //notificação de 2h de antecedencia]
                        NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, userModel.MoveIdCancelment+'2');

                        setState(() {
                          showJobCancelmentByUser=false;
                        });
                      },
                      child: WidgetsConstructor().makeText("Ok", Colors.blue, 16.0, 0.0, 0.0, 'center') ,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

  }

  void ConfirmJob() async {

    await FirestoreServices().confirmJobAceptance(mapSelected['id_contratante'],() {_onSucessConfirmJob();}, () {_onFailConfirmJob();});
    mapSelected['situacao']='accepted';
  }

  void _onSucessConfirmJob(){
    //coloca um alerta de novidade para o usuário
    FirestoreServices().alertSetUserAlert(mapSelected['moveId']);
    //cria uma notificação para o freteiro 24 horas antes
    DateTime moveDate = MoveClass().formatMyDateToNotify(mapSelected['selectedDate'], mapSelected['selectedTime']);
    DateTime notifyDateTime = DateUtils().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, mapSelected['moveId'], "Lembrete: Mudança amanhã às "+mapSelected['selectedTime'], notifyDateTime);

    //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
    notifyDateTime = DateUtils().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, mapSelected['moveId']+'2', "Lembrete: Mudança em duas horas às "+mapSelected['selectedTime'] , notifyDateTime);

    setState(() {
      isLoading=false;
      showJobConfirmationPopup=false;
      showJobPopUp=false;
    });
    _displaySnackBar(context, "Pronto. Esta mudança está agendada.");
  }

  void _onFailConfirmJob(){
    setState(() {
      isLoading=false;
    });
    _displaySnackBar(context, "Ocorreu um erro. Tente novamente");
  }

  void DenyJob() async {

    void _onSucessDenyJob(){

      FirestoreServices().alertSetUserAlert(mapSelected['moveId']);

      //cancelando as notificações
      NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, mapSelected['moveId']); //24h early
      NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, mapSelected['moveId']+'2'); //2h early

      mapSelected['situacao']='deny';
      mapSelected['id_freteiro']=null;
      mapSelected['nome_freteiro']=null;

      setState(() {
        isLoading=false;
        showJobDeclinationPopup=false;
        showJobPopUp=false;
      });
      _displaySnackBar(context, "Você rejeitou este serviço.");
    }

    void _onFailureDenyJob(){

      setState(() {
        isLoading=false;
      });
      _displaySnackBar(context, "Ocorreu um erro. Tente novamente.");
    }

    await FirestoreServices().confirmJobDeny(mapSelected['moveId'], () {_onSucessDenyJob();}, () {_onFailureDenyJob();});

  }

  Future<void> calculateDistance() async {

    distance = await MoveClass().getTheDistanceFromTwoAddress(mapSelected['endereco_origem'], mapSelected['endereco_destino']);
    setState(()  {
      distance = distance;
    });


  }

  void checkFBconnection() async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {

        setState(() {
          userIsLoggedIn=false;
        });


      } else {

        setState(() {
          userIsLoggedIn=true;
          needCheck=true;
        });

      }
    });
  }


  Future<void> checkEmailVerified(UserModel userModel, NewAuthService newAuthService) async {

    //load data in model
    await newAuthService.loadUser();

    //check if email is verified
    bool isUserEmailVerified = false;
    isUserEmailVerified = await newAuthService.isUserEmailVerified();
    if(isUserEmailVerified==true){

      //now check if there is basic data in sharedPrefs
      bool existsDataInSharedPrefs = await SharedPrefsUtils().thereIsBasicInfoSavedInShared();
      if(existsDataInSharedPrefs==true){
        //if there is data, load it
        await SharedPrefsUtils().loadBasicInfoFromSharedPrefs(userModel);

      } else {
        //if there is not, load it from FB
        //await newAuthService.loadUserBasicDataInSharedPrefs(userModel);
        //the rest will be done on another metch to check what need to be done in case of more info required
        //await FirestoreServices().loadUserInfos(userModel, () {_onSucessLoadInfos(userModel);}, () {_onFailureLoadInfos(userModel);});

      }


      everyProcedureAfterUserInfoIsLoad(userModel);


    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  Future<void> everyProcedureAfterUserInfoIsLoad(UserModel userModel) async {

    checkIfNeedUserInfos(userModel);  //completa as informações de cadastro do usuário

    checkIfUserBanishmentIsOver(userModel);

    /*
    //somente para testes de avaliation page - a info que vai é de moveClass poiis vai vir depois da mudança
    MoveClass moveClass = MoveClass();

    void _onFail(){
      print('fail');
    }

    void _onSucess(){
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AvaliationPage(moveClass)));

    }

    await FirestoreServices().loadMoveClassForTests(moveIdSomenteParaTestarAvaliationPage, moveClass, () {_onFail();}, () {_onSucess();});


     */

  }

  Future<void> checkIfNeedUserInfos(UserModel userModel) async {

    //agora verifica se precisa ler dados do bd
    int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
    if(pageDone==99){
      //nao existe data. Pegar no firebase
      _userIsOk();//check if truckers cad is complete in firebase
    } else if(pageDone==1){

      //obs: se pageDone == 1 significa que vai abrir a página 2 (a 1 está ok). Os dados são carregados abaixo para ficarem acessiveis no entanto eles n correpsondem a página 2.
      //carregue os dados da pagina então, que ja foi preenchida em outro momento
      SharedPrefsUtils().loadPageOneInfo(userModel);

      //exibe um dialog pro user escolher
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Completar informações",
        desc: "Você ainda não completou seu cadastro. Assim, você ainda não está aparecendo para os clientes.",
        buttons: [
          DialogButton(
            child: Text(
              "Completar agora",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {

              Navigator.pop(context);
              goToPage2OfUserInfos(context);

            },
            color: Color.fromRGBO(0, 179, 134, 1.0),
          ),
          DialogButton(
            child: Text(
              "Fazer depois",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            gradient: LinearGradient(colors: [
              Color.fromRGBO(116, 116, 191, 1.0),
              Color.fromRGBO(52, 138, 199, 1.0)
            ]),
          )
        ],
      ).show();


      //SharedPrefsUtils().loadPageOneInfo(userModel);
      //goToPage2OfUserInfos(context);
    } else if(pageDone==2) {
      //SharedPrefsUtils().loadPageOneInfo(userModel);

      //exibe um dialog pro user escolher
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Completar informações",
        desc: "Você ainda não completou seu cadastro. Assim, você ainda não está aparecendo para os clientes.",
        buttons: [
          DialogButton(
            child: Text(
              "Completar agora",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              goToPage3OfUserInfos(context);
            },
            color: Color.fromRGBO(0, 179, 134, 1.0),
          ),
          DialogButton(
            child: Text(
              "Fazer depois",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            gradient: LinearGradient(colors: [
              Color.fromRGBO(116, 116, 191, 1.0),
              Color.fromRGBO(52, 138, 199, 1.0)
            ]),
          )
        ],
      ).show();

    } else if(pageDone==3){

      //exibe um dialog pro user escolher
      Alert(
        context: context,
        type: AlertType.warning,
        title: "Completar informações bancárias",
        desc: "Você ainda não completou seu cadastro. Assim, você ainda não está aparecendo para os clientes.",
        buttons: [
          DialogButton(
            child: Text(
              "Completar agora",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
              goToPage4OfUserInfos(context);
            },
            color: Color.fromRGBO(0, 179, 134, 1.0),
          ),
          DialogButton(
            child: Text(
              "Fazer depois",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            gradient: LinearGradient(colors: [
              Color.fromRGBO(116, 116, 191, 1.0),
              Color.fromRGBO(52, 138, 199, 1.0)
            ]),
          )
        ],
      ).show();


    } else if(pageDone==4){

      //user ja completou tudo
      SharedPrefsUtils().loadPageOneInfo(userModel);
      //obs a página dois só tem a cnh, n precisa ler
      SharedPrefsUtils().loadPageThreeInfo(userModel);
      userModel.updateTruckerInfoOk(true);
      //a pagina 4 tb nao precisa ler pq sao dados bancários q n vamos manter no shared

      //novos métodos após todas verificações
      checkIfUserHasCancelmentsNotify(userModel);
    }


  }

  Future<void> checkIfUserHasCancelmentsNotify(UserModel userModel) async {

    FirestoreServices().checkIfUserHasCancelmentsNotify(userModel.Uid, userModel, () {_onSucessShowUserCancelment(userModel);});
  }

  void checkIfUserBanishmentIsOver(UserModel userModel){

    void _isBanished(){
      //pegar o tempo para conferir
      BanishmentClass banishmentClass = BanishmentClass(userModel.Uid, 'no', 'no', 'no', 911);

      void _onSucessHere(){
        //calcular se ja esgotou o tempo e retirar do banimento
        calculateBanishmentIsOver(banishmentClass.tempo_banimento, banishmentClass.hora, banishmentClass.data, userModel.Uid);

      }

      void _onFailHere(){
        //tentar novamente
        FirestoreServices().getBanishmentInfo(userModel.Uid, banishmentClass, () { _onSucessHere();}, () { _onFailHere();});
      }

      FirestoreServices().getBanishmentInfo(userModel.Uid, banishmentClass, () { _onSucessHere();}, () { _onFailHere();});

    }

    void _isNotBanished(){
      //nao fazer nada
    }

    void _Fail(){
      //chamar novamente a função
      FirestoreServices().checkIfUserIsBanished(userModel.Uid, (){ _isBanished();}, () { _isNotBanished();}, () {_Fail();});
    }

    FirestoreServices().checkIfUserIsBanished(userModel.Uid, (){ _isBanished();}, () { _isNotBanished();}, () {_Fail();});

  }

  void calculateBanishmentIsOver(int prazo, String hora, String data, String truckerId){

    int prazoEmDias = prazo*7;

    String dateTodayString = DateUtils().giveMeTheDateToday();
    DateTime dateToday = DateUtils().convertDateFromString(dateTodayString);
    DateTime dateLimit = DateUtils().convertDateFromString(data);
    dateLimit = DateUtils().addDaysToDate(dateLimit, prazoEmDias);

    int difference = DateUtils().compareTwoDatesInMinutes(dateToday, dateLimit);
    if(difference.isNegative){
        //significa que acabou o prazo e pode tirar do banimento
        FirestoreServices().removeBanishmentInfo(truckerId);
        _displaySnackBar(context, 'Seu banimento acabou. Agora você aparece nas buscas novamente.');
    } else {
        _displaySnackBar(context, "Você ainda está banido até o dia "+data.toString()+'.');
    }
    /*
    if(difference==0){
      result = 'equal';
    } else if(difference.isNegative){
      result = 'date2bigger';
    } else {
      result = 'date1bigger';
    }

     */


  }

  void _onSucessShowUserCancelment(UserModel userModel){
    setState(() {
      showJobCancelmentByUser=true;
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







  Future<void> _userIsOk() async {
    //check if user concluded the cad as trucker
    await FirestoreServices().getUserInfoCheckWhatIsMissing(userModelGLobal, () {goToPage1OfUserInfos(context); }, () {goToPage2OfUserInfos(context); }, () {goToPage3OfUserInfos(context); }, () {goToPage4OfUserInfos(context); });

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

  void goToPage4OfUserInfos(BuildContext context){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TruckerInfosCadBankData()));
  }

}




