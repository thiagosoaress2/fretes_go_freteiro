import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretes_go_freteiro/classes/banishment_class.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_bank_data.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/pages/email_verify_view.dart';
import 'package:fretes_go_freteiro/login/pages/new_login_page.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/menu/drawer.dart';
import 'package:fretes_go_freteiro/models/home_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/avaliation_page.dart';
import 'package:fretes_go_freteiro/pages/move_day_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/services/sharedPrefs_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/custom_pure_popup.dart';
import 'package:fretes_go_freteiro/utils/date_utils.dart';
import 'package:fretes_go_freteiro/utils/globals_constants.dart';
import 'package:fretes_go_freteiro/utils/notificationMeths.dart';
import 'package:fretes_go_freteiro/utils/popup.dart';
import 'package:fretes_go_freteiro/utils/popup_new.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:date_format/date_format.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

//https://stackoverflow.com/questions/61755268/how-to-create-custom-calendar-in-flutter

class HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, SingleTickerProviderStateMixin {

  FirebaseAuth auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  UserModel userModelGLobal;
  NewAuthService _newAuthService;
  bool userIsLoggedIn;
  bool needCheck=true;
  double heightPercent;
  double widthPercent;
  Map mapSelected;
  int indexSelected;
  bool queryWasLoaded=false;
  bool _firstPass=true;
  CalendarController _calendarController;
  Map<DateTime, List> _listEvents;
  Query query;
  bool goForTheCheck=true;
  bool thereIsApopUponScreen = false;
  String _situationWithListener;
  //now trying this
  //https://brainsandbeards.com/blog/how-to-add-local-notifications-to-flutter-app <<este funcionou
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;
  QuerySnapshot _querySnapshot;
  Map<int, String> _listPopups = Map();
  String popsShownStr;
  int popsShownInt;
  bool showNotificationsScreen=false;
  ScrollController _scrollController;
  double offset=1.0;
  bool _showServicesPage=false;
  bool _showPopupFromTheServiceList=false;
  Map MapClone;




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
        userModelGLobal = userModel;

        /*
        if(userModel.Uid != '' && queryWasLoaded==false){
          queryWasLoaded=true;
          updateQuery(userModel.Uid);
        }

         */

        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {
            _newAuthService = newAuthService;



            /*
            Future.delayed(Duration(seconds: 5)).then((_) {
              testeNovaMudanca(300.00);
            });

             */

            return ScopedModelDescendant<HomeModel>(
              builder: (BuildContext context, Widget child, HomeModel homeModel){

                if(userIsLoggedIn==null){
                  _startVerifyLoginStatus(homeModel, newAuthService);
                }

                return Scaffold(
                    key: _scaffoldKey,
                    drawer: MenuDrawer(),
                    body: Container(
                      height: heightPercent,
                      width: widthPercent,
                      color: Colors.white,

                      child: userIsLoggedIn==true ? HomePageLoggedIn(homeModel, userModel) : HomePageUnLogged(homeModel),

                      /*
                      child: Stack(
                        children: [

                          //texto "Seus serviços
                          Positioned(
                            top: heightPercent*0.18,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                              width: widthPercent,
                              alignment: Alignment.center,
                              child: Text('Seus serviços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                            ),
                          ),


                          //alerta de outras notificacoes
                      Positioned(
                        top: heightPercent*0.17,
                        right: 10.0,
                        child: _listPopups.isEmpty ? Icon(Icons.add_alert_outlined, color: Colors.grey[100],) : customNotifyIcon(),
                      ),

                          //corpo do projeto com lista do firebase
                          userIsLoggedIn==true && homeModel.popUpsCode=='no' ? Positioned(
                            top: heightPercent*0.20,
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: Center(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [

                                    //userIsLoggedIn == true ? Text("Logado") : Text("Nao logado"),
                                    SizedBox(height: 25.0,),
                                    /*
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.calendar_today), onPressed: (){
                                          homeModel.updateShowCalendar(true);
                                        })
                                      ],
                                    ),
                                     */
                                    //a lista de serviços
                                    userModel.Uid == ""
                                        ? Container()
                                        :

                                    StreamBuilder<QuerySnapshot>(
                                      //stream: homeModel.query.snapshots(),
                                      stream: query.snapshots(),
                                      builder: (context, stream){
                                        /*
                                        homeModel.query.snapshots().listen((event) async {

                                          if(_firstPass==false){ //first pass vai assegurar que não entre aqui nas verificações na primeira rodada (até pq carrega várias vezes). Somente depois quando estiver vigiando mudanças
                                            event.docChanges.forEach((change) {
                                              print('entrou no listener');
                                              _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                              /*
                                      if(change.doc.data()["situacao"] != 'sjjsjsjs'){

                                      }

                                       */
                                            });
                                          }


                                        });

                                         */

                                        if (stream.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        }

                                        else if (stream.hasError) {
                                          return Center(child: Text(stream.error.toString()));
                                        }

                                        else if(stream.connectionState == ConnectionState.active){

                                          QuerySnapshot querySnapshot = stream.data;

                                          return querySnapshot.size == 0
                                              ? Center(child: simpleTextOfFeedback(),)
                                              : Expanded(
                                            child: GridView.builder(
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3),
                                                itemCount: querySnapshot.size,
                                                itemBuilder: (context, index){


                                                  _querySnapshot = querySnapshot;
                                                  //homeModel.updateMsgCanBeShown(true);


                                                  /*
                                                //novo listener
                                                //aparentemente n precisa do listener. Quando mdua ele ja percebe
                                                FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).doc(querySnapshot.docs[index].id).collection('situacao').snapshots().listen((event) async {
                                                  event.docChanges.forEach((change) {
                                                    print('entrou no listener');
                                                    _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                                  });
                                                });

                                                 */

                                                  if(index+1==querySnapshot.size){
                                                    //significa que é o ultimo load. Posso fazer verificação para abrir proxima página sem apresentar erros
                                                    Future.delayed(Duration(seconds: 4)).whenComplete(() => checkIfExistMovegoingNow(querySnapshot, userModel, homeModel));
                                                  }

                                                  Map<String, dynamic> map = querySnapshot.docs[index].data();

                                                  //click da situacao
                                                  return GestureDetector(
                                                    onTap: (){


                                                      if(map['alert'].toString().contains('trucker')  && map['alert_saw']== false){
                                                        FirestoreServices().updateAlertView(map['moveId']); //coloca como visto e remove o alerta
                                                      }

                                                      indexSelected = index;
                                                      homeModel.updateIndexPosition(index);
                                                      mapSelected = map;
                                                      calculateDistance(homeModel);



                                                      /*
                                            if(map['situacao'].toString()=='trucker_finished'){

                                            } else {

                                            }
                                             */

                                                      homeModel.setIsLoading(false);

                                                      //ATENÇÃO
                                                      // sitTruckerQuitAfterPayment = 'trucker_quited_after_payment';  //<<desabilitar os controles e exibir mensagem mas permitir trocar motorista
                                                      //   static String sitUserInformTruckerDidntMakeMove = 'user_informs_trucker_didnt_make_move';  //<<desabilitar os controles e exibir a mensagem
                                                      //   static String sitUserInformTruckerDidntFinishedMove =
                                                      //ESTAS TRES POSSIBILIDADES ACIMA NAO ESTÃO CONTEMPLADAS AQUI POIS ESTOU IMAGINANDO QUE NÃO TEM COMO CHEGAR AQUI DISPONIVEL. ESSAS SAO EXIBIDAS ASSIM QUE A SITUACAO É IDENTIFICADA EXIBE UMA POPUP E APAGA
                                                      if(map['situacao'].toString()== GlobalsConstants.sitAguardando){

                                                        homeModel.updateshowJobPopUp(true);

                                                      } else if (map['situacao'].toString()== GlobalsConstants.sitTruckerFinished){

                                                        homeModel.updatepopUpsCode(GlobalsConstants.sitTruckerFinished);

                                                      } else if (map['situacao'].toString()== GlobalsConstants.sitAccepted){

                                                        homeModel.updateshowJobPopUp(true);

                                                      } else if (map['situacao'].toString()== GlobalsConstants.sitAccepted){

                                                      }




                                                    },
                                                    //child: Text(map['name']),
                                                    child: ListLine(map, userModel, homeModel),

                                                  );



                                                }
                                            ),
                                          );
                                        }


                                      },
                                    ),

                                    homeModel.showCalendar==true ? SingleChildScrollView(
                                      child:Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              CloseButton(onPressed: (){
                                                homeModel.updateShowCalendar(false);
                                              },)
                                            ],
                                          ),
                                          _buildCalendar(),

                                        ],
                                      ) ,
                                    ) : Container(),

                                  ],
                                ),
                              ),
                            ),
                          ) : Container(),

                          //appbar
                          Positioned(
                            top: 0.0,
                            child: Container(
                                height: heightPercent*0.12,
                                width: widthPercent,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    SizedBox(height: 30.0,),
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.menu, color: CustomColors.blue, size: 35.0,), onPressed: (){
                                          homeModel.updateShowDrawer();
                                        }),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                          ),

                          //notificatiosn page
                          showNotificationsScreen==true ? notificationsScreen(homeModel) : Container(),

                          //menu
                          homeModel.showDrawer==true ? Positioned(
                            top: 0.0,
                            bottom: 0.0,
                            left: 0.0,
                            right: widthPercent*0.2,
                            child: MenuDrawer(),
                          ) : Container(),
                          //barra branca que fecha o menu
                          homeModel.showDrawer==true ? Positioned(
                            top: 50.0,
                            bottom: 0.0,
                            right: 0.0,
                            left: widthPercent*0.8,
                            child: GestureDetector(
                              onTap: (){
                                homeModel.updateShowDrawer();
                              },
                              child: Container(
                                alignment: Alignment.topCenter,
                                color: Colors.white.withOpacity(0.5),
                                child: Icon(Icons.arrow_back, color: CustomColors.blue, size: 50.0,),
                                //n precisa mostrar nada
                              ),
                            ),
                          ) : Container(),

                          //showJobPopUp==true ? Container(decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0), child: JobPopUp(),) : Container(),

                          homeModel.showJobPopUp==true ? popUpWithResumeOfTheJob(homeModel) : Container(),

                          homeModel.showJobConfirmationPopup==true
                              ? popUpConfirmJob(homeModel)
                              : Container(),

                          homeModel.showJobDeclinationPopup==true
                              ? popUpDeclinationJob(homeModel)
                              : Container(),

                          homeModel.showJobCancelmentByUser==true
                              ? popupShowUserHasCancelledJob(userModel, homeModel)
                              : Container(),

                          //reconstruindo os popups
                          homeModel.popUpsCode=='no'
                              ? Container()
                              : homeModel.popUpsCode=='pago_little_negative'  && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', () {_pago_passou_mudancaNocorreu(homeModel); }, 'Ir para mudança', () { _pago_passou_abrirMove(_querySnapshot, homeModel);})
                          //? WidgetsConstructor().customPopUp('Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Ir para mudança', 'Mudança não ocorreu', widthPercent, heightPercent, () {_pago_passou_abrirMove(_querySnapshot);}, () {_pago_passou_mudancaNocorreu();})
                              : homeModel.popUpsCode=='pago_much_negative'  && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', () {_pago_passouMuito_mudancaNaoOcorreu(homeModel, _querySnapshot); }, 'Finalizar\ne avaliar', () {_pago_passouMuito_finalizar(homeModel); })
                          //? WidgetsConstructor().customPopUp('Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', 'Finalizar mudança', widthPercent, heightPercent, () {_pago_passouMuito_mudancaNaoOcorreu();}, () {_pago_passouMuito_finalizar();})
                              : homeModel.popUpsCode=='pago_reminder'  && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+'.', 'Depois', () {_pago_reminder_depois(homeModel); }, 'Ir para mudança', () { _pago_reminder_irParaMove(_querySnapshot, homeModel);})
                          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
                          //  () {_pago_reminder_irParaMove(_querySnapshot);}, () {_pago_reminder_depois();})
                              : homeModel.popUpsCode=='pago_moveTime'
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Hora de mudança', 'Você tem uma mudança agora.',
                              'Depois', () { _pago_moveTime_depois(homeModel);}, 'Ir para mudança', () {_pago_moveTime_irParaMove(_querySnapshot, homeModel); })
                          //? WidgetsConstructor().customPopUp('Hora de mudança', 'Você tem uma mudança agora.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
                          //  () {_pago_moveTime_irParaMove(_querySnapshot);}, () {_pago_moveTime_depois();})
                              : homeModel.popUpsCode=='accepted_little_negative' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança que iniciou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
                              'Cancelar mudança', () {_accepted_passou_cancelarMove(homeModel); }, 'Aguardar', () {_accepted_passou_aguardar(homeModel); })
                          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança que iniciou às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
                          // 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
                          //  () {_accepted_passou_aguardar();}, () {_accepted_passou_cancelarMove();})
                              : homeModel.popUpsCode == 'accepted_much_negative'  && homeModel.indexPosition != null
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.',
                              'Ok', () { _accepted_passouMuito_cancelar(homeModel);})
                          //? WidgetsConstructor().customPopUp1Btn('Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.'
                          // , Colors.blue, widthPercent, heightPercent,
                          //  () {_accepted_passouMuito_cancelar();})
                              : homeModel.popUpsCode=='accepted_reminder' && homeModel.indexPosition != null
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime'] +'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.',
                              'Ok', () { _accepted_reminder(homeModel);})
                          //? WidgetsConstructor().customPopUp1Btn('Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.'
                          // , Colors.blue, widthPercent, heightPercent,
                          //  () {_accepted_reminder();})
                              : homeModel.popUpsCode=='accepted_moveTime' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança.'
                              , 'Cancelar mudança', () { _accepted_moveTime_cancelarMove(homeModel);}, 'Aguardar', () {_accepted_moveTime_aguardar(homeModel); })
                          //? WidgetsConstructor().customPopUp('Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança..'
                          // , 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
                          //  () {_accepted_moveTime_aguardar();}, () {_accepted_moveTime_cancelarMove();})
                              : homeModel.popUpsCode=='_pago_passouMuito_mudancaNaoOcorreu_alert' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você está informando que não realizou a mudança.',
                              'Não prestei o serviço', () { _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel.Uid, homeModel);}, 'Eu prestei este serviço', () { _pago_passouMuito_mudancaNaoOcorreuCancelCallback(homeModel);})
                          //? WidgetsConstructor().customPopUp('Atenção', 'Você está informando que não realizou a mudança.',
                          // 'Não prestei o serviço', 'Eu prestei este serviço', widthPercent, heightPercent, ()
                          // {_pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[indexPosition]['moveId'], userModel.Uid);},
                          // () {_pago_passouMuito_mudancaNaoOcorreuCancelCallback();})
                              : homeModel.popUpsCode=='user_informs_trucker_didnt_finished_move' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
                              'Vou voltar para terminar', () { _user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel);},
                              'Não vou voltar e concordo não receberei pelo serviço', () { _user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel);})
                          //? WidgetsConstructor().customPopUp('Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
                          // 'Vou voltar para terminar', 'Não vou voltar e concordo não receberei pelo serviço', widthPercent, heightPercent,
                          // () {_user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[indexPosition]['moveId'], userModel);},
                          // () {_user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
                              : homeModel.popUpsCode=='user_informs_trucker_didnt_make_move' && homeModel.indexPosition != null
                          //? WidgetsConstructor().customPopUp1Btn('Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.", Colors.red, widthPercent, heightPercent, () { _user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.",'Ok', () {_user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel); })
                              : homeModel.popUpsCode=='user_finished'
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
                              'Cancelar', () { _accepted_reminder(homeModel);}, 'Finalizar', () { _userFinishedAndAvaliatedMove(_querySnapshot, homeModel); }):
                          //? WidgetsConstructor().customPopUp('Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
                          // 'Finalizar', 'Cancelar', widthPercent, heightPercent, () { _userFinishedAndAvaliatedMove(_querySnapshot);} , () {_accepted_reminder();} )
                          homeModel.popUpsCode == GlobalsConstants.sitTruckerFinished
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Esperando o cliente', 'Aguardando o cliente finalizar para encerrar.', 'Ok', () { _accepted_reminder(homeModel);})
                              : Container(),


                          homeModel.isLoading==true
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
                      ),


                       */

                    )
                );

              },
            );
          },
        );
      },
    );

  }



  //pages
  Widget HomePageLoggedIn(HomeModel homeModel, UserModel userModel){

    //ELEMENTOS DA BUILD
    Widget _simpleTextOfFeedback(){

      _listPopups.clear();
      return Text("Sem serviços para você por enquanto");
    }

    Widget _customNotifyIcon(){

      return GestureDetector(

        onTap: (){
          if(_listPopups.length != 0){
            setState(() {
              showNotificationsScreen=true;
            });
          } else {
            _displaySnackBar(context, 'Você não possui notificações');
          }
        },
        child: Container(
          height: heightPercent*0.05,
          width: widthPercent*0.10,
          child: Stack(
            children: [
              Positioned(
                  top: 8.0,
                  left: 0.0,
                  right: 0.0,
                  child: Icon(Icons.add_alert, color: Colors.redAccent,)
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text(_listPopups.length.toString(), style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.5)),),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildCalendar(){

      return TableCalendar(
        //locale: 'pt_BR',
        locale: 'pt_Br',
        events: _listEvents,
        calendarController: _calendarController,
        calendarStyle: CalendarStyle(
          canEventMarkersOverflow: true,
          selectedColor: CustomColors.brown,
          todayColor: CustomColors.yellow,
          markersColor: CustomColors.blue,
          outsideDaysVisible: false,

        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,

        ),


        builders: CalendarBuilders(
          selectedDayBuilder: (context, date, events) {
            //_selectedEvents = events;
            //_selectedDate = DateUtils().convertStringFromDate(date);

            return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10.0)),
                child: Text(
                  date.day.toString(),
                  style: TextStyle(color: Colors.white),
                ));
          },
          todayDayBuilder: (context, date, events) => Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                date.day.toString(),
                style: TextStyle(color: Colors.white),
              )),

        ),


      );

    }

    String _returnMessageToUser(String code, int indexPosition){

      if(code == 'pago_little_negative'){
        return 'Mudança acontecendo agora \n\nVocê têm uma mudança que começou às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.';
      } else if(code == 'pago_much_negative'){
        return 'Atenção \n\n Havia uma mudança agendada para às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.';
      } else if(code == 'pago_reminder'){
        return 'Atenção \n\n Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'.';
      } else if(code == 'pago_moveTime'){
        return 'Hora de mudança \n\nVocê tem uma mudança agora.';
      } else if(code == 'accepted_little_negative'){
        return 'Atenção \n\n Você tem uma mudança que iniciou às '+_querySnapshot.docs[indexPosition]['selectedTime'] + '. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.';
      } else if(code == 'accepted_much_negative') {
        return 'Atenção \n\n Você tinha uma mudança às'+_querySnapshot.docs[indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.';
      } else if(code == 'accepted_reminder'){
        return 'Lembrete \n\n Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime'] +'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.';
      } else if(code == 'accepted_moveTime'){
        return 'Atenção \n\n Existe uma mudança que inicia às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança.';
      } else if(code == '_pago_passouMuito_mudancaNaoOcorreu_alert'){
        return 'Atenção \n\n Você informou que não prestou o serviço.';
      } else if(code =='user_informs_trucker_didnt_finished_move'){
        return 'Atenção \n\n O cliente informou que você ainda não finalizou o serviço.';
      } else if(code == 'user_informs_trucker_didnt_make_move'){
        return 'Atenção \n\n O cliente informou que o serviço não foi prestado por você. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por ${(GlobalsConstants.banishementTime2*7).toString()} dias.';
      } else if(code == 'user_finished'){
        return 'Mudança finalizada \n\n O cliente confirmou que a mudança terminou. Caso você confirme que tenha terminado sua parte, finalize também para avaliar, encerrar o serviço e estar apto a receber por ele.';
      } else if( code == GlobalsConstants.sitTruckerFinished){
        return 'Esperando cliente \n\n Aguardando o cliente finalizar para encerrar.';
      } else {
        return 'Erro';
      }

    }

    Widget _exibeListLine(int index, String code, HomeModel homeModel){

      return GestureDetector(
        onTap: (){

          homeModel.updatepopUpsCode(code); //atualiza para exibir a popup
        },
        child: Container(
          height: heightPercent*0.15,
          width: widthPercent*0.90,
          color: Colors.white,
          child: ListView(
            children: [
              Text(_returnMessageToUser(code, index)),
              Divider(color: CustomColors.blue,),
            ],
          ),
        ),
      );

    }

    Widget _notificationsScreen(HomeModel homeModel){

      return Container(
          height: heightPercent,
          width: widthPercent,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 40.0),
            child: ListView(
              children: [

                SizedBox(height: 15.0,),
                //close btn
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: (){
                        setState(() {
                          showNotificationsScreen=false;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Suas notificações', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                  ],
                ),

                SizedBox(height: heightPercent*0.05,),
                Divider(),

                //lista das notificações
                Container(
                  height: heightPercent*0.85,
                  child: ListView.builder(
                      itemCount: _listPopups.length,
                      itemBuilder: (BuildContext context, int index){

                        //int key = _listPopups.keys.elementAt(index);
                        //String value = _listPopups.values.elementAt(index);
                        return _exibeListLine(_listPopups.keys.elementAt(index), _listPopups.values.elementAt(index), homeModel);

                      }
                  ),
                )
                ,

              ],
            ),
          )
      );

    }

    Widget ListLine(Map map, UserModel userModel, HomeModel homeModel){

      _handleSituation(map["situacao"], userModel, map['selectedDate'], map['selectedTime'], homeModel);

      return //content
        Padding(
          padding:EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          child: Container(

              decoration: BoxDecoration(
                color: CustomColors.yellowPostIt,
                border: Border.all(
                  color: map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt,
                  width: 4.0, //                   <--- border width here
                ),

                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],


              ),

              //height: heightPercent*0.30,
              width: widthPercent*0.31, //se mudar tem que mudar o tamanho do container com texto abaixo
              //color: map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt,
              child: ListView(
                children: [
                  //icone notificação
                  map['alert'].toString().contains('trucker')  && map['alert_saw']== false
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.add_alert,
                        color: Colors.pink,
                        size: widthPercent*0.05,
                        semanticLabel: 'Novidades',
                      ),
                    ],
                  ) : Container(),

                  /*
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


               */
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 20, color: Colors.white,),
                      Text(map['selectedDate'], style: TextStyle(color: Colors.white,fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 20,color: Colors.white),
                      Text(map['selectedTime'], style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                    ],
                  ),
                  SizedBox(height: heightPercent*0.01,),
                  Container(
                    alignment: Alignment.center,
                    width: widthPercent*0.31,
                    child: Text(MoveClass().formatSituationToHuman(map['situacao']), style: TextStyle(color: map['situacao']=='aguardando' ? Colors.red : Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                  )



                  /*
              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

               */
                  /*
              map['situacao']=='accepted'
                  ? WidgetsConstructor().makeText("Você aceitou este serviço", Colors.blue, 15.0, 10.0, 5.0, null)
                  : Container(),


               */
                ],
              )
          ),
        );

    }

    Widget _whiteBackground(double top){
      return Positioned(
        left: 0.0,
        right: 0.0,
        top: heightPercent*top,
        bottom: 0.0,
        child: Container(
          color: Colors.white,
        ),
      );
    }

    Widget _helloLoggedUserText(UserModel userModel){

      return Positioned(
          top: heightPercent*0.15,
          left: 0.0,
          right: 0.0,
          child: Center(
            child: Text('Olá ${userModel.Apelido??''}', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.5)),),
          )
      );
    }

    Widget _btnVerServicos(){
      return Positioned(
          top: heightPercent*0.22,
          left: widthPercent*0.15,
          right: widthPercent*0.15,
          child: Container(
        height: heightPercent*0.08,
        width: widthPercent*0.7,
        child: RaisedButton(
          color: CustomColors.yellow,
          onPressed: (){
            setState(() {
              _showServicesPage=true;
            });
          },
          child: Text('Ver serviços disponíveis', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),),
        ),
      ));
    }


    return Container(
      child: Stack(
        children: [

          //fundo azul
          _blueBackground(),

          //fundo branco do restante da página
          _whiteBackground(0.44),

          //barra transição branca
          _whiteBarArtistic(0.30),

          //texto com ola para o user
          _helloLoggedUserText(userModel),

          //texto "Seus serviços
          Positioned(
            top: heightPercent*0.42,
            left: 0.0,
            right: 0.0,
            child: Container(
              width: widthPercent,
              alignment: Alignment.center,
              child: Text('Seus serviços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
            ),
          ),


          //alerta de outras notificacoes
          Positioned(
            top: heightPercent*0.07,
            right: widthPercent*0.05,
            child: _listPopups.isEmpty ? Icon(Icons.add_alert_outlined, color: Colors.grey[100],) : _customNotifyIcon(),
          ),

          //corpo do projeto com lista do firebase
          userIsLoggedIn==true && homeModel.popUpsCode=='no' ? Positioned(
            top: heightPercent*0.44,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    //userIsLoggedIn == true ? Text("Logado") : Text("Nao logado"),
                    SizedBox(height: 25.0,),
                    /*
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.calendar_today), onPressed: (){
                                          homeModel.updateShowCalendar(true);
                                        })
                                      ],
                                    ),
                                     */
                    //a lista de serviços
                    userModel.Uid == ""
                        ? Container()
                        :

                    StreamBuilder<QuerySnapshot>(
                      //stream: homeModel.query.snapshots(),
                      stream: query.snapshots(),
                      builder: (context, stream){
                        /*
                                        homeModel.query.snapshots().listen((event) async {

                                          if(_firstPass==false){ //first pass vai assegurar que não entre aqui nas verificações na primeira rodada (até pq carrega várias vezes). Somente depois quando estiver vigiando mudanças
                                            event.docChanges.forEach((change) {
                                              print('entrou no listener');
                                              _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                              /*
                                      if(change.doc.data()["situacao"] != 'sjjsjsjs'){

                                      }

                                       */
                                            });
                                          }


                                        });

                                         */

                        if (stream.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        else if (stream.hasError) {
                          return Center(child: Text(stream.error.toString()));
                        }

                        else if(stream.connectionState == ConnectionState.active){

                          QuerySnapshot querySnapshot = stream.data;

                          return querySnapshot.size == 0
                              ? Center(child: _simpleTextOfFeedback(),)
                              : Expanded(
                            child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                                itemCount: querySnapshot.size,
                                itemBuilder: (context, index){


                                  _querySnapshot = querySnapshot;
                                  //homeModel.updateMsgCanBeShown(true);


                                  /*
                                                //novo listener
                                                //aparentemente n precisa do listener. Quando mdua ele ja percebe
                                                FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).doc(querySnapshot.docs[index].id).collection('situacao').snapshots().listen((event) async {
                                                  event.docChanges.forEach((change) {
                                                    print('entrou no listener');
                                                    _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                                  });
                                                });

                                                 */

                                  if(index+1==querySnapshot.size){
                                    //significa que é o ultimo load. Posso fazer verificação para abrir proxima página sem apresentar erros
                                    Future.delayed(Duration(seconds: 4)).whenComplete(() => _checkIfExistMovegoingNow(querySnapshot, userModel, homeModel));
                                  }

                                  Map<String, dynamic> map = querySnapshot.docs[index].data();

                                  //click da situacao
                                  return GestureDetector(
                                    onTap: (){


                                      if(map['alert'].toString().contains('trucker')  && map['alert_saw']== false){
                                        FirestoreServices().updateAlertView(map['moveId']); //coloca como visto e remove o alerta
                                      }

                                      indexSelected = index;
                                      homeModel.updateIndexPosition(index);
                                      mapSelected = map;
                                      calculateDistance(homeModel);

                                      /*
                                            if(map['situacao'].toString()=='trucker_finished'){

                                            } else {

                                            }
                                             */

                                      homeModel.setIsLoading(false);

                                      //ATENÇÃO
                                      // sitTruckerQuitAfterPayment = 'trucker_quited_after_payment';  //<<desabilitar os controles e exibir mensagem mas permitir trocar motorista
                                      //   static String sitUserInformTruckerDidntMakeMove = 'user_informs_trucker_didnt_make_move';  //<<desabilitar os controles e exibir a mensagem
                                      //   static String sitUserInformTruckerDidntFinishedMove =
                                      //ESTAS TRES POSSIBILIDADES ACIMA NAO ESTÃO CONTEMPLADAS AQUI POIS ESTOU IMAGINANDO QUE NÃO TEM COMO CHEGAR AQUI DISPONIVEL. ESSAS SAO EXIBIDAS ASSIM QUE A SITUACAO É IDENTIFICADA EXIBE UMA POPUP E APAGA
                                      if(map['situacao'].toString()== GlobalsConstants.sitAguardando || map['situacao'].toString()== GlobalsConstants.sitAguardandoEspecifico || map['situacao'].toString()== GlobalsConstants.sitAguardandoFreteiro){

                                        homeModel.updateshowJobPopUp(true);

                                      } else if (map['situacao'].toString()== GlobalsConstants.sitTruckerFinished){

                                        homeModel.updatepopUpsCode(GlobalsConstants.sitTruckerFinished);

                                      } else if (map['situacao'].toString()== GlobalsConstants.sitAccepted){

                                        homeModel.updateshowJobPopUp(true);

                                      } else if (map['situacao'].toString()== GlobalsConstants.sitPago){

                                        homeModel.updateIndexPosition(index);
                                        homeModel.updatepopUpsCode('pago_reminder');

                                      } else if(map['situacao'].toString()== GlobalsConstants.sitReschedule){

                                        homeModel.updateIndexPosition(index);
                                        homeModel.updatepopUpsCode(GlobalsConstants.sitReschedule);

                                      }


                                    },
                                    //child: Text(map['name']),
                                    child: ListLine(map, userModel, homeModel),

                                  );



                                }
                            ),
                          );
                        }


                      },
                    ),

                    homeModel.showCalendar==true ? SingleChildScrollView(
                      child:Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CloseButton(onPressed: (){
                                homeModel.updateShowCalendar(false);
                              },)
                            ],
                          ),
                          _buildCalendar(),

                        ],
                      ) ,
                    ) : Container(),

                  ],
                ),
              ),
            ),
          ) : Container(),

          //appbar
          Positioned(
            top: 0.0,
            child: Container(
                height: heightPercent*0.12,
                width: widthPercent,
                child: Column(
                  children: [
                    SizedBox(height: 30.0,),
                    Row(
                      children: [
                        IconButton(icon: Icon(Icons.menu, color: Colors.white, size: 35.0,), onPressed: (){
                          homeModel.updateShowDrawer();
                        }),
                      ],
                    ),
                  ],
                )
            ),
          ),

          //notificatiosn page
          showNotificationsScreen==true ? _notificationsScreen(homeModel) : Container(),

          if(userModel.Listed==true && userModel.Banned==false && userModel.LatLong!=0.0) _btnVerServicos(),

          if(_showServicesPage==true) _servicesPage(homeModel, userModel),

          if(_showPopupFromTheServiceList) popUpWithResumeOfTheJob2(mapSelected, homeModel),

          //menu
          homeModel.showDrawer==true ? Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: widthPercent*0.2,
            child: MenuDrawer(),
          ) : Container(),
          //barra branca que fecha o menu
          homeModel.showDrawer==true ? Positioned(
            top: 50.0,
            bottom: 0.0,
            right: 0.0,
            left: widthPercent*0.8,
            child: GestureDetector(
              onTap: (){
                homeModel.updateShowDrawer();
              },
              child: Container(
                alignment: Alignment.topCenter,
                color: Colors.white.withOpacity(0.5),
                child: Icon(Icons.arrow_back, color: CustomColors.blue, size: 50.0,),
                //n precisa mostrar nada
              ),
            ),
          ) : Container(),

          //showJobPopUp==true ? Container(decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0), child: JobPopUp(),) : Container(),

          homeModel.showJobPopUp==true ? popUpWithResumeOfTheJob(homeModel) : Container(),

          homeModel.showJobConfirmationPopup==true
              ? popUpConfirmJob2(homeModel, userModel)
              : Container(),

          homeModel.showJobDeclinationPopup==true
              ? popUpDeclinationJob(homeModel)
              : Container(),

          homeModel.showJobCancelmentByUser==true
              ? popupShowUserHasCancelledJob(userModel, homeModel)
              : Container(),

          //reconstruindo os popups
          homeModel.popUpsCode=='no'
              ? Container()
              : homeModel.popUpsCode=='pago_little_negative'  && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']??'erro'+'.', 'Mudança não ocorreu', () {_pago_passou_mudancaNocorreu(homeModel); }, 'Ir para mudança', () { _pago_passou_abrirMove(_querySnapshot, homeModel);})
          //? WidgetsConstructor().customPopUp('Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Ir para mudança', 'Mudança não ocorreu', widthPercent, heightPercent, () {_pago_passou_abrirMove(_querySnapshot);}, () {_pago_passou_mudancaNocorreu();})
              : homeModel.popUpsCode=='pago_much_negative'  && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']??'erro'+'.', 'Mudança não ocorreu', () {_pago_passouMuito_mudancaNaoOcorreu(homeModel, _querySnapshot); }, 'Finalizar\ne avaliar', () {_pago_passouMuito_finalizar(homeModel); })
          //? WidgetsConstructor().customPopUp('Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', 'Finalizar mudança', widthPercent, heightPercent, () {_pago_passouMuito_mudancaNaoOcorreu();}, () {_pago_passouMuito_finalizar();})
              : homeModel.popUpsCode=='pago_reminder'  && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+'.', 'Depois', () {_pago_reminder_depois(homeModel); }, 'Ir para mudança', () { _pago_reminder_irParaMove(_querySnapshot, homeModel);})
          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
          //  () {_pago_reminder_irParaMove(_querySnapshot);}, () {_pago_reminder_depois();})
              : homeModel.popUpsCode=='pago_moveTime'
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Hora de mudança', 'Você tem uma mudança agora.',
              'Depois', () { _pago_moveTime_depois(homeModel);}, 'Ir para mudança', () {_pago_moveTime_irParaMove(_querySnapshot, homeModel); })
          //? WidgetsConstructor().customPopUp('Hora de mudança', 'Você tem uma mudança agora.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
          //  () {_pago_moveTime_irParaMove(_querySnapshot);}, () {_pago_moveTime_depois();})
              : homeModel.popUpsCode=='accepted_little_negative' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança que iniciou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
              'Cancelar mudança', () {_accepted_passou_cancelarMove(homeModel); }, 'Aguardar', () {_accepted_passou_aguardar(homeModel); })
          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança que iniciou às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
          // 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
          //  () {_accepted_passou_aguardar();}, () {_accepted_passou_cancelarMove();})
              : homeModel.popUpsCode == 'accepted_much_negative'  && homeModel.indexPosition != null
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+' do dia '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']??'erro'+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.',
              'Ok', () { _accepted_passouMuito_cancelar(homeModel);})
          //? WidgetsConstructor().customPopUp1Btn('Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.'
          // , Colors.blue, widthPercent, heightPercent,
          //  () {_accepted_passouMuito_cancelar();})
              : homeModel.popUpsCode=='accepted_reminder' && homeModel.indexPosition != null
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro' +'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.',
              'Ok', () { _accepted_reminder(homeModel);})
          //? WidgetsConstructor().customPopUp1Btn('Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.'
          // , Colors.blue, widthPercent, heightPercent,
          //  () {_accepted_reminder();})
              : homeModel.popUpsCode=='accepted_moveTime' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança.'
              , 'Cancelar mudança', () { _accepted_moveTime_cancelarMove(homeModel);}, 'Aguardar', () {_accepted_moveTime_aguardar(homeModel); })
          //? WidgetsConstructor().customPopUp('Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança..'
          // , 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
          //  () {_accepted_moveTime_aguardar();}, () {_accepted_moveTime_cancelarMove();})
              : homeModel.popUpsCode=='_pago_passouMuito_mudancaNaoOcorreu_alert' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você está informando que não realizou a mudança.',
              'Não prestei o serviço', () { _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel.Uid, homeModel);}, 'Eu prestei este serviço', () { _pago_passouMuito_mudancaNaoOcorreuCancelCallback(homeModel);})
          //? WidgetsConstructor().customPopUp('Atenção', 'Você está informando que não realizou a mudança.',
          // 'Não prestei o serviço', 'Eu prestei este serviço', widthPercent, heightPercent, ()
          // {_pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[indexPosition]['moveId'], userModel.Uid);},
          // () {_pago_passouMuito_mudancaNaoOcorreuCancelCallback();})
              : homeModel.popUpsCode=='user_informs_trucker_didnt_finished_move' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
              'Vou voltar para terminar', () { _user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel);},
              'Não vou voltar e concordo não receberei pelo serviço', () { _user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel);})
          //? WidgetsConstructor().customPopUp('Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
          // 'Vou voltar para terminar', 'Não vou voltar e concordo não receberei pelo serviço', widthPercent, heightPercent,
          // () {_user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[indexPosition]['moveId'], userModel);},
          // () {_user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
              : homeModel.popUpsCode=='user_informs_trucker_didnt_make_move' && homeModel.indexPosition != null
          //? WidgetsConstructor().customPopUp1Btn('Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.", Colors.red, widthPercent, heightPercent, () { _user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.",'Ok', () {_user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel); })
              : homeModel.popUpsCode=='user_finished'
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
              'Cancelar', () { _accepted_reminder(homeModel);}, 'Finalizar', () { _userFinishedAndAvaliatedMove(_querySnapshot, homeModel); }):
          //? WidgetsConstructor().customPopUp('Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
          // 'Finalizar', 'Cancelar', widthPercent, heightPercent, () { _userFinishedAndAvaliatedMove(_querySnapshot);} , () {_accepted_reminder();} )
          homeModel.popUpsCode == GlobalsConstants.sitTruckerFinished
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Esperando o cliente', 'Aguardando o cliente finalizar para encerrar.', 'Ok', () { _accepted_reminder(homeModel);})
              : homeModel.popUpsCode == GlobalsConstants.sitReschedule
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Reagendamento', 'O cliente alterou data ou horário. A nova data é ${_querySnapshot.docs[homeModel.indexPosition]['selectedDate']} às ${_querySnapshot.docs[homeModel.indexPosition]['selectedTime']}. Você pode desistir sem punições.',
              'Manter', () { _situation_Rescheduled(_querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel);}, 'Desistir', () { _situation_Rescheduled_truckerQuit(homeModel); })
              : Container(),


          homeModel.isLoading==true
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
      ),
    );
  }

  Widget HomePageUnLogged(HomeModel homeModel){

    Widget _explicationText1(String text){

      return Positioned(
        right: 800-offset > 0.0 ? 800-offset : 10.0,
        top: heightPercent*0.2,
        child: Container(
          height: heightPercent*0.2,
          width: widthPercent*0.65,
          decoration: BoxDecoration(
            color: CustomColors.yellowPostIt,
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(text, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
            ),
          ),
        ),
      );
    }

    Widget _artisticBagroundForAnim(){

      return Positioned(
          top: offset < 1280 ? 1200 - offset : offset > 1900 ? offset-1900 : -60.0,
          left: 0.0,
          right: 0.0,
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Container(
                width: widthPercent,
                child: FittedBox(
                  child: Image.asset('images/home/barrabranca.png'),
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                height: heightPercent*0.90,
                width: widthPercent,
                color: Colors.white,
              ),
            ],
          )
      );

    }

    Widget _fotografiaCarros(){

      double max;
      if(offset>=1567){
        max = 2900;
      }

      return Positioned(
        top: heightPercent*0.40,
        left: offset<1578 ? offset-1360 : 1578.0-1360.0,
        child: Container(
            width: widthPercent*0.30,
            height: heightPercent*0.30,
            child: Transform.rotate(
              //scale: ((offset*0.001)-1),
              //scale: offset-(offset*0.01),
              angle: offset<1578 ? offset*0.01 : max,
              child: Image.asset('images/home/scrollanim/fotos_car.png', fit: BoxFit.fill,),
            )
        ),
      );

    }

    Widget _fotografiaPerfil(){

      double max;
      if(offset>=1704){
        max = 1704;
      }

      return Positioned(
        top: heightPercent*0.45,
        left: offset<1704 ? offset-1578 : 1704.0-1578.0,
        child: Container(
            width: widthPercent*0.25,
            height: heightPercent*0.20,
            child: Transform.rotate(
              //scale: ((offset*0.001)-1),
              //scale: offset-(offset*0.01),
              angle: offset<1704 ? offset*0.02 : max,
              child: Image.asset('images/home/scrollanim/fotos_homem.png', fit: BoxFit.fill,),
            )
        ),
      );

    }

    Widget _textAboveCarro(String text){

      return Positioned(
        right: widthPercent*0.09,
        top: heightPercent*0.70,
        child: Text(text, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
      );
    }

    Widget _textAbovePerfil(String text){

      return Positioned(
        right: widthPercent*0.40,
        top: heightPercent*0.70,
        child: Text(text, style: TextStyle(color: Colors.redAccent, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
      );
    }

    Widget _locationIcon(){
      return Positioned(
        top: heightPercent*0.47,
        left: widthPercent*0.05,
        //child: Icon(Icons.pin_drop_sharp, color: Colors.redAccent, size: heightPercent*0.10,),
        child: Container(
          height: heightPercent*0.15,
          width: widthPercent*0.25,
          child: Image.asset('images/home/scrollanim/celmaporigin.png', fit: BoxFit.fill,),
        ),
      );
    }

    Widget _textAboveLocation(String text){

      return Positioned(
        left: widthPercent*0.05,
        top: heightPercent*0.70,
        child: Text(text, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
      );
    }

    Widget _yellowLine(){

      print(widthPercent*(offset*0.000001));

      return Positioned(
          top: heightPercent*0.22,
          right: 2210.0-2114,
          child: Container(
            height: heightPercent*0.01,
            width: widthPercent*0.35,
            color: Colors.white,
          )
      );

    }

    Widget _celPerfilDoCliente(){

      return Positioned(
        top: heightPercent*0.18,
        right: 2210.0-2114,
        child: Container(
          width: widthPercent*0.10,
          height: heightPercent*0.10,
          child: Image.asset('images/home/scrollanim/celavatar.png', fit: BoxFit.fill,),
        ),
      );

    }

    Widget _celImg(){

      double max;
      if(offset>=2185){
        max=2185.0-2114;
      }

      return Positioned(
        top: heightPercent*0.20,
        right: offset<2185 ? offset-2114 : max,
        child: Container(
          width: widthPercent*0.25,
          height: heightPercent*0.15,
          child: Image.asset('images/home/scrollanim/celmaps.png', fit: BoxFit.fill,),
        ),
      );

    }

    Widget _truckerImg(){

      double max;
      if(offset>=2185){
        max=2185.0-2114;
      }

      return Positioned(
        top: heightPercent*0.20,
        left: offset<2185 ? offset-2114 : max,
        child: Container(
          width: widthPercent*0.25,
          height: heightPercent*0.15,
          child: Image.asset('images/home/scrollanim/truckerico.png', fit: BoxFit.fill,),
        ),
      );

    }

    Widget _textAboveConectingClients(String text){

      return Positioned(
        left: 0.0,
        right: 0.0,
        top: heightPercent*0.4,
        child: Center(
          child: Text(text, textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(4.0)),),
        ),
      );
    }

    Widget _acordoImg(){

      //print('bottom'+(offset-2195).toString());

      return Positioned(

        left: 0.0,
        right: 0.0,
        bottom: offset<2810 ? offset-2550 : heightPercent*0.42,
        child: Container(
          height: heightPercent*0.25,
          width: widthPercent,
          child: FittedBox(
            child: Image.asset('images/home/scrollanim/acordopic.png'),
            fit: BoxFit.fill,
          ),
        ),
      );

    }

    Widget _logo(){

      //print('bottom'+(offset-2195).toString());

      return Positioned(

        top: heightPercent*0.15,
        child: Container(
          width: widthPercent,
          height: heightPercent*0.20,

          child: Center(
            child: FittedBox(
              child: Image.asset('images/home/scrollanim/logo.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );

    }

    Widget _web(){

      //print('bottom'+(offset-2195).toString());

      return Positioned(

        bottom: heightPercent*0.10,
        child: Container(
          width: widthPercent,
          height: heightPercent*0.25,
          child: Center(
            child: Image.asset('images/home/scrollanim/socialmedia.png'),
          ),
        ),
      );

    }

    Widget _textAboveWeb(String text){

      return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 10.0,
        child: Center(
          child: Text(text, textAlign: TextAlign.center,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(4.0)),),
        ),
      );
    }

    Widget _btnVoltarAoInicio(){

      return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: heightPercent*0.10,
        child: Center(
          child: Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],

            ),
            child: IconButton(icon: Icon(Icons.arrow_upward, color: CustomColors.yellow, size: 35.0,), onPressed: (){
              print('click');
              //final topOffset = _scrollController.position.maxScrollExtent;
              setState(() {
                offset=0.0;
              });

            }),
          ),
        ),
      );
    }

    Widget _textVoltarAoInicio(){
      return Positioned(
        left: 0.0,
        right: 0.0,
        bottom: heightPercent*0.05,
        child: Center(
          child: Container(
            child: Text('Voltar ao início', textAlign: TextAlign.center,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
          ),
        ),
      );
    }

    Widget _btnLoginDoFinalDaAnimacao(){

      return Positioned(
          top: heightPercent*0.65,
          left: 0.0,
          right: 0.0,
          child: Center(
            child: Container(
              height: heightPercent*0.10,
              width: widthPercent*0.6,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],

              ),
              child: RaisedButton(
                color: CustomColors.yellow,
                onPressed: (){
                  setState(() {
                    print('clicou no botao');
                    offset=0.0;
                    _openLoginPage(2); //dois é para encaminhar direto para para novo user na pagina login
                  });
                },
                child: Text('Registrar', textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
              ),
            ),
          )
      );
    }

    Widget _yellowButton(double top, double right, String text){
      return Positioned(
        top: (heightPercent*top)-(offset-20),
        right: widthPercent*right,
        child: Container(
          height: heightPercent*0.08,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],

          ),
          child: RaisedButton(
            color: CustomColors.yellow,
            onPressed: (){
              //click
              _openLoginPage(1); //opção 1 vai para a página de login
            },
            child: Text(text, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),

          ),
        ),
      );
    }

    Widget _welcomeText(){

      return Positioned(
          top: (heightPercent*0.30)-offset,
          left: 0.0,
          right: 0.0,
          child: Center(
            child: Text('Bem-vindo!', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(6.0)),),
          )
      );
    }

    Widget _meetUsText(){

      return Positioned(
          top: heightPercent*0.75,
          left: 0.0,
          right: 0.0,
          child: GestureDetector(
            onTap: (){
              //click
              setState(() {
                print('foi');

                double end = _scrollController.position.maxScrollExtent;
                setState(() {
                  //_scrollController.animateTo(end, duration: Duration(seconds: 20), curve: Curves.easeInOut);
                  _scrollController.animateTo(end, duration: Duration(seconds: 20), curve: Curves.easeOut);
                });

              });
            },
            child: Column(
              children: [
                Center(
                  child: Text('Deslize para conhecer\nnosso serviço', textAlign: TextAlign.center , style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5)),),
                ),
                Center(
                  child: Icon(Icons.arrow_drop_up, color: CustomColors.blue,size: 75,),
                )
              ],
            ),
          )
      );
    }





    return Container(
      height: heightPercent,
      width: widthPercent,
      color: Colors.white,
      child: Stack(
        children: [


          //inicio do corpo com fundo azul
          _blueBackground(),

          //texto welcome
          _welcomeText(),

          //barra branca
          _whiteBarArtistic(0.55),


          //itens da animação de scroll


          //vai ser: se offset maior do que 100 então aparece
          //imagem do carregador que entra com efeito 3d
          offset > 5.000 && offset<155.4 ? Positioned(
              bottom: 0.0,
              top: heightPercent*0.45,
              child: Transform(

                //transform: Matrix4.identity()..setEntry(3, 2, 0.01)..rotateX(1.0),
                transform: Matrix4.identity()..setEntry(3, 2, 0.01)..rotateX(1.0-offset/100 <= 0.0 ? 0.0 : 1.0-offset/100),

                alignment: FractionalOffset.center,
                //child: Image.asset('images/cadinfos/cnhavatar.png', fit: BoxFit.contain,),
                child: Image.asset('images/home/scrollanim/carregador.png', fit: BoxFit.contain,),

                /*
              child: RotationTransition(
                turns: _controller,
                child: Image.asset('images/cadinfos/cnhavatar.png', fit: BoxFit.contain,),

              )

               */

              )
          ) : Container(),
          //imagem igual a do carregador anterior mas estática...aqui ele vai pra esquerda fingindo uma saida da mesma imagem
          offset > 155.3 ? Positioned(
            bottom: 0.0,
            top: heightPercent*0.45,
            left: offset<469 ? 0.0 : 469-offset,
            child: Image.asset('images/home/scrollanim/carregador.png', fit: BoxFit.contain,),
          ) : Container(),

          //fundo branco subindo - fora da ordem
          offset>850 ? _artisticBagroundForAnim() : Container(),

          //sequencia de caixas subindo
          offset > 120 && offset < 1335 ? Positioned(
            bottom: -250+offset < 0.0 ? -250+offset : 0.0,
            right: 0.0,
            child: Image.asset('images/home/scrollanim/rightbox.png', fit: BoxFit.contain,),
          ) : Container(),
          offset > 135  && offset < 1350 ? Positioned(
            bottom: -300+offset < 0.0 ? -300+offset : 0.0,
            left: 0.0,
            child: Image.asset('images/home/scrollanim/leftbox.png', fit: BoxFit.contain,),
          ) : Container(),
          offset > 135  && offset < 1300 ? Positioned(
            bottom: -400+(offset-40) < 0.0 ? -400+(offset-40) : 0.0,
            left: widthPercent*0.25,
            child: Image.asset('images/home/scrollanim/middlebox.png', fit: BoxFit.contain,),
          ) : Container(),

          //texto explicativo 1
          offset>448 && offset < 1970 ? _explicationText1('Você disponibiliza algumas informações') : Container(),
          //aqui é quando acontece o fundo branco subindo...mas ele esdtá acima fora de ordem para encaixar na animação nas sobreposições

          offset > 1360 && offset < 2104 ? _fotografiaCarros() : Container(),

          offset > 1600 && offset < 2104 ? _textAboveCarro('Foto do\nveículo') : Container(),

          offset > 1578 && offset < 2104 ? _fotografiaPerfil() : Container(),

          offset > 1704 && offset < 2104 ? _textAbovePerfil('Sua foto') : Container(),

          offset > 1800 && offset < 2104 ? _locationIcon() : Container(),

          offset > 1850 && offset < 2104 ? _textAboveLocation('Posição') : Container(),


          offset > 2114 && offset < 2810 ? _celImg() : Container(),

          offset > 2114 && offset < 2810 ? _truckerImg() : Container(),

          offset > 2354 && offset < 2810 ? _yellowLine() : Container(),

          offset > 2200 && offset < 2810 ? _celPerfilDoCliente() : Container(),

          offset > 2180  && offset < 2810 ? _textAboveConectingClients('Nós conectamos você\na novos clientes') : Container(),

          offset > 2372 ? _acordoImg() : Container(),

          offset > 2900 ? _logo() : Container(),

          offset > 3000 && offset < 3380 ? _web() : Container(),

          offset > 3000 && offset < 3380 ? _textAboveWeb('Expanda sua rede') : Container(),


          //btn voltar ao inicio

          //lista fake para dar profundidade na tela na animação
          Positioned(
              top: 100.0,
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: heightPercent,
                width: widthPercent,
                child: Scrollbar(
                  child: ListView( //essa listview é apenas para a tela crescer e poder ser rolada
                    controller: _scrollController,
                    children: [
                      Container(),
                      SizedBox(height: 3900.0,),
                      Container(color: Colors.transparent, width: 500.0, height: 100.0,)
                    ],
                  ),
                ),
              )
          ),

          //texto conheça o serviço
          offset < 48  ? _meetUsText() : Container(),

          offset > 3400 ? _btnVoltarAoInicio() : Container(),

          offset > 3400 ? _textVoltarAoInicio() : Container(),

          offset > 3400 ? _btnLoginDoFinalDaAnimacao() : Container(),

          //fim da animação

          //botão amarelo
          //verifica se o menu está aberto. Se estiver some o botão para não confundir o fundo
          homeModel.showDrawer==false ? _yellowButton(0.15, 0.05, 'Login') : Container(),


          //fim dos itens de scroll

          //appbar
          Positioned(
            top: 0.0,
            child: Container(
                height: heightPercent*0.12,
                width: widthPercent,
                child: Column(
                  children: [
                    SizedBox(height: 30.0,),
                    Row(
                      children: [
                        IconButton(icon: Icon(Icons.menu, color: Colors.white, size: 35.0,), onPressed: (){
                          homeModel.updateShowDrawer();
                        }),
                      ],
                    ),
                  ],
                )
            ),
          ),
          //menu
          homeModel.showDrawer==true ? Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: widthPercent*0.2,
            child: MenuDrawer(),
          ) : Container(),
          //barra branca que fecha o menu
          homeModel.showDrawer==true ? Positioned(
            top: 50.0,
            bottom: 0.0,
            right: 0.0,
            left: widthPercent*0.8,
            child: GestureDetector(
              onTap: (){
                homeModel.updateShowDrawer();
              },
              child: Container(
                alignment: Alignment.topCenter,
                color: Colors.white.withOpacity(0.5),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 50.0,),
                //n precisa mostrar nada
              ),
            ),
          ) : Container(),



        ],
      ),
    );

  }

  Widget _servicesPage(HomeModel homeModel, UserModel userModel){

    print(userModel.Vehicle);
    print('veiculo');

    //final double _latLong = _currentPosition.latitude+_currentPosition.longitude;
    //double startAtval = _latLong-(0.05*5.0);
    double startAtval = userModel.LatLong-(0.05*5.0);
    //final double endAtval = _latLong+(0.05*5.0);
    final double endAtval = userModel.LatLong+(0.05*5.0);
    final double dif = -0.07576889999999992;
    startAtval = (dif+startAtval);


    Query _query = FirebaseFirestore.instance.collection('agendamentos_aguardando')
        .where('latlong', isGreaterThanOrEqualTo: startAtval)
        .where('latlong', isLessThan: endAtval)
    //.where('banido', isEqualTo: false);
    //.where('listed', isEqualTo: true)
        .where('carro', isEqualTo: userModel.Vehicle)
        .where('situacao', isEqualTo: 'aguardando');


    Widget _CloseButton(){

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CloseButton(
            onPressed: (){
              setState(() {
                _showServicesPage=false;
              });
            },
          )
        ],
      );

    }

    Widget _textoDeEachLineOfTheList({String text, double size, Color color}){

      return Container(
        width: widthPercent*0.9,
        child: Text(text, style: TextStyle(color: color, fontSize: ResponsiveFlutter.of(context).fontSize(size)),),
      );

    }


    Widget _EachLineOfTheList(Map map){

      var escada = map['escada'];
      print(escada);
      final _escada = escada==false ? 'nao' : map['lances_escada'].toString();

      return Container(
        height: heightPercent*0.35,
        width: widthPercent*0.95,
        child: Stack(
          children: [

            //fundo do card
            Positioned(
                top: heightPercent*0.015,
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      height: heightPercent*0.20,
                      margin: const EdgeInsets.only(bottom: 6.0), //Same as `blurRadius` i guess
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      width: widthPercent*0.9,
                    )
                ),),

            //card amarelo com preço
            Positioned(
              top: 0.0,
              right: 0.0,
              child: Container(
                width: widthPercent*0.35,
                height: heightPercent*0.08,
                color: CustomColors.yellow,
                alignment: Alignment.center,
                child: Text('R\$${map['valor'].toStringAsFixed(2)??''}', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
              )
            ),

            Positioned(
                left: widthPercent*0.02,
                top: heightPercent*0.01,
                bottom: 0.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //primeiro icone com data
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: CustomColors.brown,),
                        SizedBox(width: widthPercent*0.01,),
                        Text(map['selectedDate']??'', style: TextStyle(color: CustomColors.brown, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
                      ],
                    ),

                    SizedBox(height: heightPercent*0.01,),

                    //segundo icone com hora
                    Row(
                      children: [
                        Icon(Icons.schedule, color: CustomColors.brown,),
                        SizedBox(width: widthPercent*0.01,),
                        Text(map['selectedTime']??'', style: TextStyle(color: CustomColors.brown, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
                      ],
                    ),

                    SizedBox(height: heightPercent*0.015,),

                    _textoDeEachLineOfTheList(text: 'Origem: '+map['endereco_origem']??'', size: 2.0, color: Colors.black),

                    SizedBox(height: heightPercent*0.01,),

                    _textoDeEachLineOfTheList(text: 'Destino: '+map['endereco_destino']??'', size: 2.0, color: Colors.black),

                    SizedBox(height: heightPercent*0.01,),

                    _textoDeEachLineOfTheList(text: 'Distancia: '+map['distancia'].toStringAsFixed(2)+' Km'??'', size: 2.0, color: Colors.black),

                    _textoDeEachLineOfTheList(text: 'Ajudantes: '+map['ajudantes'].toString()??'', size: 2.0, color: Colors.black),

                    _textoDeEachLineOfTheList(text: 'Escada: '+ _escada, size: 2.0, color: Colors.black),





                  ],
                )
            ),



          ],
        ),
      );

    }

    Widget _textoTitulo(){

      return Text('Pessoas precisando dos seus serviços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.5)),);

    }

    Widget _lista(){

      return Container(

          height: heightPercent*0.70,
          width: widthPercent*0.9,
          child:Column(
            children: [

              StreamBuilder<QuerySnapshot>(
                stream: _query.snapshots(),
                builder: (context, stream){

                  if (stream.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (stream.hasError) {
                    return Center(child: Text(stream.error.toString()));
                  }

                  QuerySnapshot querySnapshot = stream.data;

                  return querySnapshot.size == 0
                      ? Center(child: Text("Não existem mudanças próximas."),)
                      :Expanded(
                    child: ListView.builder(
                      itemCount: querySnapshot.size,
                      itemBuilder: (context, index) {

                        Map<String, dynamic> map = querySnapshot.docs[index].data();

                        return GestureDetector(
                          onTap: (){

                            mapSelected = map;
                            _placeListenerInSituation(mapSelected['moveId']);
                            setState(() {
                              _showPopupFromTheServiceList=true;
                            });


                          },
                          child: _EachLineOfTheList(map),
                        );

                      },
                    ),
                  );

                },
              ),

            ],
          )

      );

    }

    /*
    Widget _popupDoServico(){

      return Container(
        color: Colors.white,
        width: widthPercent,
        height: heightPercent,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: heightPercent*0.06),
              //botão de fechar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CloseButton(
                    onPressed: (){
                      setState(() {
                        _showPopupFromTheServiceList=false;
                      });
                    },
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.02,),
              //simbolo com interregoração
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: widthPercent*0.35,
                    height: heightPercent*0.10,
                    child: Text('?', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(8))),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],

                    ),
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.03,),
              Text('Endereços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              Text('Origem: ${MapClone['endereco_origem']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.01,),
              Text('Destino: ${MapClone['endereco_destino']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.03,),
              Text('Detalhes', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              homeModel.distance != null
                  ?Text('Distancia: '+homeModel.distance.toStringAsFixed(2)+"km", style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)))
                  :Text('Calculando distância', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Ajudantes requisitados: '+MapClone['ajudantes'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Data: '+MapClone['selectedDate'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Horário: '+MapClone['selectedTime'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              //Text('Observações : '+MapClone['ps']??'não', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              MapClone['escada']??false == true
                  ? Text('Lances de escada: '+MapClone['lances_escada']??'não', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)))
                  : Container(),
              Text('Valor: R\$'+MapClone['valor'].toStringAsFixed(2).toString().replaceAll('.', ','), style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
              SizedBox(height: heightPercent*0.04),


            ],
          ),
        ),
      );

    }

     */

    return Container(
      height: heightPercent,
      width: widthPercent,
      color: Colors.white,
      child: Column(
        children: [

          SizedBox(height: heightPercent*0.05,),

          _CloseButton(),

          SizedBox(height: heightPercent*0.02,),

          _textoTitulo(),

          SizedBox(height: heightPercent*0.05,),

          _lista(),

        ],
      ),
    );
  }








  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();

    //para animação da tela
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        //offset = _scrollController.hasClients ? _scrollController.offset : 0.1;
        offset = _scrollController.hasClients ? _scrollController.offset : offset;

        print('offset quando dps de atualizar' + offset.toString());
      });
    });



  }

  @override
  void dispose() {
    super.dispose();

    _calendarController.dispose();

  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    // isto é exercutado após todo o layout ser renderizado

    if(goForTheCheck==true){
      //alterar o query e chamar setstate
      goForTheCheck=false;
      setState(() {

      });
    }

  }

  //FLOW DE LOGIN
  Future<void> _startVerifyLoginStatus(HomeModel homeModel, NewAuthService newAuthService) async {

    await _checkFBconnection();
    if(userIsLoggedIn==true){

      //verificação se é facebook ou e-mail. Se for facebook não precisa verificar e-mail verified
      if(newAuthService.isFacebookUser()==true){
        print('nao precisa checar e-mail');
        _ifUserIsVerified(userModelGLobal, homeModel, newAuthService);
      } else {
        print('checar email');
        _checkEmailVerified(userModelGLobal, _newAuthService, homeModel);
      }

    }

  }

  void _checkFBconnection() async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {

        setState(() {
          userIsLoggedIn=false;
        });


      } else {


        //setState(() { mudei aqui
        userIsLoggedIn=true;
        needCheck=true;
        //});

      }
    });
  }

  Future<void> _checkEmailVerified(UserModel userModel, NewAuthService newAuthService, HomeModel homeModel) async {

    //load data in model
    await newAuthService.loadUser();

    //check if email is verified
    bool isUserEmailVerified = false;
    isUserEmailVerified = await newAuthService.isUserEmailVerified();
    if(isUserEmailVerified==true){

      _ifUserIsVerified(userModel, homeModel, newAuthService);

    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  Future<void> _ifUserIsVerified(UserModel userModel,HomeModel homeModel, NewAuthService newAuthService) async {

    await newAuthService.loadUser();
    //now check if there is basic data in sharedPrefs
    bool existsDataInSharedPrefs = await SharedPrefsUtils().thereIsBasicInfoSavedInShared();
    if(existsDataInSharedPrefs==true){
      //if there is data, load it
      await SharedPrefsUtils().loadBasicInfoFromSharedPrefs(userModel, );

    } else {
      //if there is not, load it from FB
      //await newAuthService.loadUserBasicDataInSharedPrefs(userModel);
      //the rest will be done on another metch to check what need to be done in case of more info required
      //await FirestoreServices().loadUserInfos(userModel, () {_onSucessLoadInfos(userModel);}, () {_onFailureLoadInfos(userModel);});

    }


    everyProcedureAfterUserInfoIsLoad(userModel, homeModel, newAuthService);
  }
  //FIM DO FLOW DE LOGIN


  //TRATAMENTO DAS SITUACOES
  Future<void> _checkIfExistMovegoingNow(QuerySnapshot querySnapshot, UserModel userModel, HomeModel homeModel) async {

    void _populateCalendarList(QuerySnapshot querySnapshot){

      _listEvents = {};
      /*
    _listEvents = {
      DateTime.now() : ['Agora'],
    };

     */

      int cont=0;
      while(cont<querySnapshot.size){

        DateTime _date = DateServices().convertDateAndTimeFromString(querySnapshot.docs[cont]['selectedDate'], querySnapshot.docs[cont]['selectedTime']);
        _listEvents[_date] = [querySnapshot.docs[cont]['endereco_origem']];
        //_listEvents[DateTime.now()] = ['Teste1'];
        cont++;
      }

      setState(() {
        _listEvents = _listEvents;
      });
      //_listEvents[DateTime.now().add(Duration(days: 1))] = ['Teste'];



    }

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


    if(homeModel.msgCanBeShown==false){
      homeModel.updateMsgCanBeShown(true);
      _querySnapshot = querySnapshot;

      _populateCalendarList(querySnapshot);

      int i = 0;
      while(i<querySnapshot.size){

        homeModel.updateIndexPosition(i);

        _handleSituation(querySnapshot.docs[i]['situacao'], userModel, querySnapshot.docs[i]['selectedDate'], querySnapshot.docs[i]['selectedTime'], homeModel);
        /*
        //caso o user tenha relatado problemas
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserInformTruckerDidntMakeMove){
          homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);
        }

        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
          homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);
        }

        //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){
          _displaySnackBar(context, 'Você está voltando para concluir a mudança. Abrindo a mudança');

          MoveClass moveClass = MoveClass();

          void _onSucess(){
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveDayPage(moveClass)));
          }


          FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});

        }

        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserFinished){
          homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);
        }

        //caso esteja pago, procedimenros abaixo
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitPago){


          DateTime scheduledDate = DateUtils().convertDateFromString(querySnapshot.docs[i]['selectedDate']);
          DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, querySnapshot.docs[i]['selectedTime']);
          final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

          if(dif.isNegative) {
            //a data já expirou

            if(dif>-240){

              homeModel.updatepopUpsCode('pago_little_negative');

              //neste caso o user fechou o app e abriu novamente

            } else {

              //a mudança já se encerrou há tempos
              homeModel.updatepopUpsCode('pago_much_negative');

            }


          } else if(dif<=120 && dif>15){

            homeModel.updatepopUpsCode('pago_reminder');
            //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

          } else if(dif<=15){

            homeModel.updatepopUpsCode('pago_moveTime');

          } else {

            //do nothing, falta mt ainda

          }



        }

        //caso esteja aceito mas o user ainda não pagou
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitAccepted){

          DateTime scheduledDate = DateUtils().convertDateFromString(querySnapshot.docs[i]['selectedDate']);
          DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, querySnapshot.docs[i]['selectedTime']);
          final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

          if(dif.isNegative) {


            //a data já expirou

            if (dif > -240) {
              homeModel.updatepopUpsCode('accepted_little_negative');

              //neste caso o user fechou o app e abriu novamente

            } else {
              //a mudança já se encerrou há tempos
              homeModel.updatepopUpsCode('accepted_much_negative');
            }





          } else if(dif<=120 && dif>15){

            homeModel.updatepopUpsCode('accepted_reminder');
            //exibe a popup informando que está na hora mas o user ainda n pagou


          } else if(dif<=15){

            homeModel.updatepopUpsCode('accepted_moveTime');


          } else {

            //do nothing, falta mt ainda

          }


        }

         */

        i++;
      }

      //_firstPass=false;
    }


  }

  void _handleSituation(String sit, UserModel userModel, String date, String time, HomeModel homeModel){


    if(homeModel.userGotMsg==false){ //se for true o usuer já viu uma mensagem

      if(sit == GlobalsConstants.sitUserInformTruckerDidntMakeMove){

        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);
        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitUserInformTruckerDidntMakeMove;
        }

      }

      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);

        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitUserInformTruckerDidntFinishedMove;
        }
      }

      //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){
        _displaySnackBar(context, 'Você está voltando para concluir a mudança. Abrindo a mudança');

        MoveClass moveClass = MoveClass();

        void _onSucess(){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MoveDayPage(moveClass)));
        }


        FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});

      }

      if(sit == GlobalsConstants.sitUserFinished){

        homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);
        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitUserFinished;
        }

      }

      //caso esteja pago, procedimenros abaixo
      if(sit == GlobalsConstants.sitPago || sit == GlobalsConstants.sitTruckerIsGoingToMove){


        DateTime scheduledDate = DateServices().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateServices().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateServices().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {
          //a data já expirou

          if(dif>-240){
            homeModel.updatepopUpsCode('pago_little_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'pago_little_negative';
            }

            //neste caso o user fechou o app e abriu novamente

          } else {
            homeModel.updatepopUpsCode('pago_much_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'pago_much_negative';
            }
            //a mudança já se encerrou há tempos

          }


        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('pago_reminder');

          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'pago_reminder';
          }
          //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

        } else if(dif<=15){

          homeModel.updatepopUpsCode('pago_moveTime');

          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'pago_moveTime';
          }

        } else {

          //do nothing, falta mt ainda

        }



      }

      //caso esteja aceito mas o user ainda não pagou
      if(sit == GlobalsConstants.sitAccepted){

        DateTime scheduledDate = DateServices().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateServices().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateServices().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {


          //a data já expirou

          if (dif > -240) {
            homeModel.updatepopUpsCode('accepted_little_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'accepted_little_negative';
            }
            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            homeModel.updatepopUpsCode('accepted_much_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'accepted_much_negative';
            }

          }





        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('accepted_reminder');
          //exibe a popup informando que está na hora mas o user ainda n pagou
          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'accepted_reminder';
          }


        } else if(dif<=15){

          homeModel.updatepopUpsCode('accepted_moveTime');

          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'accepted_moveTime';
          }

        } else {

          //do nothing, falta mt ainda

        }


      }

      if(sit == GlobalsConstants.sitReschedule){
        homeModel.updatepopUpsCode(GlobalsConstants.sitReschedule);
        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitReschedule;
        }
      }


    } else {
      //aqui significa que ja exibiu a primeira popup. Então agora vamos guardar as infos como notificações
      //e o user vai pdoer ver clicando num botão de exibir notificações]

      if(sit == GlobalsConstants.sitUserInformTruckerDidntMakeMove){

        //homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);
        if(homeModel.indexPosition != null){

          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            if(!_listPopups.containsKey(homeModel.indexPosition)){ //evita salvar repetido
              _listPopups[homeModel.indexPosition] = GlobalsConstants.sitUserInformTruckerDidntMakeMove;
            }
          }

        }


      }

      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
        //homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);
        if(homeModel.indexPosition != null){
          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            _listPopups[homeModel.indexPosition] = GlobalsConstants.sitUserInformTruckerDidntFinishedMove;
          }

        }

      }

      //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){


        //esta situação não se aplica aqui
        /*
        MoveClass moveClass = MoveClass();

        void _onSucess(){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MoveDayPage(moveClass)));
        }


        FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});
         */
      }

      if(sit == GlobalsConstants.sitUserFinished){
        //homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);
        if(homeModel.indexPosition != null){
          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            _listPopups[homeModel.indexPosition] = GlobalsConstants.sitUserFinished;
          }
        }

      }

      //caso esteja pago, procedimenros abaixo
      if(sit == GlobalsConstants.sitPago || sit == GlobalsConstants.sitTruckerIsGoingToMove){


        DateTime scheduledDate = DateServices().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateServices().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateServices().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {
          //a data já expirou

          if(dif>-240){
            //homeModel.updatepopUpsCode('pago_little_negative');

            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                _listPopups[homeModel.indexPosition] = 'pago_little_negative';
              }

            }

            //neste caso o user fechou o app e abriu novamente

          } else {
            //homeModel.updatepopUpsCode('pago_much_negative');
            //a mudança já se encerrou há tempos
            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                _listPopups[homeModel.indexPosition] = 'pago_much_negative';
              }

            }

          }


        } else if(dif<=120 && dif>15){

          //homeModel.updatepopUpsCode('pago_reminder');
          //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'pago_reminder';
            }
          }

        } else if(dif<=15){


          //homeModel.updatepopUpsCode('pago_moveTime');
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'pago_moveTime';
            }
          }

        } else {

          //do nothing, falta mt ainda

        }



      }

      //caso esteja aceito mas o user ainda não pagou
      if(sit == GlobalsConstants.sitAccepted){

        DateTime scheduledDate = DateServices().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateServices().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateServices().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {


          //a data já expirou

          if (dif > -240) {
            //homeModel.updatepopUpsCode('accepted_little_negative');
            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                if(!_listPopups.containsKey(homeModel.indexPosition)) { //evita salvar repetido
                  _listPopups[homeModel.indexPosition] = 'accepted_little_negative';
                }
              }

            }

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            //homeModel.updatepopUpsCode('accepted_much_negative');
            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                _listPopups[homeModel.indexPosition] = 'accepted_much_negative';
              }
            }
          }





        } else if(dif<=120 && dif>15){

          //homeModel.updatepopUpsCode('accepted_reminder');
          //exibe a popup informando que está na hora mas o user ainda n pagou
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'accepted_reminder';
            }

          }


        } else if(dif<=15){

          //homeModel.updatepopUpsCode('accepted_moveTime');
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'accepted_moveTime';
            }

          }

        } else {

          //do nothing, falta mt ainda

        }


      }

      if(sit == GlobalsConstants.sitReschedule){

        if(homeModel.indexPosition != null){

          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            if(!_listPopups.containsKey(homeModel.indexPosition)){ //evita salvar repetido
              _listPopups[homeModel.indexPosition] = GlobalsConstants.sitReschedule;
            }
          }

        }

      }


    }

    print(_listPopups);

    /*
    if(homeModel.userGotMsg==false){ //se for true o usuer já viu uma mensagem

      if(sit == GlobalsConstants.sitUserInformTruckerDidntMakeMove){

        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);

      }

      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);
      }

      //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){
        _displaySnackBar(context, 'Você está voltando para concluir a mudança. Abrindo a mudança');

        MoveClass moveClass = MoveClass();

        void _onSucess(){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MoveDayPage(moveClass)));
        }


        FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});

      }

      if(sit == GlobalsConstants.sitUserFinished){
        homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);

      }

      //caso esteja pago, procedimenros abaixo
      if(sit == GlobalsConstants.sitPago || sit == GlobalsConstants.sitTruckerIsGoingToMove){


        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {
          //a data já expirou

          if(dif>-240){
            homeModel.updatepopUpsCode('pago_little_negative');


            //neste caso o user fechou o app e abriu novamente

          } else {
            homeModel.updatepopUpsCode('pago_much_negative');
            //a mudança já se encerrou há tempos

          }


        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('pago_reminder');
          //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

        } else if(dif<=15){


          homeModel.updatepopUpsCode('pago_moveTime');

        } else {

          //do nothing, falta mt ainda

        }



      }

      //caso esteja aceito mas o user ainda não pagou
      if(sit == GlobalsConstants.sitAccepted){

        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {


          //a data já expirou

          if (dif > -240) {
            homeModel.updatepopUpsCode('accepted_little_negative');

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            homeModel.updatepopUpsCode('accepted_much_negative');
          }





        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('accepted_reminder');
          //exibe a popup informando que está na hora mas o user ainda n pagou


        } else if(dif<=15){

          homeModel.updatepopUpsCode('accepted_moveTime');

        } else {

          //do nothing, falta mt ainda

        }


      }


    }



     */

  }

  //FIM DOS TRATAMENTOS DAS SITUACOES






















  //FUNCOES DE CALLBACK PARA CADA SITUAÇÃO QUE EXIBE POPUP


  //opção 1 - mudança tá paga, mas já passou. Exibe opções abaixo
  //popUpsCode=='pago_little_negative'
  void _pago_passou_finalizar(){
    //finalizar uma mudança
    print('finalizar mudança');
  }

  Future<void> _pago_passou_abrirMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_passou_mudancaNocorreu(HomeModel homeModel){
    print('mudança nunca ocorreu');
    //lidar com isso no bd. pegar os motivos e provavelmente punir o freteiro
    homeModel.updatepopUpsCode('_pago_passouMuito_mudancaNaoOcorreu_alert');

  }

  //opção 2 - mudança tá paga, mas já passou há mt tempo. Exibe opções
  //popUpsCode=='pago_much_negative'
  void _pago_passouMuito_finalizar(HomeModel homeModel){
    //aqui signfica que a mudança ocorreu bem para o motorista e ele vai finalizar. Vai ficar faltando o user pra fechar o ticket
    FirestoreServices().updateMoveSituation(GlobalsConstants.sitTruckerFinished, _querySnapshot.docs[homeModel.indexPosition]['moveId']);
    homeModel.updatepopUpsCode('no');

  }

  void _pago_passouMuito_mudancaNaoOcorreu(HomeModel homeModel, QuerySnapshot querySnapshot){

    homeModel.updatepopUpsCode('_pago_passouMuito_mudancaNaoOcorreu_alert');
  }

  void _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(String moveId, String truckerId, HomeModel homeModel){

    homeModel.setIsLoading(true);

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, 'trucker desistiu após pagamento do user');
      homeModel.setIsLoading(false);
      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){
      isLoading=false;
      _displaySnackBar(context, "Ocorreu um erro. Tente nvoamente");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});
  }

  void _pago_passouMuito_mudancaNaoOcorreuCancelCallback(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  //opção 3 - mudança tá paga e começa logo.
  //popUpsCode=='pago_reminder'
  Future<void> _pago_reminder_irParaMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);


    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_reminder_depois(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  //opção 4 - mudança tá paga e tá na hora de fazer
  //opUpsCode=='pago_moveTime'
  Future<void> _pago_moveTime_irParaMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    FirestoreServices().updateMoveSituation(GlobalsConstants.sitTruckerIsGoingToMove, _moveClass.idPedido);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_moveTime_depois(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }


  //agora opções quando o user ainda não pagou
  //já deu a hora mas passou pouco, o user ainda nao pagou.
  //popUpsCode=='accepted_little_negative'
  void _accepted_passou_aguardar(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  void _accepted_passou_cancelarMove(HomeModel homeModel){

    void _onCancelSucess(){
      queryWasLoaded=false;
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Você cancelou a mudança.');
    }

    void _onCancelFailure(){
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }

    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});
  }


  //usuario nao pagou e já passou muito do tempo
  //popUpsCode == 'accepted_much_negative'
  void _accepted_passouMuito_cancelar(HomeModel homeModel){

    //precisa avaliar mal o user
    void _onCancelSucess(){
      _displaySnackBar(context, 'Você cancelou a mudança.');
      homeModel.updatepopUpsCode('no');
    }

    void _onCancelFailure(){
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
      homeModel.updatepopUpsCode('no');
    }

    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});

  }

  //reminder - o user ainda nao pagou mas a mudança começaria em breve
  //popUpsCode=='accepted_reminder'
  void _accepted_reminder(HomeModel homeModel) {
    homeModel.updatepopUpsCode('no');
  }

  //deu a hora mas o user nao pagou. DEixar o motorista escolher
  //popUpsCode=='accepted_moveTime'
  void _accepted_moveTime_aguardar(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  void _accepted_moveTime_cancelarMove(HomeModel homeModel){

    //avaliar mal o user
    void _onCancelSucess(){
      _displaySnackBar(context, 'Você cancelou a mudança.');
    }

    void _onCancelFailure(){
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }


    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});
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

  void _user_informed_truckerDidntFinishedMoveCancel(String truckerId, String moveId, HomeModel homeModel){

    homeModel.setIsLoading(true);

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, GlobalsConstants.punishmentEntry2);
      FirestoreServices().createBanishmentEntry(truckerId, GlobalsConstants.banishmentInform1, GlobalsConstants.banishementTime1);
      _displaySnackBar(context, "Você está punido com o banimento da plataforma por uma semana. Nesta semana você pode concluir as mudanças que estão agendadas mas não aparecerá para novos clientes até encerrar o prazo.");

      homeModel.setIsLoading(false);
      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Ocorreu um erro. Tente nvoamente");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});

  }

  void _user_informed_truckerDidndShowUp(String truckerId, String moveId, HomeModel homeModel){

    homeModel.setIsLoading(true);

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, GlobalsConstants.punishmentEntry3);
      FirestoreServices().createBanishmentEntry(truckerId, GlobalsConstants.banishmentInform2, GlobalsConstants.banishementTime2);
      _displaySnackBar(context, "Você está punido com o banimento da plataforma por ${GlobalsConstants.banishementTime2.toString()} semanas. Neste tempo você pode concluir as mudanças que estão agendadas mas não aparecerá para novos clientes até encerrar o prazo.");

      homeModel.setIsLoading(false);
      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Ocorreu um erro");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});

  }

  Future<void> _userFinishedAndAvaliatedMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);

    _displaySnackBar(context, 'Encerrando mudança e carregando sistema de avaliação');

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AvaliationPage(_moveClass)));

    });

  }

  Future<void> _situation_Rescheduled(String moveId, HomeModel homeModel) async {

    void _onfinish(){

      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){

    }

    FirestoreServices().loadMoveSituationBackup(moveId, () {_onfinish();}, () {_onFail();});


  }

  void _situation_Rescheduled_truckerQuit(HomeModel homeModel){

    void _onCancelSucess(){
      queryWasLoaded=false;
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Você desistiu da mudança.');
    }

    void _onCancelFailure(){
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }

    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});

  }



  //FIM DAS FUNÇÕES DE CALLBACK DOS POPUPS



  /*
  Widget ListLine(Map map, UserModel userModel, HomeModel homeModel){

    _handleSituation(map["situacao"], userModel, map['selectedDate'], map['selectedTime'], homeModel);

    return Padding(padding: EdgeInsets.all(5.0),
      child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellowPostIt, map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt, 4.0, 4.0),
          width: widthPercent*0.31, //se mudar tem que mudar o tamanho do container com texto abaixo
          //color: map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt,
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

              /*
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


               */
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20, color: Colors.white,),
                  Text(map['selectedDate'], style: TextStyle(color: Colors.white,fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.schedule, size: 20,color: Colors.white),
                  Text(map['selectedTime'], style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                ],
              ),
              SizedBox(height: heightPercent*0.015,),
              Container(
                alignment: Alignment.center,
                width: widthPercent*0.31,
                child: Text(MoveClass().formatSituationToHuman(map['situacao']), style: TextStyle(color: map['situacao']=='aguardando' ? Colors.red : Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
              )



              /*
              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

               */
              /*
              map['situacao']=='accepted'
                  ? WidgetsConstructor().makeText("Você aceitou este serviço", Colors.blue, 15.0, 10.0, 5.0, null)
                  : Container(),


               */
            ],
          )
      ),
    );

  }
   */

  Widget JobPopUp(HomeModel homeModel) {

    String lances = mapSelected['lances_escada'].toString();
    if(lances == 'null'){
      lances = 'não';
    }

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(
                onPressed: (){
                  homeModel.updateshowJobPopUp(false);
                  homeModel.updateshowJobConfirmationPopup(false);
                  homeModel.updateshowJobConfirmationPopup(false);

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
          homeModel.distance != null
              ?Text('Distancia: '+homeModel.distance.toStringAsFixed(2)+"km")
              :Text('Calculando'),
          SizedBox(height: 20.0,),
          Text('Ajudantes requisitados: '+mapSelected['ajudantes'].toString()),
          Text('Data: '+mapSelected['selectedDate'].toString()),
          Text('Horário: '+mapSelected['selectedTime'].toString()),
          Text('Observações : '+mapSelected['ps']),
          mapSelected['escada'] == true
              ? Text('Lances de escada: '+lances)
              : Container(),
          Text('Valor: R\$'+mapSelected['valor'].toStringAsFixed(2)),
          SizedBox(height: 20.0,),
          //botoes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  homeModel.updateshowJobDeclinationPopup(true);
                },
                child: WidgetsConstructor().makeButton(Colors.redAccent, Colors.white, mapSelected['situacao'] == 'accepted' ? widthPercent*0.8 : widthPercent*0.4, 60.0, 2.0, 5.0, mapSelected['situacao'] == 'accepted' ? "Desistir" : "Negar", Colors.white, 17.0),
              ),

              GestureDetector(
                onTap: (){
                  homeModel.updateshowJobConfirmationPopup(true);
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

  Widget popUpConfirmJob(HomeModel homeModel){

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
                        homeModel.updateshowJobConfirmationPopup(true);
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
                        homeModel.setIsLoading(true);

                        //ConfirmJob(homeModel);

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

  Widget popUpWithResumeOfTheJob(HomeModel homeModel){

    String _lances = mapSelected['lances_escada'].toString();
    if(_lances == 'null'){
      _lances = 'não';
    }
    String _ps = mapSelected['ps'].toString();
    if(_ps == 'null'){
      _ps = 'não';
    }

    return Container(
        color: Colors.white,
        width: widthPercent,
        height: heightPercent,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: heightPercent*0.06),
              //botão de fechar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CloseButton(
                    onPressed: (){
                      homeModel.updateshowJobPopUp(false);
                      homeModel.updateshowJobConfirmationPopup(false);
                      homeModel.updateshowJobDeclinationPopup(false);
                    },
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.02,),
              //simbolo com interregoração
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: widthPercent*0.35,
                    height: heightPercent*0.10,
                    child: Text('?', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(8))),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],

                    ),
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.03,),
              Text('Endereços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              Text('Origem: ${mapSelected['endereco_origem']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.01,),
              Text('Destino: ${mapSelected['endereco_destino']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.03,),
              Text('Detalhes', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              homeModel.distance != null
                  ?Text('Distancia: '+homeModel.distance.toStringAsFixed(2)+"km", style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)))
                  :Text('Calculando distância', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Ajudantes requisitados: '+mapSelected['ajudantes'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Data: '+mapSelected['selectedDate'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Horário: '+mapSelected['selectedTime'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Observações : '+_ps, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              mapSelected['escada'] == true
                  ? Text('Lances de escada: '+_lances, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)))
                  : Container(),
              Text('Valor: R\$'+mapSelected['valor'].toStringAsFixed(2).toString().replaceAll('.', ','), style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
              SizedBox(height: heightPercent*0.04),

              //botão de aceitar
              mapSelected['situacao'] == GlobalsConstants.sitAguardando
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: widthPercent*0.6, height: heightPercent*0.08,
                    child: RaisedButton(color: CustomColors.yellow ,onPressed: (){
                      homeModel.updateshowJobConfirmationPopup(true);
                    },
                      child: Text('Aceitar serviço', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                    ),
                  )
                ],
              )
                  : Container(),

              //espaço
              SizedBox(height: 15.0,),

              //botão de negar
              mapSelected['situacao'] == GlobalsConstants.sitAguardando
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: widthPercent*0.6, height: heightPercent*0.08,
                    child: RaisedButton(color: Colors.redAccent ,onPressed: (){
                      homeModel.updateshowJobDeclinationPopup(true);
                    },
                      child: Text('Rejeitar', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                    ),
                  )
                ],
              )
                  : Container(),

              SizedBox(height: 10.0,),

              mapSelected['situacao'] != GlobalsConstants.sitAguardando
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: widthPercent*0.6, height: heightPercent*0.08,
                    child: RaisedButton(color: Colors.red, splashColor: Colors.grey[300] ,onPressed: (){

                      if(mapSelected['situacao'] == GlobalsConstants.sitAccepted){
                        _accepted_passou_cancelarMove(homeModel);
                      } else if(mapSelected['situacao'] == GlobalsConstants.sitPago){
                        _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(mapSelected['moveId'], userModelGLobal.Uid, homeModel);
                      } else {
                        ///cancelamento sem punição. Se precisar de mais opções adicionar acima
                        _accepted_passou_cancelarMove(homeModel);
                      }


                    },
                      child: Text('Desistir do serviço', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                    ),
                  )
                ],
              )
                  : Container(),




            ],
          ),
        )
    );
  }


  /*
  Widget popUpWithResumeOfTheJob(HomeModel homeModel){

    String _lances = mapSelected['lances_escada'].toString();
    if(_lances == 'null'){
      _lances = 'não';
    }
    String _ps = mapSelected['ps'].toString();
    if(_ps == 'null'){
      _ps = 'não';
    }

    return Container(
      color: Colors.black54.withOpacity(0.6),
      width: widthPercent,
      height: heightPercent,
      child: Container(
        color: Colors.white,
        width: widthPercent*0.9,
        height: heightPercent*0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: 15.0,),
              Stack(
                children: [
                  Container(
                    width: 200.0,
                    height: 300.0,
                    child: Image.asset('images/home/popupimg.jpg', fit: BoxFit.fill,),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CloseButton(
                        onPressed: (){
                          homeModel.updateshowJobPopUp(false);
                          homeModel.updateshowJobConfirmationPopup(false);
                          homeModel.updateshowJobDeclinationPopup(false);
                        },
                      )
                    ],
                  ),
                ],
              ),
              Text('Situação: '+mapSelected['situacao']),
              Text('Origem: '+mapSelected['endereco_origem']),
              Text('Destino: '+mapSelected['endereco_destino']),
              homeModel.distance != null
                  ?Text('Distancia: '+homeModel.distance.toStringAsFixed(2)+"km")
                  :Text('Calculando'),
              Text('Ajudantes requisitados: '+mapSelected['ajudantes'].toString()),
              Text('Data: '+mapSelected['selectedDate'].toString()),
              Text('Horário: '+mapSelected['selectedTime'].toString()),
              Text('Observações : '+_ps),
              mapSelected['escada'] == true
                  ? Text('Lances de escada: '+_lances)
                  : Container(),
              Text('Valor: R\$'+mapSelected['valor'].toStringAsFixed(2)),
              SizedBox(height: 20.0,),
              //botão de aceitar
              mapSelected['situacao'] == GlobalsConstants.sitAguardando
                  ? Container(width: widthPercent*0.9,height: 60.0,
                child: RaisedButton(color: Colors.blue, splashColor: Colors.grey[300] ,onPressed: (){
                  homeModel.updateshowJobConfirmationPopup(true);
                },
                  child: WidgetsConstructor().makeText('Aceitar serviço', Colors.white, 17.0, 0.0, 0.0, 'center'),
                ),
              ) : Container(),
              mapSelected['situacao'] != GlobalsConstants.sitAguardando
                  ? Container(width: widthPercent*0.9,height: 60.0,
                child: RaisedButton(color: Colors.red, splashColor: Colors.grey[300] ,onPressed: (){

                  if(mapSelected['situacao'] == GlobalsConstants.sitAccepted){
                    _accepted_passou_cancelarMove(homeModel);
                  } else if(mapSelected['situacao'] == GlobalsConstants.sitPago){
                    _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(mapSelected['moveId'], userModelGLobal.Uid, homeModel);
                  } else {
                    ///cancelamento sem punição. Se precisar de mais opções adicionar acima
                    _accepted_passou_cancelarMove(homeModel);
                  }


                },
                  child: WidgetsConstructor().makeText('Desistir do serviço', Colors.white, 17.0, 0.0, 0.0, 'center'),
                ),
              ) : Container(),




            ],
          ),
        ),
      ),
    );
  }
   */
  Widget popUpDeclinationJob(HomeModel homeModel){

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
                        homeModel.updateshowJobDeclinationPopup(false);
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

                        DenyJob(homeModel);

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

  Widget popupShowUserHasCancelledJob(UserModel userModel, HomeModel homeModel){

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

                        homeModel.updateshowJobCancelmentByUser(false);
                        FirestoreServices().deleteCancelmentsNotify(userModel.Uid);

                        //agora cancelar as notificacoes locais (lembretes)
                        //notificação de 24h de antecedencia
                        NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, userModel.MoveIdCancelment);
                        //notificação de 2h de antecedencia]
                        NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, userModel.MoveIdCancelment+'2');



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

  void ConfirmJob(HomeModel homeModel, UserModel userModel) async {

    await FirestoreServices().confirmJobAceptance2(userModel, mapSelected['id_contratante'],() {_onSucessConfirmJob(homeModel);}, () {_onFailConfirmJob(homeModel);});
    mapSelected['situacao']='accepted';
  }

  void _onSucessConfirmJob(HomeModel homeModel){
    //coloca um alerta de novidade para o usuário
    FirestoreServices().alertSetUserAlert(mapSelected['moveId']);
    //cria uma notificação para o freteiro 24 horas antes
    DateTime moveDate = MoveClass().formatMyDateToNotify(mapSelected['selectedDate'], mapSelected['selectedTime']);
    DateTime notifyDateTime = DateServices().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, mapSelected['moveId'], "Lembrete: Mudança amanhã às "+mapSelected['selectedTime'], notifyDateTime);

    //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
    notifyDateTime = DateServices().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, mapSelected['moveId']+'2', "Lembrete: Mudança em duas horas às "+mapSelected['selectedTime'] , notifyDateTime);

    homeModel.updateshowJobConfirmationPopup(false);
    //homeModel.updateshowJobPopUp(false);
    _showPopupFromTheServiceList=false;
    _showServicesPage=false;
    homeModel.updateshowJobConfirmationPopup(false);
    homeModel.setIsLoading(false);

    _displaySnackBar(context, "Pronto. Esta mudança está agendada e foi adicionada a sua agenda.");
  }

  void _onFailConfirmJob(HomeModel homeModel){
    homeModel.setIsLoading(false);
    _displaySnackBar(context, "Ocorreu um erro. Tente novamente");
  }

  void DenyJob(HomeModel homeModel) async {

    void _onSucessDenyJob(){

      FirestoreServices().alertSetUserAlert(mapSelected['moveId']);

      //cancelando as notificações
      NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, mapSelected['moveId']); //24h early
      NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, mapSelected['moveId']+'2'); //2h early

      mapSelected['situacao']='deny';
      mapSelected['id_freteiro']=null;
      mapSelected['nome_freteiro']=null;

      homeModel.updateshowJobDeclinationPopup(false);
      homeModel.updateshowJobPopUp(false);
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Você rejeitou este serviço.");
    }

    void _onFailureDenyJob(){

      //do nothing (tava dando erro sempre)
      /*
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Ocorreu um erro. Tente novamente.");

       */
      homeModel.updateshowJobDeclinationPopup(false);
      homeModel.updateshowJobPopUp(false);
      homeModel.setIsLoading(false);
    }

    await FirestoreServices().confirmJobDeny(mapSelected['moveId'], () {_onSucessDenyJob();}, () {_onFailureDenyJob();});

  }

  Future<void> calculateDistance(HomeModel homeModel) async {

    double _distance = await MoveClass().getTheDistanceFromTwoAddress(mapSelected['endereco_origem'], mapSelected['endereco_destino']);
    homeModel.updateDistance(_distance);
  }

  Future<void> everyProcedureAfterUserInfoIsLoad(UserModel userModel, HomeModel homeModel, NewAuthService newAuthService) async {

    checkIfNeedUserInfos(userModel, homeModel, newAuthService);  //completa as informações de cadastro do usuário

    checkIfUserBanishmentIsOver(userModel);

    loadApelido(userModel);

    loadCarType(userModel);

    _loadUserListedBannedAndLatlong(userModel);


    /*
    if(homeModel.query==null){ //atualiza a query apenas se for a primeira vez (null)
      updateQuery(userModel.Uid, homeModel);
    }

     */


    //MANEJO DA QUERY
    void updateQuery(String id, HomeModel homeModel){
      //homeModel.updateQuery(FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).where('id_freteiro', isEqualTo: id).orderBy('selectedDate'));
      query = FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).where('id_freteiro', isEqualTo: id).orderBy('selectedDate');
    }

    updateQuery(userModel.Uid, homeModel);


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

  Future<void> loadApelido(UserModel userModel) async {

    String apelido = await SharedPrefsServices().loadApelido();
    if(apelido == '' || apelido == 'null'){
      FirestoreServices().getUserApelido(userModel);
    } else {
      userModel.updateApelido(apelido);
    }

  }

  Future<void> loadCarType(UserModel userModel) async {

    String _carro = await SharedPrefsUtils().loadIndividualInfo('vehicle')??'';
    
    if(_carro == '' || _carro == 'null'){
      FirestoreServices().getUserCarTypeo(userModel);
    } else {
      userModel.updateVehicle(_carro);
    }

  }

  //verifica se o user tá banido. Se estiver n exibe o botão para ver serviços
  Future<void> _loadUserListedBannedAndLatlong(UserModel userModel) async {


    FirestoreServices().getUserListedAndBanned(userModel);


  }

  Future<void> loadUserBanned(UserModel userModel) async {

    String _carro = await SharedPrefsUtils().loadIndividualInfo('vehicle')??'';

    if(_carro == '' || _carro == 'null'){
      FirestoreServices().getUserCarTypeo(userModel);
    } else {
      userModel.updateVehicle(_carro);
    }

  }

  Future<void> checkIfNeedUserInfos(UserModel userModel, HomeModel homeModel, NewAuthService newAuthService) async {

    userModel.updateUid(newAuthService.loadUserIDfromFirebase());

    int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
    //pageDone é 99 se não tiver nada no shared
    //verificação redundante

    if(pageDone==99){
      //nao existe data. Pegar no firebase
      _userIsOk();//check if truckers cad is complete in firebase
    } else if(pageDone==0){
      //
      //significa que ele ainda não preencheu nada. Deve ser um novo usuario
      /*
      VoidCallback callBack = () => {
        Navigator.of(context).pop(),
        // code on continue comes here
        goToPage1OfUserInfos(context),
      };

      CustomPurePopup alert = CustomPurePopup(heightPercent, widthPercent, 'Informações', "Você ainda não iniciou o cadastro de suas informações. Você ainda não está aparecendo para os clientes. Demora menos de três minutos.", 'Depois', 'Completar', pageDone, callBack);
       */


      /*
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );

       */

      void callback(){
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage1OfUserInfos(context);
      }
      _showCustomDialogFullScreen('Informações não preenchidas', 'Você ainda não iniciou o cadastro de suas informações e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});
      //CustomPurePopup alert = CustomPurePopup(heightPercent, widthPercent, 'Informações', "Você ainda não iniciou o cadastro de suas informações. Você ainda não está aparecendo para os clientes. Demora menos de três minutos.", 'Depois', 'Completar', pageDone, callBack);

    } else if(pageDone==1){

      //obs: se pageDone == 1 significa que vai abrir a página 2 (a 1 está ok). Os dados são carregados abaixo para ficarem acessiveis no entanto eles n correpsondem a página 2.
      //carregue os dados da pagina então, que ja foi preenchida em outro momento
      //SharedPrefsUtils().loadPageOneInfo(userModel);
      loadPageOneInfo(userModel);

      void callback () {
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage2OfUserInfos(context);
      };

      _showCustomDialogFullScreen('Faltando informações', 'Você ainda não completou seu cadastro e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});


      //SharedPrefsUtils().loadPageOneInfo(userModel);
      //goToPage2OfUserInfos(context);
    } else if(pageDone==2) {

      SharedPrefsUtils().loadPageOneInfo(userModel);
      //n precisa carregar dados pois é só a cnh

      //exibe um dialog pro user escolher

      void callback () {
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage3OfUserInfos(context);
      }

      _showCustomDialogFullScreen('Faltando informações', 'Você ainda não completou seu cadastro e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});

    } else if(pageDone==3){

      SharedPrefsUtils().loadPageOneInfo(userModel);
      SharedPrefsUtils().loadPageThreeInfo(userModel);
      //exibe um dialog pro user escolher

      void callback () {
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage4OfUserInfos(context);
      }

      _showCustomDialogFullScreen('Faltando informações', 'Você ainda não completou seu cadastro e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});


    } else if(pageDone==4){

      //user ja completou tudo
      SharedPrefsUtils().loadPageOneInfo(userModel);
      //obs a página dois só tem a cnh, n precisa ler
      SharedPrefsUtils().loadPageThreeInfo(userModel);
      userModel.updateTruckerInfoOk(true);
      //a pagina 4 tb nao precisa ler pq sao dados bancários q n vamos manter no shared

      //novos métodos após todas verificações
      checkIfUserHasCancelmentsNotify(userModel, homeModel);
    }


  }


  void _showCustomDialogFullScreen(String title, String text, String btn1Text, String btn2Text, int progress, VoidCallback okCallBack){

    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: Duration(milliseconds: 400),
      context: context,
      pageBuilder: (_, __, ___) {
        return Scaffold(
          body: Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.white,
              height: heightPercent*0.85,
              width: widthPercent*0.9,
              child: Column(
                children: [
                  //imagem
                  Center(
                    child: Container(
                      height: heightPercent*0.3,
                      width: widthPercent*0.7,
                      child: Image.asset('images/popup/socialmediaimg.png', fit: BoxFit.contain,),
                    ),
                  ),
                  //titulo
                  Text(title, textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.bold ,color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
                  //barra
                  Padding(
                      child: Stack(
                        children: [
                          Container(height: heightPercent*0.03, decoration: WidgetsConstructor().myBoxDecoration(Colors.grey[300], Colors.grey[300], 1.0, 45.0), ),
                          //obs: widthPercent*0.60 representa 100 da barra completa.
                          //obs 2 - progress==99 significa 0 e progress==4 significa 100%
                          Container(height: heightPercent*0.03, width: progress==99 || progress == 0 ? 0.0 : progress==1 ? widthPercent*0.20 : progress==2 ? widthPercent*0.45 : progress==3 ? widthPercent*0.65 : widthPercent*0.95, decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellow, CustomColors.yellow, 1.0, 45.0), ),
                          Container(
                            alignment: Alignment.center,
                            width: widthPercent, child: Text(progress==99 || progress==0 ? '0%' : progress==1 ? '25%' : progress==2 ? '50%' : progress==3 ? '75%' : '100%', style: TextStyle(color: Colors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),)
                        ],
                      ),
                      padding: EdgeInsets.all(35.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.report, color: Colors.redAccent,)
                    ],
                  ),
                  Padding(
                      child: Text(text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0)),
                  SizedBox(height: heightPercent*0.04,),
                  Row(
                    children: [
                      SizedBox(width: widthPercent*0.03,),
                      Container(
                        width: widthPercent*0.4,
                        height: heightPercent*0.10,
                        child: RaisedButton(
                          color: Colors.white,
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text(btn1Text, textAlign: TextAlign.center ,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                        ),
                      )  ,
                      SizedBox(width: widthPercent*0.03,),
                      Container(
                        width: widthPercent*0.4,
                        height: heightPercent*0.10,
                        child: RaisedButton(
                          color: CustomColors.yellow,
                          onPressed: (){
                            okCallBack();
                          },
                          child: Text(btn2Text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                        ),
                      )  ,
                      SizedBox(width: widthPercent*0.03,),
                    ],
                  ),


                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );

  }


  Future<void> checkIfUserHasCancelmentsNotify(UserModel userModel, HomeModel homeModel) async {

    FirestoreServices().checkIfUserHasCancelmentsNotify(userModel.Uid, userModel, () {_onSucessShowUserCancelment(userModel, homeModel);});
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

    String dateTodayString = DateServices().giveMeTheDateToday();
    DateTime dateToday = DateServices().convertDateFromString(dateTodayString);
    DateTime dateLimit = DateServices().convertDateFromString(data);
    dateLimit = DateServices().addDaysToDate(dateLimit, prazoEmDias);

    int difference = DateServices().compareTwoDatesInMinutes(dateToday, dateLimit);
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

  void _onSucessShowUserCancelment(UserModel userModel, HomeModel homeModel){
    homeModel.updateshowJobCancelmentByUser(true);

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
    //se esta aqui falta cadastro
    goToPage1OfUserInfos(context);
  }

  void goToPage1OfUserInfos(BuildContext context){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TruckerInfosCadUserInfo()));
  }

  void goToPage2OfUserInfos(BuildContext context){
    //Navigator.of(context).pop();
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

  Future<void> loadPageOneInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String value = (prefs.getString('image').toString());
    userModel.updateImage(value);
    value = (prefs.getString('apelido').toString());
    userModel.updateApelido(value);
    double value2 = (prefs.getDouble('latlong'));
    userModel.updateLatLoong(value2);
    value = (prefs.getString('phone').toString());
    userModel.updatePhone(value);
    value = (prefs.getString('address').toString());
    userModel.updateAddress(value);

  }











  Widget popUpWithResumeOfTheJob2(Map map, HomeModel homeModel){

    String _lances = map['lances_escada'].toString();
    if(_lances == 'null'){
      _lances = 'não';
    }
    String _ps = map['ps'].toString();
    if(_ps == 'null'){
      _ps = 'não';
    }

    return Container(
        color: Colors.white,
        width: widthPercent,
        height: heightPercent,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: heightPercent*0.05),
              //botão de fechar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CloseButton(
                    onPressed: (){
                      setState(() {
                        _showPopupFromTheServiceList=false;
                      });
                    },
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.01,),
              //texto serviço disponível
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Serviço disponível', style: TextStyle(color: CustomColors.brown, fontSize: ResponsiveFlutter.of(context).fontSize(4.0))),
                ],
              ),
              SizedBox(height: heightPercent*0.02,),
              //simbolo com interregoração
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: widthPercent*0.30,
                    height: heightPercent*0.07,
                    child: Text('?', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(6))),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],

                    ),
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.03,),
              Text('Endereços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              SizedBox(height: heightPercent*0.01,),
              Text('Origem: ${map['endereco_origem']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.01,),
              Text('Destino: ${map['endereco_destino']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.03,),
              Text('Detalhes', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              SizedBox(height: heightPercent*0.01,),
              Text('Distancia: '+map['distancia'].toStringAsFixed(2)+"km", style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Ajudantes requisitados: '+map['ajudantes'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Data: '+map['selectedDate'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Horário: '+map['selectedTime'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Observações : '+_ps, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              map['escada'] == true
                  ? Text('Lances de escada: '+_lances, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)))
                  : Container(),
              SizedBox(height: heightPercent*0.02,),
              //valor
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: widthPercent*0.6,
                    height: heightPercent*0.07,
                    color: CustomColors.blue,
                    child: Center(
                      child: Text('Valor: R\$'+map['valor'].toStringAsFixed(2).toString().replaceAll('.', ','), style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
                    ),
                  ),
                ],
              ),

              SizedBox(height: heightPercent*0.04),

              //botão de aceitar
              map['situacao'] == GlobalsConstants.sitAguardando
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: widthPercent*0.8, height: heightPercent*0.09,
                    child: RaisedButton(color: CustomColors.yellow ,onPressed: (){
                      //homeModel.updateshowJobConfirmationPopup(true);
                      if(_situationWithListener==GlobalsConstants.sitAguardando){
                        //entao abre a outra janela pedindo confirmação
                        homeModel.updateshowJobConfirmationPopup(true);
                      } else {
                        _displaySnackBar(context, "Este serviço não está mais disponível.");
                        setState(() {
                          _showPopupFromTheServiceList=false;
                        });
                      }

                      /*
                      if(mapSelected['situacao']== GlobalsConstants.sitAguardando){
                        //executar
                        //_getThisJob();
                        homeModel.updateshowJobConfirmationPopup(true);

                      } else {
                        _displaySnackBar(context, "Este serviço não está mais disponível. Desculpe");
                      }
                       */
                      },
                      child: Text('Aceitar serviço', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                    ),
                  )
                ],
              )
                  : Container(),

              SizedBox(height: 10.0,),





            ],
          ),
        )
    );
  }

  Widget popUpConfirmJob2(HomeModel homeModel, UserModel userModel){

    return Stack(
      children: [

        //fundo escuro
        Container(
          height: heightPercent,
          width: widthPercent,
          color: Colors.black.withOpacity(0.7),
        ),

        //janela branca com elementos internos
        Positioned(
          top: heightPercent*0.2,
          left: widthPercent*0.05,
          right: widthPercent*0.05,
          child: Container(
          color: Colors.white,
          height: heightPercent*0.54,
          width: widthPercent*0.9,
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
                        homeModel.updateshowJobConfirmationPopup(false);
                      },
                    )
                  ],
                ),
                SizedBox(height: heightPercent*0.02),
                Text('Atenção', style: TextStyle(color: CustomColors.brown, fontSize: ResponsiveFlutter.of(context).fontSize(5.0)),),
                SizedBox(height: heightPercent*0.02),
                Text('Você deseja aceitar este serviço nestas condições?', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
                SizedBox(height: heightPercent*0.15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: widthPercent*0.55,
                      height: heightPercent*0.10,
                      child: RaisedButton(
                        color: CustomColors.yellow,
                        onPressed: (){

                          if(_situationWithListener == GlobalsConstants.sitAguardando){
                            homeModel.setIsLoading(true);
                            ConfirmJob(homeModel, userModel);
                          } else {
                            _displaySnackBar(context, 'Este serviço não está mais disponível');
                            homeModel.updateshowJobConfirmationPopup(false);
                          }

                        },
                        child: Text('Pegar serviço', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.5)),),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),),

        //icone
        Positioned(
          top: heightPercent*0.16,
          left: 0.0,
          right: 0.0,
          child: Container(
            width: widthPercent*0.25,
            height: heightPercent*0.10,
            child: Icon(Icons.error, color: CustomColors.blue, size: widthPercent*0.25,),

          ),
        ),


      ],
    );
  }

  Future<void> _placeListenerInSituation(String moveId){

    var situationRef = FirebaseFirestore.instance.collection(FirestoreServices .agendamentosPath).doc(moveId);
    situationRef.snapshots().listen((DocumentSnapshot event) async {
      
      _situationWithListener = event.data()['situacao'];

      //se a situação mudar, chamar o método que lida com as situações
      /*
      if(event.data()['situacao'] !=  currentSituation){
        moveClass.situacao = event.data()['situacao'];
        moveClassGlobal.situacao = moveClass.situacao;
        homePageModel.updateSituationInMoveClass(moveClassGlobal.situacao);
        _handleSituation(userModel, moveClass, homePageModel);
      }
      
       */
      
    });
  }



  void _openLoginPage(int sit){
    /*
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => LoginChooseView()));

     */
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => NewLoginPage(sit)));

  }


  Widget _blueBackground(){
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: 0.0,
      bottom: heightPercent*0.30,
      child: Container(
        color: CustomColors.blue,
      ),
    );
  }

  Widget _whiteBarArtistic(double top){

    return Positioned(
      top: heightPercent*top,
      left: 0.0,
      right: 0.0,
      child: Container(
          width: widthPercent,
          height: heightPercent*0.22,
          child: FittedBox(
            child: Image.asset('images/home/barrabranca.png'),
            fit: BoxFit.fill,
          )
      ),
    );
  }








  Future<void> testeNovaMudanca(double valor){

    String date = DateServices().giveMeTheTimeNow();
    String today = DateServices().giveMeTheDateToday();

    CollectionReference userLocation = FirebaseFirestore.instance.collection('agendamentos_aguardando');
    return userLocation
        .doc(date)
        .set({
      'ajudantes' : 1,
      'alert' : 'user',
      'alert_saw' : false,
      'carro' : 'pickupP',
      'endereco_destino' : 'Estr. Monan Grande, 31 - Badu, Niterói - RJ, 24320-040, Brasil - Rio de Janeiro',
      'endereco_origem' : 'Tv. Petronilha Miranda, 49 - Barreto, Niterói - RJ, 24110-657, Brasil - Rio de Janeiro',
      'escada' : false,
      'id_contratante' : 'b5RkDgc9hbeIovmviGN6tvbSiEu1',
      'id_freteiro' : 'vQtalKKBk5hW1bmCFKW1m2QzLWF2',
      'lances_escada' : 0,
      'moveId' : date,
      'nome_freteiro' : 'Thiago fretes',
      'pago' : null,
      'placa' : 'kvp8h60',
      'ps': null,
      'selectedDate' : today,
      'selectedTime' : '20:00',
      'situacao' : 'accepted',
      'valor' : valor,

    });

  }

  /*
  _getCurrentLocation() {
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

   */

}








//antes da mudança da query do motorista
/*
import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fretes_go_freteiro/classes/banishment_class.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_bank_data.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/pages/email_verify_view.dart';
import 'package:fretes_go_freteiro/login/pages/new_login_page.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/menu/drawer.dart';
import 'package:fretes_go_freteiro/models/home_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/avaliation_page.dart';
import 'package:fretes_go_freteiro/pages/move_day_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/services/sharedPrefs_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/custom_pure_popup.dart';
import 'package:fretes_go_freteiro/utils/date_utils.dart';
import 'package:fretes_go_freteiro/utils/globals_constants.dart';
import 'package:fretes_go_freteiro/utils/notificationMeths.dart';
import 'package:fretes_go_freteiro/utils/popup.dart';
import 'package:fretes_go_freteiro/utils/popup_new.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:date_format/date_format.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

//https://stackoverflow.com/questions/61755268/how-to-create-custom-calendar-in-flutter

class HomePageState extends State<HomePage> with AfterLayoutMixin<HomePage>, SingleTickerProviderStateMixin {

  FirebaseAuth auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  UserModel userModelGLobal;
  NewAuthService _newAuthService;

  bool userIsLoggedIn;
  bool needCheck=true;

  double heightPercent;
  double widthPercent;

  Map mapSelected;
  int indexSelected;

  bool queryWasLoaded=false;
  bool _firstPass=true;

  CalendarController _calendarController;
  Map<DateTime, List> _listEvents;

  Query query;

  bool goForTheCheck=true;

  bool thereIsApopUponScreen = false;


  //now trying this
  //https://brainsandbeards.com/blog/how-to-add-local-notifications-to-flutter-app <<este funcionou

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  QuerySnapshot _querySnapshot;

  Map<int, String> _listPopups = Map();
  String popsShownStr;
  int popsShownInt;

  bool showNotificationsScreen=false;


  ScrollController _scrollController;
  double offset=1.0;

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();

    //para animação da tela
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        //offset = _scrollController.hasClients ? _scrollController.offset : 0.1;
        offset = _scrollController.hasClients ? _scrollController.offset : offset;

        print('offset quando dps de atualizar' + offset.toString());
      });
    });



  }


  /* LOGIN PATH
    Is user logged in? yes ---------is email verified? yes ----------- there is file in sharedPrefs? yes ----load it then check if need cad infos trucker? yes --- go cad pages
                       no---do nothing                --no, go verify                                no ------load it from Firestore---then check if need cad infos trucker? yes ----go cad pages
     */



  @override
  void dispose() {
    super.dispose();

    _calendarController.dispose();

  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    // isto é exercutado após todo o layout ser renderizado

    if(goForTheCheck==true){
      //alterar o query e chamar setstate
      goForTheCheck=false;
      setState(() {

      });
    }

  }

  Future<void> startVerifyLoginStatus(HomeModel homeModel, NewAuthService newAuthService) async {

    await checkFBconnection();
    if(userIsLoggedIn==true){

      //verificação se é facebook ou e-mail. Se for facebook não precisa verificar e-mail verified
      if(newAuthService.isFacebookUser()==true){
        print('nao precisa checar e-mail');
        _ifUserIsVerified(userModelGLobal, homeModel, newAuthService);
      } else {
        print('checar email');
        checkEmailVerified(userModelGLobal, _newAuthService, homeModel);
      }

    }

  }

  void updateQuery(String id, HomeModel homeModel){
    //homeModel.updateQuery(FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).where('id_freteiro', isEqualTo: id).orderBy('selectedDate'));
    query = FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).where('id_freteiro', isEqualTo: id).orderBy('selectedDate');
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

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        userModelGLobal = userModel;

        /*
        if(userModel.Uid != '' && queryWasLoaded==false){
          queryWasLoaded=true;
          updateQuery(userModel.Uid);
        }

         */

        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {
            _newAuthService = newAuthService;



            /*
            Future.delayed(Duration(seconds: 5)).then((_) {
              testeNovaMudanca(300.00);
            });

             */

            return ScopedModelDescendant<HomeModel>(
              builder: (BuildContext context, Widget child, HomeModel homeModel){

                if(userIsLoggedIn==null){
                  startVerifyLoginStatus(homeModel, newAuthService);
                }

                return Scaffold(
                    key: _scaffoldKey,
                    drawer: MenuDrawer(),
                    body: Container(
                      height: heightPercent,
                      width: widthPercent,
                      color: Colors.white,

                      child: userIsLoggedIn==true ? HomePageLoggedIn(homeModel, userModel) : HomePageUnLogged(homeModel),

                      /*
                      child: Stack(
                        children: [

                          //texto "Seus serviços
                          Positioned(
                            top: heightPercent*0.18,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                              width: widthPercent,
                              alignment: Alignment.center,
                              child: Text('Seus serviços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                            ),
                          ),


                          //alerta de outras notificacoes
                      Positioned(
                        top: heightPercent*0.17,
                        right: 10.0,
                        child: _listPopups.isEmpty ? Icon(Icons.add_alert_outlined, color: Colors.grey[100],) : customNotifyIcon(),
                      ),

                          //corpo do projeto com lista do firebase
                          userIsLoggedIn==true && homeModel.popUpsCode=='no' ? Positioned(
                            top: heightPercent*0.20,
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: Center(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [

                                    //userIsLoggedIn == true ? Text("Logado") : Text("Nao logado"),
                                    SizedBox(height: 25.0,),
                                    /*
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.calendar_today), onPressed: (){
                                          homeModel.updateShowCalendar(true);
                                        })
                                      ],
                                    ),
                                     */
                                    //a lista de serviços
                                    userModel.Uid == ""
                                        ? Container()
                                        :

                                    StreamBuilder<QuerySnapshot>(
                                      //stream: homeModel.query.snapshots(),
                                      stream: query.snapshots(),
                                      builder: (context, stream){
                                        /*
                                        homeModel.query.snapshots().listen((event) async {

                                          if(_firstPass==false){ //first pass vai assegurar que não entre aqui nas verificações na primeira rodada (até pq carrega várias vezes). Somente depois quando estiver vigiando mudanças
                                            event.docChanges.forEach((change) {
                                              print('entrou no listener');
                                              _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                              /*
                                      if(change.doc.data()["situacao"] != 'sjjsjsjs'){

                                      }

                                       */
                                            });
                                          }


                                        });

                                         */

                                        if (stream.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        }

                                        else if (stream.hasError) {
                                          return Center(child: Text(stream.error.toString()));
                                        }

                                        else if(stream.connectionState == ConnectionState.active){

                                          QuerySnapshot querySnapshot = stream.data;

                                          return querySnapshot.size == 0
                                              ? Center(child: simpleTextOfFeedback(),)
                                              : Expanded(
                                            child: GridView.builder(
                                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3),
                                                itemCount: querySnapshot.size,
                                                itemBuilder: (context, index){


                                                  _querySnapshot = querySnapshot;
                                                  //homeModel.updateMsgCanBeShown(true);


                                                  /*
                                                //novo listener
                                                //aparentemente n precisa do listener. Quando mdua ele ja percebe
                                                FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).doc(querySnapshot.docs[index].id).collection('situacao').snapshots().listen((event) async {
                                                  event.docChanges.forEach((change) {
                                                    print('entrou no listener');
                                                    _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                                  });
                                                });

                                                 */

                                                  if(index+1==querySnapshot.size){
                                                    //significa que é o ultimo load. Posso fazer verificação para abrir proxima página sem apresentar erros
                                                    Future.delayed(Duration(seconds: 4)).whenComplete(() => checkIfExistMovegoingNow(querySnapshot, userModel, homeModel));
                                                  }

                                                  Map<String, dynamic> map = querySnapshot.docs[index].data();

                                                  //click da situacao
                                                  return GestureDetector(
                                                    onTap: (){


                                                      if(map['alert'].toString().contains('trucker')  && map['alert_saw']== false){
                                                        FirestoreServices().updateAlertView(map['moveId']); //coloca como visto e remove o alerta
                                                      }

                                                      indexSelected = index;
                                                      homeModel.updateIndexPosition(index);
                                                      mapSelected = map;
                                                      calculateDistance(homeModel);



                                                      /*
                                            if(map['situacao'].toString()=='trucker_finished'){

                                            } else {

                                            }
                                             */

                                                      homeModel.setIsLoading(false);

                                                      //ATENÇÃO
                                                      // sitTruckerQuitAfterPayment = 'trucker_quited_after_payment';  //<<desabilitar os controles e exibir mensagem mas permitir trocar motorista
                                                      //   static String sitUserInformTruckerDidntMakeMove = 'user_informs_trucker_didnt_make_move';  //<<desabilitar os controles e exibir a mensagem
                                                      //   static String sitUserInformTruckerDidntFinishedMove =
                                                      //ESTAS TRES POSSIBILIDADES ACIMA NAO ESTÃO CONTEMPLADAS AQUI POIS ESTOU IMAGINANDO QUE NÃO TEM COMO CHEGAR AQUI DISPONIVEL. ESSAS SAO EXIBIDAS ASSIM QUE A SITUACAO É IDENTIFICADA EXIBE UMA POPUP E APAGA
                                                      if(map['situacao'].toString()== GlobalsConstants.sitAguardando){

                                                        homeModel.updateshowJobPopUp(true);

                                                      } else if (map['situacao'].toString()== GlobalsConstants.sitTruckerFinished){

                                                        homeModel.updatepopUpsCode(GlobalsConstants.sitTruckerFinished);

                                                      } else if (map['situacao'].toString()== GlobalsConstants.sitAccepted){

                                                        homeModel.updateshowJobPopUp(true);

                                                      } else if (map['situacao'].toString()== GlobalsConstants.sitAccepted){

                                                      }




                                                    },
                                                    //child: Text(map['name']),
                                                    child: ListLine(map, userModel, homeModel),

                                                  );



                                                }
                                            ),
                                          );
                                        }


                                      },
                                    ),

                                    homeModel.showCalendar==true ? SingleChildScrollView(
                                      child:Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              CloseButton(onPressed: (){
                                                homeModel.updateShowCalendar(false);
                                              },)
                                            ],
                                          ),
                                          _buildCalendar(),

                                        ],
                                      ) ,
                                    ) : Container(),

                                  ],
                                ),
                              ),
                            ),
                          ) : Container(),

                          //appbar
                          Positioned(
                            top: 0.0,
                            child: Container(
                                height: heightPercent*0.12,
                                width: widthPercent,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    SizedBox(height: 30.0,),
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.menu, color: CustomColors.blue, size: 35.0,), onPressed: (){
                                          homeModel.updateShowDrawer();
                                        }),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                          ),

                          //notificatiosn page
                          showNotificationsScreen==true ? notificationsScreen(homeModel) : Container(),

                          //menu
                          homeModel.showDrawer==true ? Positioned(
                            top: 0.0,
                            bottom: 0.0,
                            left: 0.0,
                            right: widthPercent*0.2,
                            child: MenuDrawer(),
                          ) : Container(),
                          //barra branca que fecha o menu
                          homeModel.showDrawer==true ? Positioned(
                            top: 50.0,
                            bottom: 0.0,
                            right: 0.0,
                            left: widthPercent*0.8,
                            child: GestureDetector(
                              onTap: (){
                                homeModel.updateShowDrawer();
                              },
                              child: Container(
                                alignment: Alignment.topCenter,
                                color: Colors.white.withOpacity(0.5),
                                child: Icon(Icons.arrow_back, color: CustomColors.blue, size: 50.0,),
                                //n precisa mostrar nada
                              ),
                            ),
                          ) : Container(),

                          //showJobPopUp==true ? Container(decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0), child: JobPopUp(),) : Container(),

                          homeModel.showJobPopUp==true ? popUpWithResumeOfTheJob(homeModel) : Container(),

                          homeModel.showJobConfirmationPopup==true
                              ? popUpConfirmJob(homeModel)
                              : Container(),

                          homeModel.showJobDeclinationPopup==true
                              ? popUpDeclinationJob(homeModel)
                              : Container(),

                          homeModel.showJobCancelmentByUser==true
                              ? popupShowUserHasCancelledJob(userModel, homeModel)
                              : Container(),

                          //reconstruindo os popups
                          homeModel.popUpsCode=='no'
                              ? Container()
                              : homeModel.popUpsCode=='pago_little_negative'  && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', () {_pago_passou_mudancaNocorreu(homeModel); }, 'Ir para mudança', () { _pago_passou_abrirMove(_querySnapshot, homeModel);})
                          //? WidgetsConstructor().customPopUp('Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Ir para mudança', 'Mudança não ocorreu', widthPercent, heightPercent, () {_pago_passou_abrirMove(_querySnapshot);}, () {_pago_passou_mudancaNocorreu();})
                              : homeModel.popUpsCode=='pago_much_negative'  && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', () {_pago_passouMuito_mudancaNaoOcorreu(homeModel, _querySnapshot); }, 'Finalizar\ne avaliar', () {_pago_passouMuito_finalizar(homeModel); })
                          //? WidgetsConstructor().customPopUp('Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', 'Finalizar mudança', widthPercent, heightPercent, () {_pago_passouMuito_mudancaNaoOcorreu();}, () {_pago_passouMuito_finalizar();})
                              : homeModel.popUpsCode=='pago_reminder'  && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+'.', 'Depois', () {_pago_reminder_depois(homeModel); }, 'Ir para mudança', () { _pago_reminder_irParaMove(_querySnapshot, homeModel);})
                          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
                          //  () {_pago_reminder_irParaMove(_querySnapshot);}, () {_pago_reminder_depois();})
                              : homeModel.popUpsCode=='pago_moveTime'
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Hora de mudança', 'Você tem uma mudança agora.',
                              'Depois', () { _pago_moveTime_depois(homeModel);}, 'Ir para mudança', () {_pago_moveTime_irParaMove(_querySnapshot, homeModel); })
                          //? WidgetsConstructor().customPopUp('Hora de mudança', 'Você tem uma mudança agora.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
                          //  () {_pago_moveTime_irParaMove(_querySnapshot);}, () {_pago_moveTime_depois();})
                              : homeModel.popUpsCode=='accepted_little_negative' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança que iniciou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
                              'Cancelar mudança', () {_accepted_passou_cancelarMove(homeModel); }, 'Aguardar', () {_accepted_passou_aguardar(homeModel); })
                          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança que iniciou às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
                          // 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
                          //  () {_accepted_passou_aguardar();}, () {_accepted_passou_cancelarMove();})
                              : homeModel.popUpsCode == 'accepted_much_negative'  && homeModel.indexPosition != null
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.',
                              'Ok', () { _accepted_passouMuito_cancelar(homeModel);})
                          //? WidgetsConstructor().customPopUp1Btn('Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.'
                          // , Colors.blue, widthPercent, heightPercent,
                          //  () {_accepted_passouMuito_cancelar();})
                              : homeModel.popUpsCode=='accepted_reminder' && homeModel.indexPosition != null
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime'] +'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.',
                              'Ok', () { _accepted_reminder(homeModel);})
                          //? WidgetsConstructor().customPopUp1Btn('Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.'
                          // , Colors.blue, widthPercent, heightPercent,
                          //  () {_accepted_reminder();})
                              : homeModel.popUpsCode=='accepted_moveTime' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança.'
                              , 'Cancelar mudança', () { _accepted_moveTime_cancelarMove(homeModel);}, 'Aguardar', () {_accepted_moveTime_aguardar(homeModel); })
                          //? WidgetsConstructor().customPopUp('Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança..'
                          // , 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
                          //  () {_accepted_moveTime_aguardar();}, () {_accepted_moveTime_cancelarMove();})
                              : homeModel.popUpsCode=='_pago_passouMuito_mudancaNaoOcorreu_alert' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você está informando que não realizou a mudança.',
                              'Não prestei o serviço', () { _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel.Uid, homeModel);}, 'Eu prestei este serviço', () { _pago_passouMuito_mudancaNaoOcorreuCancelCallback(homeModel);})
                          //? WidgetsConstructor().customPopUp('Atenção', 'Você está informando que não realizou a mudança.',
                          // 'Não prestei o serviço', 'Eu prestei este serviço', widthPercent, heightPercent, ()
                          // {_pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[indexPosition]['moveId'], userModel.Uid);},
                          // () {_pago_passouMuito_mudancaNaoOcorreuCancelCallback();})
                              : homeModel.popUpsCode=='user_informs_trucker_didnt_finished_move' && homeModel.indexPosition != null
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
                              'Vou voltar para terminar', () { _user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel);},
                              'Não vou voltar e concordo não receberei pelo serviço', () { _user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel);})
                          //? WidgetsConstructor().customPopUp('Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
                          // 'Vou voltar para terminar', 'Não vou voltar e concordo não receberei pelo serviço', widthPercent, heightPercent,
                          // () {_user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[indexPosition]['moveId'], userModel);},
                          // () {_user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
                              : homeModel.popUpsCode=='user_informs_trucker_didnt_make_move' && homeModel.indexPosition != null
                          //? WidgetsConstructor().customPopUp1Btn('Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.", Colors.red, widthPercent, heightPercent, () { _user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.",'Ok', () {_user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel); })
                              : homeModel.popUpsCode=='user_finished'
                              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
                              'Cancelar', () { _accepted_reminder(homeModel);}, 'Finalizar', () { _userFinishedAndAvaliatedMove(_querySnapshot, homeModel); }):
                          //? WidgetsConstructor().customPopUp('Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
                          // 'Finalizar', 'Cancelar', widthPercent, heightPercent, () { _userFinishedAndAvaliatedMove(_querySnapshot);} , () {_accepted_reminder();} )
                          homeModel.popUpsCode == GlobalsConstants.sitTruckerFinished
                              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Esperando o cliente', 'Aguardando o cliente finalizar para encerrar.', 'Ok', () { _accepted_reminder(homeModel);})
                              : Container(),


                          homeModel.isLoading==true
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
                      ),


                       */

                    )
                );

              },
            );
          },
        );
      },
    );

  }


  Widget simpleTextOfFeedback(){

    _listPopups.clear();
    return Text("Sem serviços para você por enquanto");
  }

  Widget customNotifyIcon(){

    return GestureDetector(

      onTap: (){
        if(_listPopups.length != 0){
          setState(() {
            showNotificationsScreen=true;
          });
        } else {
          _displaySnackBar(context, 'Você não possui notificações');
        }
      },
      child: Container(
        height: heightPercent*0.05,
        width: widthPercent*0.10,
        child: Stack(
          children: [
            Positioned(
                top: 8.0,
                left: 0.0,
                right: 0.0,
                child: Icon(Icons.add_alert, color: Colors.redAccent,)
            ),
            Positioned(
              top: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent
                ),
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Text(_listPopups.length.toString(), style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.5)),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(){


    return TableCalendar(
      //locale: 'pt_BR',
      locale: 'pt_Br',
      events: _listEvents,
      calendarController: _calendarController,
      calendarStyle: CalendarStyle(
        canEventMarkersOverflow: true,
        selectedColor: CustomColors.brown,
        todayColor: CustomColors.yellow,
        markersColor: CustomColors.blue,
        outsideDaysVisible: false,

      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,

      ),


      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, events) {
          //_selectedEvents = events;
          //_selectedDate = DateUtils().convertStringFromDate(date);

          return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                date.day.toString(),
                style: TextStyle(color: Colors.white),
              ));
        },
        todayDayBuilder: (context, date, events) => Container(
            margin: const EdgeInsets.all(4.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              date.day.toString(),
              style: TextStyle(color: Colors.white),
            )),

      ),


    );


  }

  Widget notificationsScreen(HomeModel homeModel){

    return Container(
        height: heightPercent,
        width: widthPercent,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 40.0),
          child: ListView(
            children: [

              SizedBox(height: 15.0,),
              //close btn
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CloseButton(
                    onPressed: (){
                      setState(() {
                        showNotificationsScreen=false;
                      });
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Suas notificações', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                ],
              ),

              SizedBox(height: heightPercent*0.05,),
              Divider(),

              //lista das notificações
              Container(
                height: heightPercent*0.85,
                child: ListView.builder(
                    itemCount: _listPopups.length,
                    itemBuilder: (BuildContext context, int index){

                      //int key = _listPopups.keys.elementAt(index);
                      //String value = _listPopups.values.elementAt(index);
                      return _exibeListLine(_listPopups.keys.elementAt(index), _listPopups.values.elementAt(index), homeModel);

                    }
                ),
              )
              ,

            ],
          ),
        )
    );

  }

  Widget _exibeListLine(int index, String code, HomeModel homeModel){

    return GestureDetector(
      onTap: (){

        homeModel.updatepopUpsCode(code); //atualiza para exibir a popup
      },
      child: Container(
        height: heightPercent*0.15,
        width: widthPercent*0.90,
        color: Colors.white,
        child: ListView(
          children: [
            Text(returnMessageToUser(code, index)),
            Divider(color: CustomColors.blue,),
          ],
        ),
      ),
    );

  }

  String returnMessageToUser(String code, int indexPosition){

    if(code == 'pago_little_negative'){
      return 'Mudança acontecendo agora \n\nVocê têm uma mudança que começou às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.';
    } else if(code == 'pago_much_negative'){
      return 'Atenção \n\n Havia uma mudança agendada para às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.';
    } else if(code == 'pago_reminder'){
      return 'Atenção \n\n Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'.';
    } else if(code == 'pago_moveTime'){
      return 'Hora de mudança \n\nVocê tem uma mudança agora.';
    } else if(code == 'accepted_little_negative'){
      return 'Atenção \n\n Você tem uma mudança que iniciou às '+_querySnapshot.docs[indexPosition]['selectedTime'] + '. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.';
    } else if(code == 'accepted_much_negative') {
      return 'Atenção \n\n Você tinha uma mudança às'+_querySnapshot.docs[indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.';
    } else if(code == 'accepted_reminder'){
      return 'Lembrete \n\n Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime'] +'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.';
    } else if(code == 'accepted_moveTime'){
      return 'Atenção \n\n Existe uma mudança que inicia às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança.';
    } else if(code == '_pago_passouMuito_mudancaNaoOcorreu_alert'){
      return 'Atenção \n\n Você informou que não prestou o serviço.';
    } else if(code =='user_informs_trucker_didnt_finished_move'){
      return 'Atenção \n\n O cliente informou que você ainda não finalizou o serviço.';
    } else if(code == 'user_informs_trucker_didnt_make_move'){
      return 'Atenção \n\n O cliente informou que o serviço não foi prestado por você. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por ${(GlobalsConstants.banishementTime2*7).toString()} dias.';
    } else if(code == 'user_finished'){
      return 'Mudança finalizada \n\n O cliente confirmou que a mudança terminou. Caso você confirme que tenha terminado sua parte, finalize também para avaliar, encerrar o serviço e estar apto a receber por ele.';
    } else if( code == GlobalsConstants.sitTruckerFinished){
      return 'Esperando cliente \n\n Aguardando o cliente finalizar para encerrar.';
    } else {
      return 'Erro';
    }

  }

  void _populateCalendarList(QuerySnapshot querySnapshot){

    _listEvents = {};
    /*
    _listEvents = {
      DateTime.now() : ['Agora'],
    };

     */

    int cont=0;
    while(cont<querySnapshot.size){

      DateTime _date = DateUtils().convertDateAndTimeFromString(querySnapshot.docs[cont]['selectedDate'], querySnapshot.docs[cont]['selectedTime']);
      _listEvents[_date] = [querySnapshot.docs[cont]['endereco_origem']];
      //_listEvents[DateTime.now()] = ['Teste1'];
      cont++;
    }

    setState(() {
      _listEvents = _listEvents;
    });
    //_listEvents[DateTime.now().add(Duration(days: 1))] = ['Teste'];



  }

  Future<void> checkIfExistMovegoingNow(QuerySnapshot querySnapshot, UserModel userModel, HomeModel homeModel) async {

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


    if(homeModel.msgCanBeShown==false){
      homeModel.updateMsgCanBeShown(true);
      _querySnapshot = querySnapshot;

      _populateCalendarList(querySnapshot);

      int i = 0;
      while(i<querySnapshot.size){

        homeModel.updateIndexPosition(i);

        _handleSituation(querySnapshot.docs[i]['situacao'], userModel, querySnapshot.docs[i]['selectedDate'], querySnapshot.docs[i]['selectedTime'], homeModel);
        /*
        //caso o user tenha relatado problemas
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserInformTruckerDidntMakeMove){
          homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);
        }

        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
          homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);
        }

        //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){
          _displaySnackBar(context, 'Você está voltando para concluir a mudança. Abrindo a mudança');

          MoveClass moveClass = MoveClass();

          void _onSucess(){
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveDayPage(moveClass)));
          }


          FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});

        }

        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitUserFinished){
          homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);
        }

        //caso esteja pago, procedimenros abaixo
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitPago){


          DateTime scheduledDate = DateUtils().convertDateFromString(querySnapshot.docs[i]['selectedDate']);
          DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, querySnapshot.docs[i]['selectedTime']);
          final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

          if(dif.isNegative) {
            //a data já expirou

            if(dif>-240){

              homeModel.updatepopUpsCode('pago_little_negative');

              //neste caso o user fechou o app e abriu novamente

            } else {

              //a mudança já se encerrou há tempos
              homeModel.updatepopUpsCode('pago_much_negative');

            }


          } else if(dif<=120 && dif>15){

            homeModel.updatepopUpsCode('pago_reminder');
            //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

          } else if(dif<=15){

            homeModel.updatepopUpsCode('pago_moveTime');

          } else {

            //do nothing, falta mt ainda

          }



        }

        //caso esteja aceito mas o user ainda não pagou
        if(querySnapshot.docs[i]['situacao'] == GlobalsConstants.sitAccepted){

          DateTime scheduledDate = DateUtils().convertDateFromString(querySnapshot.docs[i]['selectedDate']);
          DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, querySnapshot.docs[i]['selectedTime']);
          final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

          if(dif.isNegative) {


            //a data já expirou

            if (dif > -240) {
              homeModel.updatepopUpsCode('accepted_little_negative');

              //neste caso o user fechou o app e abriu novamente

            } else {
              //a mudança já se encerrou há tempos
              homeModel.updatepopUpsCode('accepted_much_negative');
            }





          } else if(dif<=120 && dif>15){

            homeModel.updatepopUpsCode('accepted_reminder');
            //exibe a popup informando que está na hora mas o user ainda n pagou


          } else if(dif<=15){

            homeModel.updatepopUpsCode('accepted_moveTime');


          } else {

            //do nothing, falta mt ainda

          }


        }

         */

        i++;
      }

      _firstPass=false;
    }


  }

  void _handleSituation(String sit, UserModel userModel, String date, String time, HomeModel homeModel){


    if(homeModel.userGotMsg==false){ //se for true o usuer já viu uma mensagem

      if(sit == GlobalsConstants.sitUserInformTruckerDidntMakeMove){

        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);
        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitUserInformTruckerDidntMakeMove;
        }

      }

      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);

        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitUserInformTruckerDidntFinishedMove;
        }
      }

      //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){
        _displaySnackBar(context, 'Você está voltando para concluir a mudança. Abrindo a mudança');

        MoveClass moveClass = MoveClass();

        void _onSucess(){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MoveDayPage(moveClass)));
        }


        FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});

      }

      if(sit == GlobalsConstants.sitUserFinished){

        homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);
        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitUserFinished;
        }

      }

      //caso esteja pago, procedimenros abaixo
      if(sit == GlobalsConstants.sitPago || sit == GlobalsConstants.sitTruckerIsGoingToMove){


        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {
          //a data já expirou

          if(dif>-240){
            homeModel.updatepopUpsCode('pago_little_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'pago_little_negative';
            }

            //neste caso o user fechou o app e abriu novamente

          } else {
            homeModel.updatepopUpsCode('pago_much_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'pago_much_negative';
            }
            //a mudança já se encerrou há tempos

          }


        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('pago_reminder');

          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'pago_reminder';
          }
          //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

        } else if(dif<=15){

          homeModel.updatepopUpsCode('pago_moveTime');

          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'pago_moveTime';
          }

        } else {

          //do nothing, falta mt ainda

        }



      }

      //caso esteja aceito mas o user ainda não pagou
      if(sit == GlobalsConstants.sitAccepted){

        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {


          //a data já expirou

          if (dif > -240) {
            homeModel.updatepopUpsCode('accepted_little_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'accepted_little_negative';
            }
            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            homeModel.updatepopUpsCode('accepted_much_negative');

            if(homeModel.indexPosition!=null){
              popsShownInt = homeModel.indexPosition;
              popsShownStr = 'accepted_much_negative';
            }

          }





        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('accepted_reminder');
          //exibe a popup informando que está na hora mas o user ainda n pagou
          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'accepted_reminder';
          }


        } else if(dif<=15){

          homeModel.updatepopUpsCode('accepted_moveTime');

          if(homeModel.indexPosition!=null){
            popsShownInt = homeModel.indexPosition;
            popsShownStr = 'accepted_moveTime';
          }

        } else {

          //do nothing, falta mt ainda

        }


      }

      if(sit == GlobalsConstants.sitReschedule){
        homeModel.updatepopUpsCode(GlobalsConstants.sitReschedule);
        if(homeModel.indexPosition!=null){
          popsShownInt = homeModel.indexPosition;
          popsShownStr = GlobalsConstants.sitReschedule;
        }
      }


    } else {
      //aqui significa que ja exibiu a primeira popup. Então agora vamos guardar as infos como notificações
      //e o user vai pdoer ver clicando num botão de exibir notificações]

      if(sit == GlobalsConstants.sitUserInformTruckerDidntMakeMove){

        //homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);
        if(homeModel.indexPosition != null){

          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            if(!_listPopups.containsKey(homeModel.indexPosition)){ //evita salvar repetido
              _listPopups[homeModel.indexPosition] = GlobalsConstants.sitUserInformTruckerDidntMakeMove;
            }
          }

        }


      }

      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
        //homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);
        if(homeModel.indexPosition != null){
          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            _listPopups[homeModel.indexPosition] = GlobalsConstants.sitUserInformTruckerDidntFinishedMove;
          }

        }

      }

      //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){


        //esta situação não se aplica aqui
        /*
        MoveClass moveClass = MoveClass();

        void _onSucess(){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MoveDayPage(moveClass)));
        }


        FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});
         */
      }

      if(sit == GlobalsConstants.sitUserFinished){
        //homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);
        if(homeModel.indexPosition != null){
          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            _listPopups[homeModel.indexPosition] = GlobalsConstants.sitUserFinished;
          }
        }

      }

      //caso esteja pago, procedimenros abaixo
      if(sit == GlobalsConstants.sitPago || sit == GlobalsConstants.sitTruckerIsGoingToMove){


        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {
          //a data já expirou

          if(dif>-240){
            //homeModel.updatepopUpsCode('pago_little_negative');

            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                _listPopups[homeModel.indexPosition] = 'pago_little_negative';
              }

            }

            //neste caso o user fechou o app e abriu novamente

          } else {
            //homeModel.updatepopUpsCode('pago_much_negative');
            //a mudança já se encerrou há tempos
            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                _listPopups[homeModel.indexPosition] = 'pago_much_negative';
              }

            }

          }


        } else if(dif<=120 && dif>15){

          //homeModel.updatepopUpsCode('pago_reminder');
          //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'pago_reminder';
            }
          }

        } else if(dif<=15){


          //homeModel.updatepopUpsCode('pago_moveTime');
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'pago_moveTime';
            }
          }

        } else {

          //do nothing, falta mt ainda

        }



      }

      //caso esteja aceito mas o user ainda não pagou
      if(sit == GlobalsConstants.sitAccepted){

        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {


          //a data já expirou

          if (dif > -240) {
            //homeModel.updatepopUpsCode('accepted_little_negative');
            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                if(!_listPopups.containsKey(homeModel.indexPosition)) { //evita salvar repetido
                  _listPopups[homeModel.indexPosition] = 'accepted_little_negative';
                }
              }

            }

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            //homeModel.updatepopUpsCode('accepted_much_negative');
            if(homeModel.indexPosition != null){
              if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
                _listPopups[homeModel.indexPosition] = 'accepted_much_negative';
              }
            }
          }





        } else if(dif<=120 && dif>15){

          //homeModel.updatepopUpsCode('accepted_reminder');
          //exibe a popup informando que está na hora mas o user ainda n pagou
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'accepted_reminder';
            }

          }


        } else if(dif<=15){

          //homeModel.updatepopUpsCode('accepted_moveTime');
          if(homeModel.indexPosition != null){
            if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
              _listPopups[homeModel.indexPosition] = 'accepted_moveTime';
            }

          }

        } else {

          //do nothing, falta mt ainda

        }


      }

      if(sit == GlobalsConstants.sitReschedule){

        if(homeModel.indexPosition != null){

          if(!_listPopups.containsKey(popsShownInt) && !_listPopups.containsValue(popsShownStr)){
            if(!_listPopups.containsKey(homeModel.indexPosition)){ //evita salvar repetido
              _listPopups[homeModel.indexPosition] = GlobalsConstants.sitReschedule;
            }
          }

        }

      }


    }

    print(_listPopups);

    /*
    if(homeModel.userGotMsg==false){ //se for true o usuer já viu uma mensagem

      if(sit == GlobalsConstants.sitUserInformTruckerDidntMakeMove){

        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntMakeMove);

      }

      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedMove){
        homeModel.updatepopUpsCode(GlobalsConstants.sitUserInformTruckerDidntFinishedMove);
      }

      //user_informs_trucker_didnt_finished_move_goingback - força a abrir o mapa
      if(sit == GlobalsConstants.sitUserInformTruckerDidntFinishedButItsGoingBack){
        _displaySnackBar(context, 'Você está voltando para concluir a mudança. Abrindo a mudança');

        MoveClass moveClass = MoveClass();

        void _onSucess(){
          Navigator.of(context).pop();
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => MoveDayPage(moveClass)));
        }


        FirestoreServices().loadMoveClass(userModel, moveClass, () { _onSucess();});

      }

      if(sit == GlobalsConstants.sitUserFinished){
        homeModel.updatepopUpsCode(GlobalsConstants.sitUserFinished);

      }

      //caso esteja pago, procedimenros abaixo
      if(sit == GlobalsConstants.sitPago || sit == GlobalsConstants.sitTruckerIsGoingToMove){


        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {
          //a data já expirou

          if(dif>-240){
            homeModel.updatepopUpsCode('pago_little_negative');


            //neste caso o user fechou o app e abriu novamente

          } else {
            homeModel.updatepopUpsCode('pago_much_negative');
            //a mudança já se encerrou há tempos

          }


        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('pago_reminder');
          //_displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

        } else if(dif<=15){


          homeModel.updatepopUpsCode('pago_moveTime');

        } else {

          //do nothing, falta mt ainda

        }



      }

      //caso esteja aceito mas o user ainda não pagou
      if(sit == GlobalsConstants.sitAccepted){

        DateTime scheduledDate = DateUtils().convertDateFromString(date);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, time);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {


          //a data já expirou

          if (dif > -240) {
            homeModel.updatepopUpsCode('accepted_little_negative');

            //neste caso o user fechou o app e abriu novamente

          } else {
            //a mudança já se encerrou há tempos
            homeModel.updatepopUpsCode('accepted_much_negative');
          }





        } else if(dif<=120 && dif>15){

          homeModel.updatepopUpsCode('accepted_reminder');
          //exibe a popup informando que está na hora mas o user ainda n pagou


        } else if(dif<=15){

          homeModel.updatepopUpsCode('accepted_moveTime');

        } else {

          //do nothing, falta mt ainda

        }


      }


    }



     */

  }























  //FUNCOES DE CALLBACK PARA CADA SITUAÇÃO QUE EXIBE POPUP


  //opção 1 - mudança tá paga, mas já passou. Exibe opções abaixo
  //popUpsCode=='pago_little_negative'
  void _pago_passou_finalizar(){
    //finalizar uma mudança
    print('finalizar mudança');
  }

  Future<void> _pago_passou_abrirMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_passou_mudancaNocorreu(HomeModel homeModel){
    print('mudança nunca ocorreu');
    //lidar com isso no bd. pegar os motivos e provavelmente punir o freteiro
    homeModel.updatepopUpsCode('_pago_passouMuito_mudancaNaoOcorreu_alert');

  }

  //opção 2 - mudança tá paga, mas já passou há mt tempo. Exibe opções
  //popUpsCode=='pago_much_negative'
  void _pago_passouMuito_finalizar(HomeModel homeModel){
    //aqui signfica que a mudança ocorreu bem para o motorista e ele vai finalizar. Vai ficar faltando o user pra fechar o ticket
    FirestoreServices().updateMoveSituation(GlobalsConstants.sitTruckerFinished, _querySnapshot.docs[homeModel.indexPosition]['moveId']);
    homeModel.updatepopUpsCode('no');

  }

  void _pago_passouMuito_mudancaNaoOcorreu(HomeModel homeModel, QuerySnapshot querySnapshot){

    homeModel.updatepopUpsCode('_pago_passouMuito_mudancaNaoOcorreu_alert');
  }

  void _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(String moveId, String truckerId, HomeModel homeModel){

    homeModel.setIsLoading(true);

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, 'trucker desistiu após pagamento do user');
      homeModel.setIsLoading(false);
      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){
      isLoading=false;
      _displaySnackBar(context, "Ocorreu um erro. Tente nvoamente");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});
  }

  void _pago_passouMuito_mudancaNaoOcorreuCancelCallback(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  //opção 3 - mudança tá paga e começa logo.
  //popUpsCode=='pago_reminder'
  Future<void> _pago_reminder_irParaMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);


    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_reminder_depois(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  //opção 4 - mudança tá paga e tá na hora de fazer
  //opUpsCode=='pago_moveTime'
  Future<void> _pago_moveTime_irParaMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    FirestoreServices().updateMoveSituation(GlobalsConstants.sitTruckerIsGoingToMove, _moveClass.idPedido);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => MoveDayPage(_moveClass)));

    });

  }

  void _pago_moveTime_depois(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }


  //agora opções quando o user ainda não pagou
  //já deu a hora mas passou pouco, o user ainda nao pagou.
  //popUpsCode=='accepted_little_negative'
  void _accepted_passou_aguardar(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  void _accepted_passou_cancelarMove(HomeModel homeModel){

    void _onCancelSucess(){
      queryWasLoaded=false;
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Você cancelou a mudança.');
    }

    void _onCancelFailure(){
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }

    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});
  }


  //usuario nao pagou e já passou muito do tempo
  //popUpsCode == 'accepted_much_negative'
  void _accepted_passouMuito_cancelar(HomeModel homeModel){

    //precisa avaliar mal o user
    void _onCancelSucess(){
      _displaySnackBar(context, 'Você cancelou a mudança.');
      homeModel.updatepopUpsCode('no');
    }

    void _onCancelFailure(){
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
      homeModel.updatepopUpsCode('no');
    }

    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});

  }

  //reminder - o user ainda nao pagou mas a mudança começaria em breve
  //popUpsCode=='accepted_reminder'
  void _accepted_reminder(HomeModel homeModel) {
    homeModel.updatepopUpsCode('no');
  }

  //deu a hora mas o user nao pagou. DEixar o motorista escolher
  //popUpsCode=='accepted_moveTime'
  void _accepted_moveTime_aguardar(HomeModel homeModel){
    homeModel.updatepopUpsCode('no');
  }

  void _accepted_moveTime_cancelarMove(HomeModel homeModel){

    //avaliar mal o user
    void _onCancelSucess(){
      _displaySnackBar(context, 'Você cancelou a mudança.');
    }

    void _onCancelFailure(){
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }


    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});
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

  void _user_informed_truckerDidntFinishedMoveCancel(String truckerId, String moveId, HomeModel homeModel){

    homeModel.setIsLoading(true);

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, GlobalsConstants.punishmentEntry2);
      FirestoreServices().createBanishmentEntry(truckerId, GlobalsConstants.banishmentInform1, GlobalsConstants.banishementTime1);
      _displaySnackBar(context, "Você está punido com o banimento da plataforma por uma semana. Nesta semana você pode concluir as mudanças que estão agendadas mas não aparecerá para novos clientes até encerrar o prazo.");

      homeModel.setIsLoading(false);
      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Ocorreu um erro. Tente nvoamente");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});

  }

  void _user_informed_truckerDidndShowUp(String truckerId, String moveId, HomeModel homeModel){

    homeModel.setIsLoading(true);

    void _onSucess(){
      FirestoreServices().createPunishmentEntry(truckerId, GlobalsConstants.punishmentEntry3);
      FirestoreServices().createBanishmentEntry(truckerId, GlobalsConstants.banishmentInform2, GlobalsConstants.banishementTime2);
      _displaySnackBar(context, "Você está punido com o banimento da plataforma por ${GlobalsConstants.banishementTime2.toString()} semanas. Neste tempo você pode concluir as mudanças que estão agendadas mas não aparecerá para novos clientes até encerrar o prazo.");

      homeModel.setIsLoading(false);
      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Ocorreu um erro");
    }

    FirestoreServices().quitJobAfterPayment(moveId, () {_onSucess();} , () {_onFail();});

  }

  Future<void> _userFinishedAndAvaliatedMove(QuerySnapshot querySnapshot, HomeModel homeModel) async {

    homeModel.setIsLoading(true);

    _displaySnackBar(context, 'Encerrando mudança e carregando sistema de avaliação');

    MoveClass _moveClass = MoveClass();
    Map<String, dynamic> map = querySnapshot.docs[homeModel.indexPosition].data();
    _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

    _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

      homeModel.setIsLoading(false);

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AvaliationPage(_moveClass)));

    });

  }

  Future<void> _situation_Rescheduled(String moveId, HomeModel homeModel) async {

    void _onfinish(){

      homeModel.updatepopUpsCode('no');
    }

    void _onFail(){

    }

    FirestoreServices().loadMoveSituationBackup(moveId, () {_onfinish();}, () {_onFail();});


  }

  void _situation_Rescheduled_truckerQuit(HomeModel homeModel){

    void _onCancelSucess(){
      queryWasLoaded=false;
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Você desistiu da mudança.');
    }

    void _onCancelFailure(){
      homeModel.updatepopUpsCode('no');
      _displaySnackBar(context, 'Ops, ocorreu um erro.');
    }

    FirestoreServices().truckerQuitWithoutPunishiment_userFault(_querySnapshot.docs[homeModel.indexPosition]['moveId'], () {_onCancelSucess();}, () {_onCancelFailure();});

  }



  //FIM DAS FUNÇÕES DE CALLBACK DOS POPUPS


  Widget ListLine(Map map, UserModel userModel, HomeModel homeModel){

    _handleSituation(map["situacao"], userModel, map['selectedDate'], map['selectedTime'], homeModel);

    return //content
      Padding(
        padding:EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        child: Container(

            decoration: BoxDecoration(
              color: CustomColors.yellowPostIt,
              border: Border.all(
                color: map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt,
                width: 4.0, //                   <--- border width here
              ),

              borderRadius: BorderRadius.all(Radius.circular(4.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],


            ),

            //height: heightPercent*0.30,
            width: widthPercent*0.31, //se mudar tem que mudar o tamanho do container com texto abaixo
            //color: map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt,
            child: ListView(
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

                /*
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


               */
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20, color: Colors.white,),
                    Text(map['selectedDate'], style: TextStyle(color: Colors.white,fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 20,color: Colors.white),
                    Text(map['selectedTime'], style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                  ],
                ),
                SizedBox(height: heightPercent*0.015,),
                Container(
                  alignment: Alignment.center,
                  width: widthPercent*0.31,
                  child: Text(MoveClass().formatSituationToHuman(map['situacao']), style: TextStyle(color: map['situacao']=='aguardando' ? Colors.red : Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                )



                /*
              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

               */
                /*
              map['situacao']=='accepted'
                  ? WidgetsConstructor().makeText("Você aceitou este serviço", Colors.blue, 15.0, 10.0, 5.0, null)
                  : Container(),


               */
              ],
            )
        ),
      );

  }


  /*
  Widget ListLine(Map map, UserModel userModel, HomeModel homeModel){

    _handleSituation(map["situacao"], userModel, map['selectedDate'], map['selectedTime'], homeModel);

    return Padding(padding: EdgeInsets.all(5.0),
      child: Container(
          decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellowPostIt, map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt, 4.0, 4.0),
          width: widthPercent*0.31, //se mudar tem que mudar o tamanho do container com texto abaixo
          //color: map['situacao']=='aguardando' ? Colors.redAccent : CustomColors.yellowPostIt,
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

              /*
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


               */
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 20, color: Colors.white,),
                  Text(map['selectedDate'], style: TextStyle(color: Colors.white,fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.schedule, size: 20,color: Colors.white),
                  Text(map['selectedTime'], style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                ],
              ),
              SizedBox(height: heightPercent*0.015,),
              Container(
                alignment: Alignment.center,
                width: widthPercent*0.31,
                child: Text(MoveClass().formatSituationToHuman(map['situacao']), style: TextStyle(color: map['situacao']=='aguardando' ? Colors.red : Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
              )



              /*
              Row(
                children: [
                  WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
                  WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
                ],
              ),

               */
              /*
              map['situacao']=='accepted'
                  ? WidgetsConstructor().makeText("Você aceitou este serviço", Colors.blue, 15.0, 10.0, 5.0, null)
                  : Container(),


               */
            ],
          )
      ),
    );

  }
   */

  Widget JobPopUp(HomeModel homeModel) {

    String lances = mapSelected['lances_escada'].toString();
    if(lances == 'null'){
      lances = 'não';
    }

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CloseButton(
                onPressed: (){
                  homeModel.updateshowJobPopUp(false);
                  homeModel.updateshowJobConfirmationPopup(false);
                  homeModel.updateshowJobConfirmationPopup(false);

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
          homeModel.distance != null
              ?Text('Distancia: '+homeModel.distance.toStringAsFixed(2)+"km")
              :Text('Calculando'),
          SizedBox(height: 20.0,),
          Text('Ajudantes requisitados: '+mapSelected['ajudantes'].toString()),
          Text('Data: '+mapSelected['selectedDate'].toString()),
          Text('Horário: '+mapSelected['selectedTime'].toString()),
          Text('Observações : '+mapSelected['ps']),
          mapSelected['escada'] == true
              ? Text('Lances de escada: '+lances)
              : Container(),
          Text('Valor: R\$'+mapSelected['valor'].toStringAsFixed(2)),
          SizedBox(height: 20.0,),
          //botoes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  homeModel.updateshowJobDeclinationPopup(true);
                },
                child: WidgetsConstructor().makeButton(Colors.redAccent, Colors.white, mapSelected['situacao'] == 'accepted' ? widthPercent*0.8 : widthPercent*0.4, 60.0, 2.0, 5.0, mapSelected['situacao'] == 'accepted' ? "Desistir" : "Negar", Colors.white, 17.0),
              ),

              GestureDetector(
                onTap: (){
                  homeModel.updateshowJobConfirmationPopup(true);
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

  Widget popUpConfirmJob(HomeModel homeModel){

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
                        homeModel.updateshowJobConfirmationPopup(true);
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
                        homeModel.setIsLoading(true);

                        ConfirmJob(homeModel);

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

  Widget popUpWithResumeOfTheJob(HomeModel homeModel){

    String _lances = mapSelected['lances_escada'].toString();
    if(_lances == 'null'){
      _lances = 'não';
    }
    String _ps = mapSelected['ps'].toString();
    if(_ps == 'null'){
      _ps = 'não';
    }

    return Container(
        color: Colors.white,
        width: widthPercent,
        height: heightPercent,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: heightPercent*0.06),
              //botão de fechar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CloseButton(
                    onPressed: (){
                      homeModel.updateshowJobPopUp(false);
                      homeModel.updateshowJobConfirmationPopup(false);
                      homeModel.updateshowJobDeclinationPopup(false);
                    },
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.02,),
              //simbolo com interregoração
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: widthPercent*0.35,
                    height: heightPercent*0.10,
                    child: Text('?', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(8))),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.blue,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],

                    ),
                  )
                ],
              ),
              SizedBox(height: heightPercent*0.03,),
              Text('Endereços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              Text('Origem: ${mapSelected['endereco_origem']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.01,),
              Text('Destino: ${mapSelected['endereco_destino']}', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              SizedBox(height: heightPercent*0.03,),
              Text('Detalhes', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              homeModel.distance != null
                  ?Text('Distancia: '+homeModel.distance.toStringAsFixed(2)+"km", style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)))
                  :Text('Calculando distância', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Ajudantes requisitados: '+mapSelected['ajudantes'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Data: '+mapSelected['selectedDate'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Horário: '+mapSelected['selectedTime'].toString(), style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              Text('Observações : '+_ps, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              mapSelected['escada'] == true
                  ? Text('Lances de escada: '+_lances, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)))
                  : Container(),
              Text('Valor: R\$'+mapSelected['valor'].toStringAsFixed(2).toString().replaceAll('.', ','), style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
              SizedBox(height: heightPercent*0.04),

              //botão de aceitar
              mapSelected['situacao'] == GlobalsConstants.sitAguardando
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: widthPercent*0.6, height: heightPercent*0.08,
                    child: RaisedButton(color: CustomColors.yellow ,onPressed: (){
                      homeModel.updateshowJobConfirmationPopup(true);
                    },
                      child: Text('Aceitar serviço', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                    ),
                  )
                ],
              )
                  : Container(),

              //espaço
              SizedBox(height: 15.0,),

              //botão de negar
              mapSelected['situacao'] == GlobalsConstants.sitAguardando
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: widthPercent*0.6, height: heightPercent*0.08,
                    child: RaisedButton(color: Colors.redAccent ,onPressed: (){
                      homeModel.updateshowJobDeclinationPopup(true);
                    },
                      child: Text('Rejeitar', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                    ),
                  )
                ],
              )
                  : Container(),

              SizedBox(height: 10.0,),

              mapSelected['situacao'] != GlobalsConstants.sitAguardando
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: widthPercent*0.6, height: heightPercent*0.08,
                    child: RaisedButton(color: Colors.red, splashColor: Colors.grey[300] ,onPressed: (){

                      if(mapSelected['situacao'] == GlobalsConstants.sitAccepted){
                        _accepted_passou_cancelarMove(homeModel);
                      } else if(mapSelected['situacao'] == GlobalsConstants.sitPago){
                        _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(mapSelected['moveId'], userModelGLobal.Uid, homeModel);
                      } else {
                        ///cancelamento sem punição. Se precisar de mais opções adicionar acima
                        _accepted_passou_cancelarMove(homeModel);
                      }


                    },
                      child: Text('Desistir do serviço', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
                    ),
                  )
                ],
              )
                  : Container(),




            ],
          ),
        )
    );
  }

  /*
  Widget popUpWithResumeOfTheJob(HomeModel homeModel){

    String _lances = mapSelected['lances_escada'].toString();
    if(_lances == 'null'){
      _lances = 'não';
    }
    String _ps = mapSelected['ps'].toString();
    if(_ps == 'null'){
      _ps = 'não';
    }

    return Container(
      color: Colors.black54.withOpacity(0.6),
      width: widthPercent,
      height: heightPercent,
      child: Container(
        color: Colors.white,
        width: widthPercent*0.9,
        height: heightPercent*0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: 15.0,),
              Stack(
                children: [
                  Container(
                    width: 200.0,
                    height: 300.0,
                    child: Image.asset('images/home/popupimg.jpg', fit: BoxFit.fill,),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CloseButton(
                        onPressed: (){
                          homeModel.updateshowJobPopUp(false);
                          homeModel.updateshowJobConfirmationPopup(false);
                          homeModel.updateshowJobDeclinationPopup(false);
                        },
                      )
                    ],
                  ),
                ],
              ),
              Text('Situação: '+mapSelected['situacao']),
              Text('Origem: '+mapSelected['endereco_origem']),
              Text('Destino: '+mapSelected['endereco_destino']),
              homeModel.distance != null
                  ?Text('Distancia: '+homeModel.distance.toStringAsFixed(2)+"km")
                  :Text('Calculando'),
              Text('Ajudantes requisitados: '+mapSelected['ajudantes'].toString()),
              Text('Data: '+mapSelected['selectedDate'].toString()),
              Text('Horário: '+mapSelected['selectedTime'].toString()),
              Text('Observações : '+_ps),
              mapSelected['escada'] == true
                  ? Text('Lances de escada: '+_lances)
                  : Container(),
              Text('Valor: R\$'+mapSelected['valor'].toStringAsFixed(2)),
              SizedBox(height: 20.0,),
              //botão de aceitar
              mapSelected['situacao'] == GlobalsConstants.sitAguardando
                  ? Container(width: widthPercent*0.9,height: 60.0,
                child: RaisedButton(color: Colors.blue, splashColor: Colors.grey[300] ,onPressed: (){
                  homeModel.updateshowJobConfirmationPopup(true);
                },
                  child: WidgetsConstructor().makeText('Aceitar serviço', Colors.white, 17.0, 0.0, 0.0, 'center'),
                ),
              ) : Container(),
              mapSelected['situacao'] != GlobalsConstants.sitAguardando
                  ? Container(width: widthPercent*0.9,height: 60.0,
                child: RaisedButton(color: Colors.red, splashColor: Colors.grey[300] ,onPressed: (){

                  if(mapSelected['situacao'] == GlobalsConstants.sitAccepted){
                    _accepted_passou_cancelarMove(homeModel);
                  } else if(mapSelected['situacao'] == GlobalsConstants.sitPago){
                    _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(mapSelected['moveId'], userModelGLobal.Uid, homeModel);
                  } else {
                    ///cancelamento sem punição. Se precisar de mais opções adicionar acima
                    _accepted_passou_cancelarMove(homeModel);
                  }


                },
                  child: WidgetsConstructor().makeText('Desistir do serviço', Colors.white, 17.0, 0.0, 0.0, 'center'),
                ),
              ) : Container(),




            ],
          ),
        ),
      ),
    );
  }
   */
  Widget popUpDeclinationJob(HomeModel homeModel){

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
                        homeModel.updateshowJobDeclinationPopup(false);
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

                        DenyJob(homeModel);

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

  Widget popupShowUserHasCancelledJob(UserModel userModel, HomeModel homeModel){

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

                        homeModel.updateshowJobCancelmentByUser(false);
                        FirestoreServices().deleteCancelmentsNotify(userModel.Uid);

                        //agora cancelar as notificacoes locais (lembretes)
                        //notificação de 24h de antecedencia
                        NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, userModel.MoveIdCancelment);
                        //notificação de 2h de antecedencia]
                        NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, userModel.MoveIdCancelment+'2');



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

  void ConfirmJob(HomeModel homeModel) async {

    await FirestoreServices().confirmJobAceptance(mapSelected['id_contratante'],() {_onSucessConfirmJob(homeModel);}, () {_onFailConfirmJob(homeModel);});
    mapSelected['situacao']='accepted';
  }

  void _onSucessConfirmJob(HomeModel homeModel){
    //coloca um alerta de novidade para o usuário
    FirestoreServices().alertSetUserAlert(mapSelected['moveId']);
    //cria uma notificação para o freteiro 24 horas antes
    DateTime moveDate = MoveClass().formatMyDateToNotify(mapSelected['selectedDate'], mapSelected['selectedTime']);
    DateTime notifyDateTime = DateUtils().subHoursFromDate(moveDate, 24); //ajusta 24 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, mapSelected['moveId'], "Lembrete: Mudança amanhã às "+mapSelected['selectedTime'], notifyDateTime);

    //notificação com 2 horas de antecedencia (obs: o id da notificação é moveID (id do cliente+2)
    notifyDateTime = DateUtils().subHoursFromDate(moveDate, 2); //ajusta 2 horas antes
    NotificationMeths().scheduleNotification(flutterLocalNotificationsPlugin, mapSelected['moveId']+'2', "Lembrete: Mudança em duas horas às "+mapSelected['selectedTime'] , notifyDateTime);

    homeModel.updateshowJobConfirmationPopup(false);
    homeModel.updateshowJobPopUp(false);
    homeModel.setIsLoading(false);

    _displaySnackBar(context, "Pronto. Esta mudança está agendada.");
  }

  void _onFailConfirmJob(HomeModel homeModel){
    homeModel.setIsLoading(false);
    _displaySnackBar(context, "Ocorreu um erro. Tente novamente");
  }

  void DenyJob(HomeModel homeModel) async {

    void _onSucessDenyJob(){

      FirestoreServices().alertSetUserAlert(mapSelected['moveId']);

      //cancelando as notificações
      NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, mapSelected['moveId']); //24h early
      NotificationMeths().turnOffNotificationById(flutterLocalNotificationsPlugin, mapSelected['moveId']+'2'); //2h early

      mapSelected['situacao']='deny';
      mapSelected['id_freteiro']=null;
      mapSelected['nome_freteiro']=null;

      homeModel.updateshowJobDeclinationPopup(false);
      homeModel.updateshowJobPopUp(false);
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Você rejeitou este serviço.");
    }

    void _onFailureDenyJob(){

      //do nothing (tava dando erro sempre)
      /*
      homeModel.setIsLoading(false);
      _displaySnackBar(context, "Ocorreu um erro. Tente novamente.");

       */
      homeModel.updateshowJobDeclinationPopup(false);
      homeModel.updateshowJobPopUp(false);
      homeModel.setIsLoading(false);
    }

    await FirestoreServices().confirmJobDeny(mapSelected['moveId'], () {_onSucessDenyJob();}, () {_onFailureDenyJob();});

  }

  Future<void> calculateDistance(HomeModel homeModel) async {

    double _distance = await MoveClass().getTheDistanceFromTwoAddress(mapSelected['endereco_origem'], mapSelected['endereco_destino']);
    homeModel.updateDistance(_distance);
  }

  void checkFBconnection() async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {

        setState(() {
          userIsLoggedIn=false;
        });


      } else {


        //setState(() { mudei aqui
        userIsLoggedIn=true;
        needCheck=true;
        //});

      }
    });
  }


  Future<void> checkEmailVerified(UserModel userModel, NewAuthService newAuthService, HomeModel homeModel) async {

    //load data in model
    await newAuthService.loadUser();

    //check if email is verified
    bool isUserEmailVerified = false;
    isUserEmailVerified = await newAuthService.isUserEmailVerified();
    if(isUserEmailVerified==true){

      _ifUserIsVerified(userModel, homeModel, newAuthService);

    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  Future<void> _ifUserIsVerified(UserModel userModel,HomeModel homeModel, NewAuthService newAuthService) async {

    await newAuthService.loadUser();
    //now check if there is basic data in sharedPrefs
    bool existsDataInSharedPrefs = await SharedPrefsUtils().thereIsBasicInfoSavedInShared();
    if(existsDataInSharedPrefs==true){
      //if there is data, load it
      await SharedPrefsUtils().loadBasicInfoFromSharedPrefs(userModel, );

    } else {
      //if there is not, load it from FB
      //await newAuthService.loadUserBasicDataInSharedPrefs(userModel);
      //the rest will be done on another metch to check what need to be done in case of more info required
      //await FirestoreServices().loadUserInfos(userModel, () {_onSucessLoadInfos(userModel);}, () {_onFailureLoadInfos(userModel);});

    }


    everyProcedureAfterUserInfoIsLoad(userModel, homeModel, newAuthService);
  }

  Future<void> everyProcedureAfterUserInfoIsLoad(UserModel userModel, HomeModel homeModel, NewAuthService newAuthService) async {

    checkIfNeedUserInfos(userModel, homeModel, newAuthService);  //completa as informações de cadastro do usuário

    checkIfUserBanishmentIsOver(userModel);

    loadApelido(userModel);


    /*
    if(homeModel.query==null){ //atualiza a query apenas se for a primeira vez (null)
      updateQuery(userModel.Uid, homeModel);
    }

     */

    updateQuery(userModel.Uid, homeModel);


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

  Future<void> loadApelido(UserModel userModel) async {

    String apelido = await SharedPrefsServices().loadApelido();
    if(apelido == ''){
      FirestoreServices().getUserApelido(userModel);
    } else {
      userModel.updateApelido(apelido);
    }

  }

  Future<void> checkIfNeedUserInfos(UserModel userModel, HomeModel homeModel, NewAuthService newAuthService) async {

    userModel.updateUid(newAuthService.loadUserIDfromFirebase());

    int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
    //pageDone é 99 se não tiver nada no shared
    //verificação redundante

    if(pageDone==99){
      //nao existe data. Pegar no firebase
      _userIsOk();//check if truckers cad is complete in firebase
    } else if(pageDone==0){
      //
      //significa que ele ainda não preencheu nada. Deve ser um novo usuario
      /*
      VoidCallback callBack = () => {
        Navigator.of(context).pop(),
        // code on continue comes here
        goToPage1OfUserInfos(context),
      };

      CustomPurePopup alert = CustomPurePopup(heightPercent, widthPercent, 'Informações', "Você ainda não iniciou o cadastro de suas informações. Você ainda não está aparecendo para os clientes. Demora menos de três minutos.", 'Depois', 'Completar', pageDone, callBack);
       */


      /*
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );

       */

      void callback(){
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage1OfUserInfos(context);
      }
      _showCustomDialogFullScreen('Informações não preenchidas', 'Você ainda não iniciou o cadastro de suas informações e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});
      //CustomPurePopup alert = CustomPurePopup(heightPercent, widthPercent, 'Informações', "Você ainda não iniciou o cadastro de suas informações. Você ainda não está aparecendo para os clientes. Demora menos de três minutos.", 'Depois', 'Completar', pageDone, callBack);

    } else if(pageDone==1){

      //obs: se pageDone == 1 significa que vai abrir a página 2 (a 1 está ok). Os dados são carregados abaixo para ficarem acessiveis no entanto eles n correpsondem a página 2.
      //carregue os dados da pagina então, que ja foi preenchida em outro momento
      //SharedPrefsUtils().loadPageOneInfo(userModel);
      loadPageOneInfo(userModel);

      void callback () {
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage2OfUserInfos(context);
      };

      _showCustomDialogFullScreen('Faltando informações', 'Você ainda não completou seu cadastro e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});


      //SharedPrefsUtils().loadPageOneInfo(userModel);
      //goToPage2OfUserInfos(context);
    } else if(pageDone==2) {

      SharedPrefsUtils().loadPageOneInfo(userModel);
      //n precisa carregar dados pois é só a cnh

      //exibe um dialog pro user escolher

      void callback () {
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage3OfUserInfos(context);
      }

      _showCustomDialogFullScreen('Faltando informações', 'Você ainda não completou seu cadastro e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});

    } else if(pageDone==3){

      SharedPrefsUtils().loadPageOneInfo(userModel);
      SharedPrefsUtils().loadPageThreeInfo(userModel);
      //exibe um dialog pro user escolher

      void callback () {
        Navigator.of(context).pop();
        // code on continue comes here
        goToPage4OfUserInfos(context);
      }

      _showCustomDialogFullScreen('Faltando informações', 'Você ainda não completou seu cadastro e por isso ainda não está aparecendo para os clientes.', 'Depois', 'Completar', pageDone, () {callback();});


    } else if(pageDone==4){

      //user ja completou tudo
      SharedPrefsUtils().loadPageOneInfo(userModel);
      //obs a página dois só tem a cnh, n precisa ler
      SharedPrefsUtils().loadPageThreeInfo(userModel);
      userModel.updateTruckerInfoOk(true);
      //a pagina 4 tb nao precisa ler pq sao dados bancários q n vamos manter no shared

      //novos métodos após todas verificações
      checkIfUserHasCancelmentsNotify(userModel, homeModel);
    }


  }


  void _showCustomDialogFullScreen(String title, String text, String btn1Text, String btn2Text, int progress, VoidCallback okCallBack){

    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.2),
      transitionDuration: Duration(milliseconds: 400),
      context: context,
      pageBuilder: (_, __, ___) {
        return Scaffold(
          body: Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.white,
              height: heightPercent*0.85,
              width: widthPercent*0.9,
              child: Column(
                children: [
                  //imagem
                  Center(
                    child: Container(
                      height: heightPercent*0.3,
                      width: widthPercent*0.7,
                      child: Image.asset('images/popup/socialmediaimg.png', fit: BoxFit.contain,),
                    ),
                  ),
                  //titulo
                  Text(title, textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.bold ,color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
                  //barra
                  Padding(
                      child: Stack(
                        children: [
                          Container(height: heightPercent*0.03, decoration: WidgetsConstructor().myBoxDecoration(Colors.grey[300], Colors.grey[300], 1.0, 45.0), ),
                          //obs: widthPercent*0.60 representa 100 da barra completa.
                          //obs 2 - progress==99 significa 0 e progress==4 significa 100%
                          Container(height: heightPercent*0.03, width: progress==99 || progress == 0 ? 0.0 : progress==1 ? widthPercent*0.20 : progress==2 ? widthPercent*0.45 : progress==3 ? widthPercent*0.65 : widthPercent*0.95, decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellow, CustomColors.yellow, 1.0, 45.0), ),
                          Container(
                            alignment: Alignment.center,
                            width: widthPercent, child: Text(progress==99 || progress==0 ? '0%' : progress==1 ? '25%' : progress==2 ? '50%' : progress==3 ? '75%' : '100%', style: TextStyle(color: Colors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),)
                        ],
                      ),
                      padding: EdgeInsets.all(35.0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.report, color: Colors.redAccent,)
                    ],
                  ),
                  Padding(
                      child: Text(text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0)),
                  SizedBox(height: heightPercent*0.04,),
                  Row(
                    children: [
                      SizedBox(width: widthPercent*0.03,),
                      Container(
                        width: widthPercent*0.4,
                        height: heightPercent*0.10,
                        child: RaisedButton(
                          color: Colors.white,
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text(btn1Text, textAlign: TextAlign.center ,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                        ),
                      )  ,
                      SizedBox(width: widthPercent*0.03,),
                      Container(
                        width: widthPercent*0.4,
                        height: heightPercent*0.10,
                        child: RaisedButton(
                          color: CustomColors.yellow,
                          onPressed: (){
                            okCallBack();
                          },
                          child: Text(btn2Text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                        ),
                      )  ,
                      SizedBox(width: widthPercent*0.03,),
                    ],
                  ),


                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );

  }


  Future<void> checkIfUserHasCancelmentsNotify(UserModel userModel, HomeModel homeModel) async {

    FirestoreServices().checkIfUserHasCancelmentsNotify(userModel.Uid, userModel, () {_onSucessShowUserCancelment(userModel, homeModel);});
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

  void _onSucessShowUserCancelment(UserModel userModel, HomeModel homeModel){
    homeModel.updateshowJobCancelmentByUser(true);

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
    //se esta aqui falta cadastro
    goToPage1OfUserInfos(context);
  }

  void goToPage1OfUserInfos(BuildContext context){
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => TruckerInfosCadUserInfo()));
  }

  void goToPage2OfUserInfos(BuildContext context){
    //Navigator.of(context).pop();
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

  Future<void> loadPageOneInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String value = (prefs.getString('image').toString());
    userModel.updateImage(value);
    value = (prefs.getString('apelido').toString());
    userModel.updateApelido(value);
    double value2 = (prefs.getDouble('latlong'));
    userModel.updateLatLoong(value2);
    value = (prefs.getString('phone').toString());
    userModel.updatePhone(value);
    value = (prefs.getString('address').toString());
    userModel.updateAddress(value);

  }









  //pages
  Widget HomePageLoggedIn(HomeModel homeModel, UserModel userModel){


    return Container(
      child: Stack(
        children: [

          //fundo azul
          _blueBackground(),

          //fundo branco do restante da página
          _whiteBackground(0.37),

          //barra transição branca
          _whiteBarArtistic(0.25),

          //texto com ola para o user
          _helloLoggedUserText(userModel),

          //texto "Seus serviços
          Positioned(
            top: heightPercent*0.40,
            left: 0.0,
            right: 0.0,
            child: Container(
              width: widthPercent,
              alignment: Alignment.center,
              child: Text('Seus serviços', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3))),
            ),
          ),


          //alerta de outras notificacoes
          Positioned(
            top: heightPercent*0.07,
            right: widthPercent*0.05,
            child: _listPopups.isEmpty ? Icon(Icons.add_alert_outlined, color: Colors.grey[100],) : customNotifyIcon(),
          ),

          //corpo do projeto com lista do firebase
          userIsLoggedIn==true && homeModel.popUpsCode=='no' ? Positioned(
            top: heightPercent*0.42,
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    //userIsLoggedIn == true ? Text("Logado") : Text("Nao logado"),
                    SizedBox(height: 25.0,),
                    /*
                                    Row(
                                      children: [
                                        IconButton(icon: Icon(Icons.calendar_today), onPressed: (){
                                          homeModel.updateShowCalendar(true);
                                        })
                                      ],
                                    ),
                                     */
                    //a lista de serviços
                    userModel.Uid == ""
                        ? Container()
                        :

                    StreamBuilder<QuerySnapshot>(
                      //stream: homeModel.query.snapshots(),
                      stream: query.snapshots(),
                      builder: (context, stream){
                        /*
                                        homeModel.query.snapshots().listen((event) async {

                                          if(_firstPass==false){ //first pass vai assegurar que não entre aqui nas verificações na primeira rodada (até pq carrega várias vezes). Somente depois quando estiver vigiando mudanças
                                            event.docChanges.forEach((change) {
                                              print('entrou no listener');
                                              _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                              /*
                                      if(change.doc.data()["situacao"] != 'sjjsjsjs'){

                                      }

                                       */
                                            });
                                          }


                                        });

                                         */

                        if (stream.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        else if (stream.hasError) {
                          return Center(child: Text(stream.error.toString()));
                        }

                        else if(stream.connectionState == ConnectionState.active){

                          QuerySnapshot querySnapshot = stream.data;

                          return querySnapshot.size == 0
                              ? Center(child: simpleTextOfFeedback(),)
                              : Expanded(
                            child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                                itemCount: querySnapshot.size,
                                itemBuilder: (context, index){


                                  _querySnapshot = querySnapshot;
                                  //homeModel.updateMsgCanBeShown(true);


                                  /*
                                                //novo listener
                                                //aparentemente n precisa do listener. Quando mdua ele ja percebe
                                                FirebaseFirestore.instance.collection(FirestoreServices.agendamentosPath).doc(querySnapshot.docs[index].id).collection('situacao').snapshots().listen((event) async {
                                                  event.docChanges.forEach((change) {
                                                    print('entrou no listener');
                                                    _handleSituation(change.doc.data()["situacao"], userModel, change.doc.data()['selectedDate'], change.doc.data()['selectedTime'], homeModel);
                                                  });
                                                });

                                                 */

                                  if(index+1==querySnapshot.size){
                                    //significa que é o ultimo load. Posso fazer verificação para abrir proxima página sem apresentar erros
                                    Future.delayed(Duration(seconds: 4)).whenComplete(() => checkIfExistMovegoingNow(querySnapshot, userModel, homeModel));
                                  }

                                  Map<String, dynamic> map = querySnapshot.docs[index].data();

                                  //click da situacao
                                  return GestureDetector(
                                    onTap: (){


                                      if(map['alert'].toString().contains('trucker')  && map['alert_saw']== false){
                                        FirestoreServices().updateAlertView(map['moveId']); //coloca como visto e remove o alerta
                                      }

                                      indexSelected = index;
                                      homeModel.updateIndexPosition(index);
                                      mapSelected = map;
                                      calculateDistance(homeModel);



                                      /*
                                            if(map['situacao'].toString()=='trucker_finished'){

                                            } else {

                                            }
                                             */

                                      homeModel.setIsLoading(false);

                                      //ATENÇÃO
                                      // sitTruckerQuitAfterPayment = 'trucker_quited_after_payment';  //<<desabilitar os controles e exibir mensagem mas permitir trocar motorista
                                      //   static String sitUserInformTruckerDidntMakeMove = 'user_informs_trucker_didnt_make_move';  //<<desabilitar os controles e exibir a mensagem
                                      //   static String sitUserInformTruckerDidntFinishedMove =
                                      //ESTAS TRES POSSIBILIDADES ACIMA NAO ESTÃO CONTEMPLADAS AQUI POIS ESTOU IMAGINANDO QUE NÃO TEM COMO CHEGAR AQUI DISPONIVEL. ESSAS SAO EXIBIDAS ASSIM QUE A SITUACAO É IDENTIFICADA EXIBE UMA POPUP E APAGA
                                      if(map['situacao'].toString()== GlobalsConstants.sitAguardando || map['situacao'].toString()== GlobalsConstants.sitAguardandoFreteiro){

                                        homeModel.updateshowJobPopUp(true);

                                      } else if (map['situacao'].toString()== GlobalsConstants.sitTruckerFinished){

                                        homeModel.updatepopUpsCode(GlobalsConstants.sitTruckerFinished);

                                      } else if (map['situacao'].toString()== GlobalsConstants.sitAccepted){

                                        homeModel.updateshowJobPopUp(true);

                                      } else if (map['situacao'].toString()== GlobalsConstants.sitPago){

                                        homeModel.updateIndexPosition(index);
                                        homeModel.updatepopUpsCode('pago_reminder');

                                      } else if(map['situacao'].toString()== GlobalsConstants.sitReschedule){

                                        homeModel.updateIndexPosition(index);
                                        homeModel.updatepopUpsCode(GlobalsConstants.sitReschedule);

                                      }




                                    },
                                    //child: Text(map['name']),
                                    child: ListLine(map, userModel, homeModel),

                                  );



                                }
                            ),
                          );
                        }


                      },
                    ),

                    homeModel.showCalendar==true ? SingleChildScrollView(
                      child:Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CloseButton(onPressed: (){
                                homeModel.updateShowCalendar(false);
                              },)
                            ],
                          ),
                          _buildCalendar(),

                        ],
                      ) ,
                    ) : Container(),

                  ],
                ),
              ),
            ),
          ) : Container(),

          //appbar
          Positioned(
            top: 0.0,
            child: Container(
                height: heightPercent*0.12,
                width: widthPercent,
                child: Column(
                  children: [
                    SizedBox(height: 30.0,),
                    Row(
                      children: [
                        IconButton(icon: Icon(Icons.menu, color: Colors.white, size: 35.0,), onPressed: (){
                          homeModel.updateShowDrawer();
                        }),
                      ],
                    ),
                  ],
                )
            ),
          ),

          //notificatiosn page
          showNotificationsScreen==true ? notificationsScreen(homeModel) : Container(),

          //menu
          homeModel.showDrawer==true ? Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: widthPercent*0.2,
            child: MenuDrawer(),
          ) : Container(),
          //barra branca que fecha o menu
          homeModel.showDrawer==true ? Positioned(
            top: 50.0,
            bottom: 0.0,
            right: 0.0,
            left: widthPercent*0.8,
            child: GestureDetector(
              onTap: (){
                homeModel.updateShowDrawer();
              },
              child: Container(
                alignment: Alignment.topCenter,
                color: Colors.white.withOpacity(0.5),
                child: Icon(Icons.arrow_back, color: CustomColors.blue, size: 50.0,),
                //n precisa mostrar nada
              ),
            ),
          ) : Container(),

          //showJobPopUp==true ? Container(decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0), child: JobPopUp(),) : Container(),

          homeModel.showJobPopUp==true ? popUpWithResumeOfTheJob(homeModel) : Container(),

          homeModel.showJobConfirmationPopup==true
              ? popUpConfirmJob(homeModel)
              : Container(),

          homeModel.showJobDeclinationPopup==true
              ? popUpDeclinationJob(homeModel)
              : Container(),

          homeModel.showJobCancelmentByUser==true
              ? popupShowUserHasCancelledJob(userModel, homeModel)
              : Container(),

          //reconstruindo os popups
          homeModel.popUpsCode=='no'
              ? Container()
              : homeModel.popUpsCode=='pago_little_negative'  && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']??'erro'+'.', 'Mudança não ocorreu', () {_pago_passou_mudancaNocorreu(homeModel); }, 'Ir para mudança', () { _pago_passou_abrirMove(_querySnapshot, homeModel);})
          //? WidgetsConstructor().customPopUp('Mudança acontecendo agora', 'Você têm uma mudança que começou às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Ir para mudança', 'Mudança não ocorreu', widthPercent, heightPercent, () {_pago_passou_abrirMove(_querySnapshot);}, () {_pago_passou_mudancaNocorreu();})
              : homeModel.popUpsCode=='pago_much_negative'  && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+' em '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']??'erro'+'.', 'Mudança não ocorreu', () {_pago_passouMuito_mudancaNaoOcorreu(homeModel, _querySnapshot); }, 'Finalizar\ne avaliar', () {_pago_passouMuito_finalizar(homeModel); })
          //? WidgetsConstructor().customPopUp('Atenção', 'Havia uma mudança agendada para às '+_querySnapshot.docs[indexPosition]['selectedTime']+' em '+_querySnapshot.docs[indexPosition]['selectedDate']+'.', 'Mudança não ocorreu', 'Finalizar mudança', widthPercent, heightPercent, () {_pago_passouMuito_mudancaNaoOcorreu();}, () {_pago_passouMuito_finalizar();})
              : homeModel.popUpsCode=='pago_reminder'  && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+'.', 'Depois', () {_pago_reminder_depois(homeModel); }, 'Ir para mudança', () { _pago_reminder_irParaMove(_querySnapshot, homeModel);})
          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
          //  () {_pago_reminder_irParaMove(_querySnapshot);}, () {_pago_reminder_depois();})
              : homeModel.popUpsCode=='pago_moveTime'
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Hora de mudança', 'Você tem uma mudança agora.',
              'Depois', () { _pago_moveTime_depois(homeModel);}, 'Ir para mudança', () {_pago_moveTime_irParaMove(_querySnapshot, homeModel); })
          //? WidgetsConstructor().customPopUp('Hora de mudança', 'Você tem uma mudança agora.', 'Ir para mudança', 'Depois', widthPercent, heightPercent,
          //  () {_pago_moveTime_irParaMove(_querySnapshot);}, () {_pago_moveTime_depois();})
              : homeModel.popUpsCode=='accepted_little_negative' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você tem uma mudança que iniciou às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
              'Cancelar mudança', () {_accepted_passou_cancelarMove(homeModel); }, 'Aguardar', () {_accepted_passou_aguardar(homeModel); })
          //? WidgetsConstructor().customPopUp('Atenção', 'Você tem uma mudança que iniciou às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Não realize esta mudança até que o usuário normalize a situação.',
          // 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
          //  () {_accepted_passou_aguardar();}, () {_accepted_passou_cancelarMove();})
              : homeModel.popUpsCode == 'accepted_much_negative'  && homeModel.indexPosition != null
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+' do dia '+_querySnapshot.docs[homeModel.indexPosition]['selectedDate']??'erro'+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.',
              'Ok', () { _accepted_passouMuito_cancelar(homeModel);})
          //? WidgetsConstructor().customPopUp1Btn('Atenção', 'Você tinha uma mudança às'+_querySnapshot.docs[indexPosition]['selectedTime']+' do dia '+_querySnapshot.docs[indexPosition]['selectedDate']+'. Como o usuário não efetuou o pagamento NÓS estamos cancelando esta mudança.'
          // , Colors.blue, widthPercent, heightPercent,
          //  () {_accepted_passouMuito_cancelar();})
              : homeModel.popUpsCode=='accepted_reminder' && homeModel.indexPosition != null
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro' +'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.',
              'Ok', () { _accepted_reminder(homeModel);})
          //? WidgetsConstructor().customPopUp1Btn('Lembrete', 'Você tem uma mudança agendada para daqui a pouco às '+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Sugerimos não iniciar o processo enquanto o pagamento não for confirmado.'
          // , Colors.blue, widthPercent, heightPercent,
          //  () {_accepted_reminder();})
              : homeModel.popUpsCode=='accepted_moveTime' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[homeModel.indexPosition]['selectedTime']??'erro'+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança.'
              , 'Cancelar mudança', () { _accepted_moveTime_cancelarMove(homeModel);}, 'Aguardar', () {_accepted_moveTime_aguardar(homeModel); })
          //? WidgetsConstructor().customPopUp('Atenção', 'Existe uma mudança que inicia às'+_querySnapshot.docs[indexPosition]['selectedTime']+'. No entanto o usuário ainda não efetuou o pagamento. Você pode optar por aguardar ou cancelar esta mudança..'
          // , 'Aguardar', 'Cancelar mudança', widthPercent, heightPercent,
          //  () {_accepted_moveTime_aguardar();}, () {_accepted_moveTime_cancelarMove();})
              : homeModel.popUpsCode=='_pago_passouMuito_mudancaNaoOcorreu_alert' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'Você está informando que não realizou a mudança.',
              'Não prestei o serviço', () { _pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel.Uid, homeModel);}, 'Eu prestei este serviço', () { _pago_passouMuito_mudancaNaoOcorreuCancelCallback(homeModel);})
          //? WidgetsConstructor().customPopUp('Atenção', 'Você está informando que não realizou a mudança.',
          // 'Não prestei o serviço', 'Eu prestei este serviço', widthPercent, heightPercent, ()
          // {_pago_passouMuito_mudancaNaoOcorreuConfirmCallback(_querySnapshot.docs[indexPosition]['moveId'], userModel.Uid);},
          // () {_pago_passouMuito_mudancaNaoOcorreuCancelCallback();})
              : homeModel.popUpsCode=='user_informs_trucker_didnt_finished_move' && homeModel.indexPosition != null
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
              'Vou voltar para terminar', () { _user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[homeModel.indexPosition]['moveId'], userModel);},
              'Não vou voltar e concordo não receberei pelo serviço', () { _user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel);})
          //? WidgetsConstructor().customPopUp('Atenção', 'O cliente informou que você ainda não finalizou o serviço.',
          // 'Vou voltar para terminar', 'Não vou voltar e concordo não receberei pelo serviço', widthPercent, heightPercent,
          // () {_user_informed_truckerDidntFinishedMoveTruckerIsCommingBack(_querySnapshot.docs[indexPosition]['moveId'], userModel);},
          // () {_user_informed_truckerDidntFinishedMoveCancel(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
              : homeModel.popUpsCode=='user_informs_trucker_didnt_make_move' && homeModel.indexPosition != null
          //? WidgetsConstructor().customPopUp1Btn('Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.", Colors.red, widthPercent, heightPercent, () { _user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[indexPosition]['moveId']);})
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Atenção', "O cliente informou que o serviço não foi prestado. Nós iremos devolver o dinheiro ao usuário e você fica banido da plataforma por "+(GlobalsConstants.banishementTime2*7).toString()+" dias.",'Ok', () {_user_informed_truckerDidndShowUp(userModel.Uid, _querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel); })
              : homeModel.popUpsCode=='user_finished'
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
              'Cancelar', () { _accepted_reminder(homeModel);}, 'Finalizar', () { _userFinishedAndAvaliatedMove(_querySnapshot, homeModel); }):
          //? WidgetsConstructor().customPopUp('Mudança finalizada', 'O cliente confirmou que a mudança terminou. Caso já tenha terminado sua parte, finalize também para avaliar e encerrar o serviço.',
          // 'Finalizar', 'Cancelar', widthPercent, heightPercent, () { _userFinishedAndAvaliatedMove(_querySnapshot);} , () {_accepted_reminder();} )
          homeModel.popUpsCode == GlobalsConstants.sitTruckerFinished
              ? Popup().popupWithOneButton(context, heightPercent, widthPercent, 'Esperando o cliente', 'Aguardando o cliente finalizar para encerrar.', 'Ok', () { _accepted_reminder(homeModel);})
              : homeModel.popUpsCode == GlobalsConstants.sitReschedule
              ? Popup().popupWithTwoButtons(context, heightPercent, widthPercent, 'Reagendamento', 'O cliente alterou data ou horário. A nova data é ${_querySnapshot.docs[homeModel.indexPosition]['selectedDate']} às ${_querySnapshot.docs[homeModel.indexPosition]['selectedTime']}. Você pode desistir sem punições.',
              'Manter', () { _situation_Rescheduled(_querySnapshot.docs[homeModel.indexPosition]['moveId'], homeModel);}, 'Desistir', () { _situation_Rescheduled_truckerQuit(homeModel); })
              : Container(),


          homeModel.isLoading==true
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
      ),
    );
  }

  Widget HomePageUnLogged(HomeModel homeModel){

    return Container(
      height: heightPercent,
      width: widthPercent,
      color: Colors.white,
      child: Stack(
        children: [


          //inicio do corpo com fundo azul
          _blueBackground(),

          //texto welcome
          _welcomeText(),

          //barra branca
          _whiteBarArtistic(0.55),


          //itens da animação de scroll


          //vai ser: se offset maior do que 100 então aparece
          //imagem do carregador que entra com efeito 3d
          offset > 5.000 && offset<155.4 ? Positioned(
              bottom: 0.0,
              top: heightPercent*0.45,
              child: Transform(

                //transform: Matrix4.identity()..setEntry(3, 2, 0.01)..rotateX(1.0),
                transform: Matrix4.identity()..setEntry(3, 2, 0.01)..rotateX(1.0-offset/100 <= 0.0 ? 0.0 : 1.0-offset/100),

                alignment: FractionalOffset.center,
                //child: Image.asset('images/cadinfos/cnhavatar.png', fit: BoxFit.contain,),
                child: Image.asset('images/home/scrollanim/carregador.png', fit: BoxFit.contain,),

                /*
              child: RotationTransition(
                turns: _controller,
                child: Image.asset('images/cadinfos/cnhavatar.png', fit: BoxFit.contain,),

              )

               */

              )
          ) : Container(),
          //imagem igual a do carregador anterior mas estática...aqui ele vai pra esquerda fingindo uma saida da mesma imagem
          offset > 155.3 ? Positioned(
            bottom: 0.0,
            top: heightPercent*0.45,
            left: offset<469 ? 0.0 : 469-offset,
            child: Image.asset('images/home/scrollanim/carregador.png', fit: BoxFit.contain,),
          ) : Container(),

          //fundo branco subindo - fora da ordem
          offset>850 ? _artisticBagroundForAnim() : Container(),

          //sequencia de caixas subindo
          offset > 120 && offset < 1335 ? Positioned(
            bottom: -250+offset < 0.0 ? -250+offset : 0.0,
            right: 0.0,
            child: Image.asset('images/home/scrollanim/rightbox.png', fit: BoxFit.contain,),
          ) : Container(),
          offset > 135  && offset < 1350 ? Positioned(
            bottom: -300+offset < 0.0 ? -300+offset : 0.0,
            left: 0.0,
            child: Image.asset('images/home/scrollanim/leftbox.png', fit: BoxFit.contain,),
          ) : Container(),
          offset > 135  && offset < 1300 ? Positioned(
            bottom: -400+(offset-40) < 0.0 ? -400+(offset-40) : 0.0,
            left: widthPercent*0.25,
            child: Image.asset('images/home/scrollanim/middlebox.png', fit: BoxFit.contain,),
          ) : Container(),

          //texto explicativo 1
          offset>448 && offset < 1970 ? _explicationText1('Você disponibiliza algumas informações') : Container(),
          //aqui é quando acontece o fundo branco subindo...mas ele esdtá acima fora de ordem para encaixar na animação nas sobreposições

          offset > 1360 && offset < 2104 ? _fotografiaCarros() : Container(),

          offset > 1600 && offset < 2104 ? _textAboveCarro('Foto do\nveículo') : Container(),

          offset > 1578 && offset < 2104 ? _fotografiaPerfil() : Container(),

          offset > 1704 && offset < 2104 ? _textAbovePerfil('Sua foto') : Container(),

          offset > 1800 && offset < 2104 ? _locationIcon() : Container(),

          offset > 1850 && offset < 2104 ? _textAboveLocation('Posição') : Container(),


          offset > 2114 && offset < 2810 ? _celImg() : Container(),

          offset > 2114 && offset < 2810 ? _truckerImg() : Container(),

          offset > 2354 && offset < 2810 ? _yellowLine() : Container(),

          offset > 2200 && offset < 2810 ? _celPerfilDoCliente() : Container(),

          offset > 2180  && offset < 2810 ? _textAboveConectingClients('Nós conectamos você\na novos clientes') : Container(),

          offset > 2372 ? _acordoImg() : Container(),

          offset > 2900 ? _logo() : Container(),

          offset > 3000 && offset < 3380 ? _web() : Container(),

          offset > 3000 && offset < 3380 ? _textAboveWeb('Expanda sua rede') : Container(),


          //btn voltar ao inicio

          //lista fake para dar profundidade na tela na animação
          Positioned(
              top: 100.0,
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: heightPercent,
                width: widthPercent,
                child: Scrollbar(
                  child: ListView( //essa listview é apenas para a tela crescer e poder ser rolada
                    controller: _scrollController,
                    children: [
                      Container(),
                      SizedBox(height: 3900.0,),
                      Container(color: Colors.transparent, width: 500.0, height: 100.0,)
                    ],
                  ),
                ),
              )
          ),

          //texto conheça o serviço
          offset < 48  ? _meetUsText() : Container(),

          offset > 3400 ? _btnVoltarAoInicio() : Container(),

          offset > 3400 ? _textVoltarAoInicio() : Container(),

          offset > 3400 ? _btnLoginDoFinalDaAnimacao() : Container(),

          //fim da animação

          //botão amarelo
          //verifica se o menu está aberto. Se estiver some o botão para não confundir o fundo
          homeModel.showDrawer==false ? _yellowButton(0.15, 0.05, 'Login') : Container(),


          //fim dos itens de scroll

          //appbar
          Positioned(
            top: 0.0,
            child: Container(
                height: heightPercent*0.12,
                width: widthPercent,
                child: Column(
                  children: [
                    SizedBox(height: 30.0,),
                    Row(
                      children: [
                        IconButton(icon: Icon(Icons.menu, color: Colors.white, size: 35.0,), onPressed: (){
                          homeModel.updateShowDrawer();
                        }),
                      ],
                    ),
                  ],
                )
            ),
          ),
          //menu
          homeModel.showDrawer==true ? Positioned(
            top: 0.0,
            bottom: 0.0,
            left: 0.0,
            right: widthPercent*0.2,
            child: MenuDrawer(),
          ) : Container(),
          //barra branca que fecha o menu
          homeModel.showDrawer==true ? Positioned(
            top: 50.0,
            bottom: 0.0,
            right: 0.0,
            left: widthPercent*0.8,
            child: GestureDetector(
              onTap: (){
                homeModel.updateShowDrawer();
              },
              child: Container(
                alignment: Alignment.topCenter,
                color: Colors.white.withOpacity(0.5),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 50.0,),
                //n precisa mostrar nada
              ),
            ),
          ) : Container(),



        ],
      ),
    );

  }





  Widget _explicationText1(String text){

    return Positioned(
      right: 800-offset > 0.0 ? 800-offset : 10.0,
      top: heightPercent*0.2,
      child: Container(
        height: heightPercent*0.2,
        width: widthPercent*0.65,
        decoration: BoxDecoration(
          color: CustomColors.yellowPostIt,
          shape: BoxShape.rectangle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Text(text, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
          ),
        ),
      ),
    );
  }

  Widget _artisticBagroundForAnim(){

    return Positioned(
        top: offset < 1280 ? 1200 - offset : offset > 1900 ? offset-1900 : -60.0,
        left: 0.0,
        right: 0.0,
        child: Column(
          children: [
            SizedBox(height: 20.0),
            Container(
              width: widthPercent,
              child: FittedBox(
                child: Image.asset('images/home/barrabranca.png'),
                fit: BoxFit.fill,
              ),
            ),
            Container(
              height: heightPercent*0.90,
              width: widthPercent,
              color: Colors.white,
            ),
          ],
        )
    );

  }

  Widget _fotografiaCarros(){

    double max;
    if(offset>=1567){
      max = 2900;
    }

    return Positioned(
      top: heightPercent*0.40,
      left: offset<1578 ? offset-1360 : 1578.0-1360.0,
      child: Container(
          width: widthPercent*0.30,
          height: heightPercent*0.30,
          child: Transform.rotate(
            //scale: ((offset*0.001)-1),
            //scale: offset-(offset*0.01),
            angle: offset<1578 ? offset*0.01 : max,
            child: Image.asset('images/home/scrollanim/fotos_car.png', fit: BoxFit.fill,),
          )
      ),
    );

  }

  Widget _fotografiaPerfil(){

    double max;
    if(offset>=1704){
      max = 1704;
    }

    return Positioned(
      top: heightPercent*0.45,
      left: offset<1704 ? offset-1578 : 1704.0-1578.0,
      child: Container(
          width: widthPercent*0.25,
          height: heightPercent*0.20,
          child: Transform.rotate(
            //scale: ((offset*0.001)-1),
            //scale: offset-(offset*0.01),
            angle: offset<1704 ? offset*0.02 : max,
            child: Image.asset('images/home/scrollanim/fotos_homem.png', fit: BoxFit.fill,),
          )
      ),
    );

  }

  Widget _textAboveCarro(String text){

    return Positioned(
      right: widthPercent*0.09,
      top: heightPercent*0.70,
      child: Text(text, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
    );
  }

  Widget _textAbovePerfil(String text){

    return Positioned(
      right: widthPercent*0.40,
      top: heightPercent*0.70,
      child: Text(text, style: TextStyle(color: Colors.redAccent, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
    );
  }

  Widget _locationIcon(){
    return Positioned(
      top: heightPercent*0.47,
      left: widthPercent*0.05,
      //child: Icon(Icons.pin_drop_sharp, color: Colors.redAccent, size: heightPercent*0.10,),
      child: Container(
        height: heightPercent*0.15,
        width: widthPercent*0.25,
        child: Image.asset('images/home/scrollanim/celmaporigin.png', fit: BoxFit.fill,),
      ),
    );
  }

  Widget _textAboveLocation(String text){

    return Positioned(
      left: widthPercent*0.05,
      top: heightPercent*0.70,
      child: Text(text, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
    );
  }

  Widget _yellowLine(){

    print(widthPercent*(offset*0.000001));

    return Positioned(
        top: heightPercent*0.22,
        right: 2210.0-2114,
        child: Container(
          height: heightPercent*0.01,
          width: widthPercent*0.35,
          color: Colors.white,
        )
    );

  }

  Widget _celPerfilDoCliente(){

    return Positioned(
      top: heightPercent*0.18,
      right: 2210.0-2114,
      child: Container(
        width: widthPercent*0.10,
        height: heightPercent*0.10,
        child: Image.asset('images/home/scrollanim/celavatar.png', fit: BoxFit.fill,),
      ),
    );

  }

  Widget _celImg(){

    double max;
    if(offset>=2185){
      max=2185.0-2114;
    }

    return Positioned(
      top: heightPercent*0.20,
      right: offset<2185 ? offset-2114 : max,
      child: Container(
        width: widthPercent*0.25,
        height: heightPercent*0.15,
        child: Image.asset('images/home/scrollanim/celmaps.png', fit: BoxFit.fill,),
      ),
    );

  }

  Widget _truckerImg(){

    double max;
    if(offset>=2185){
      max=2185.0-2114;
    }

    return Positioned(
      top: heightPercent*0.20,
      left: offset<2185 ? offset-2114 : max,
      child: Container(
        width: widthPercent*0.25,
        height: heightPercent*0.15,
        child: Image.asset('images/home/scrollanim/truckerico.png', fit: BoxFit.fill,),
      ),
    );

  }

  Widget _textAboveConectingClients(String text){

    return Positioned(
      left: 0.0,
      right: 0.0,
      top: heightPercent*0.4,
      child: Center(
        child: Text(text, textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(4.0)),),
      ),
    );
  }


  Widget _acordoImg(){

    //print('bottom'+(offset-2195).toString());

    return Positioned(

      left: 0.0,
      right: 0.0,
      bottom: offset<2810 ? offset-2550 : heightPercent*0.42,
      child: Container(
        height: heightPercent*0.25,
        width: widthPercent,
        child: FittedBox(
          child: Image.asset('images/home/scrollanim/acordopic.png'),
          fit: BoxFit.fill,
        ),
      ),
    );

  }

  Widget _logo(){

    //print('bottom'+(offset-2195).toString());

    return Positioned(

      top: heightPercent*0.15,
      child: Container(
        width: widthPercent,
        height: heightPercent*0.20,

        child: Center(
          child: FittedBox(
            child: Image.asset('images/home/scrollanim/logo.png'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );

  }

  Widget _web(){

    //print('bottom'+(offset-2195).toString());

    return Positioned(

      bottom: heightPercent*0.10,
      child: Container(
        width: widthPercent,
        height: heightPercent*0.25,
        child: Center(
          child: Image.asset('images/home/scrollanim/socialmedia.png'),
        ),
      ),
    );

  }

  Widget _textAboveWeb(String text){

    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 10.0,
      child: Center(
        child: Text(text, textAlign: TextAlign.center,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(4.0)),),
      ),
    );
  }

  Widget _btnVoltarAoInicio(){

    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: heightPercent*0.10,
      child: Center(
        child: Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],

          ),
          child: IconButton(icon: Icon(Icons.arrow_upward, color: CustomColors.yellow, size: 35.0,), onPressed: (){
            print('click');
            //final topOffset = _scrollController.position.maxScrollExtent;
            setState(() {
              offset=0.0;
            });

          }),
        ),
      ),
    );
  }

  Widget _textVoltarAoInicio(){
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: heightPercent*0.05,
      child: Center(
        child: Container(
          child: Text('Voltar ao início', textAlign: TextAlign.center,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0)),),
        ),
      ),
    );
  }

  Widget _btnLoginDoFinalDaAnimacao(){

    return Positioned(
        top: heightPercent*0.65,
        left: 0.0,
        right: 0.0,
        child: Center(
          child: Container(
            height: heightPercent*0.10,
            width: widthPercent*0.6,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],

            ),
            child: RaisedButton(
              color: CustomColors.yellow,
              onPressed: (){
                setState(() {
                  print('clicou no botao');
                  offset=0.0;
                  _openLoginPage(2); //dois é para encaminhar direto para para novo user na pagina login
                });
              },
              child: Text('Registrar', textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),
            ),
          ),
        )
    );
  }

  void _openLoginPage(int sit){
    /*
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => LoginChooseView()));

     */
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => NewLoginPage(sit)));

  }


  Widget _blueBackground(){
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: 0.0,
      bottom: heightPercent*0.30,
      child: Container(
        color: CustomColors.blue,
      ),
    );
  }

  Widget _whiteBackground(double top){
    return Positioned(
      left: 0.0,
      right: 0.0,
      top: heightPercent*top,
      bottom: 0.0,
      child: Container(
        color: Colors.white,
      ),
    );
  }

  Widget _yellowButton(double top, double right, String text){
    return Positioned(
      top: (heightPercent*top)-(offset-20),
      right: widthPercent*right,
      child: Container(
        height: heightPercent*0.08,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],

        ),
        child: RaisedButton(
          color: CustomColors.yellow,
          onPressed: (){
            //click
            _openLoginPage(1); //opção 1 vai para a página de login
          },
          child: Text(text, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0)),),

        ),
      ),
    );
  }

  Widget _welcomeText(){

    return Positioned(
        top: (heightPercent*0.30)-offset,
        left: 0.0,
        right: 0.0,
        child: Center(
          child: Text('Bem-vindo!', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(6.0)),),
        )
    );
  }

  Widget _whiteBarArtistic(double top){

    return Positioned(
      top: heightPercent*top,
      left: 0.0,
      right: 0.0,
      child: Container(
          width: widthPercent,
          height: heightPercent*0.22,
          child: FittedBox(
            child: Image.asset('images/home/barrabranca.png'),
            fit: BoxFit.fill,
          )
      ),
    );
  }

  Widget _meetUsText(){

    return Positioned(
        top: heightPercent*0.75,
        left: 0.0,
        right: 0.0,
        child: GestureDetector(
          onTap: (){
            //click
            setState(() {
              print('foi');

              double end = _scrollController.position.maxScrollExtent;
              setState(() {
                //_scrollController.animateTo(end, duration: Duration(seconds: 20), curve: Curves.easeInOut);
                _scrollController.animateTo(end, duration: Duration(seconds: 20), curve: Curves.easeOut);
              });

            });
          },
          child: Column(
            children: [
              Center(
                child: Text('Deslize para conhecer\nnosso serviço', textAlign: TextAlign.center , style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5)),),
              ),
              Center(
                child: Icon(Icons.arrow_drop_up, color: CustomColors.blue,size: 75,),
              )
            ],
          ),
        )
    );
  }

  Widget _helloLoggedUserText(UserModel userModel){

    return Positioned(
        top: heightPercent*0.20,
        left: 0.0,
        right: 0.0,
        child: Center(
          child: Text('Olá ${userModel.Apelido??''}', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.5)),),
        )
    );
  }






  Future<void> testeNovaMudanca(double valor){

    String date = DateUtils().giveMeTheTimeNow();
    String today = DateUtils().giveMeTheDateToday();

    CollectionReference userLocation = FirebaseFirestore.instance.collection('agendamentos_aguardando');
    return userLocation
        .doc(date)
        .set({
      'ajudantes' : 1,
      'alert' : 'user',
      'alert_saw' : false,
      'carro' : 'pickupP',
      'endereco_destino' : 'Estr. Monan Grande, 31 - Badu, Niterói - RJ, 24320-040, Brasil - Rio de Janeiro',
      'endereco_origem' : 'Tv. Petronilha Miranda, 49 - Barreto, Niterói - RJ, 24110-657, Brasil - Rio de Janeiro',
      'escada' : false,
      'id_contratante' : 'b5RkDgc9hbeIovmviGN6tvbSiEu1',
      'id_freteiro' : 'vQtalKKBk5hW1bmCFKW1m2QzLWF2',
      'lances_escada' : 0,
      'moveId' : date,
      'nome_freteiro' : 'Thiago fretes',
      'pago' : null,
      'placa' : 'kvp8h60',
      'ps': null,
      'selectedDate' : today,
      'selectedTime' : '20:00',
      'situacao' : 'accepted',
      'valor' : valor,

    });

  }

}



 */