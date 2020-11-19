import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:fretes_go_freteiro/utils/notificationMeths.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:date_format/date_format.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}


class HomePageState extends State<HomePage> {

  //FirebaseAuth mAuth = FirebaseAuth.instance;
  //FirebaseUser firebaseUser;

  FirebaseAuth auth = FirebaseAuth.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  
  UserModel userModelGLobal;

  bool userIsLoggedIn;
  bool needCheck=true;

  bool showJobPopUp=false;
  bool showJobConfirmationPopup=false;
  bool showJobDeclinationPopup=false;
  bool showJobCancelmentByUser=false;

  double heightPercent;
  double widthPercent;

  Map mapSelected;
  int indexSelected;

  double distance;

  bool isLoading=false;

  //now trying this
  //https://brainsandbeards.com/blog/how-to-add-local-notifications-to-flutter-app <<este funcionou

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails notificationAppLaunchDetails;

  @override
  void initState() {
    super.initState();

    checkFBconnection();
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
        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {


            Query query;

            if(needCheck==true){
              needCheck=false;
                //se nao está logado n precisa verificar nada. Pois ele pode fazer login quando quiser
              if(userIsLoggedIn==true){
                checkEmailVerified(userModel, newAuthService);
              }
            }

            query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('id_freteiro', isEqualTo: userModel.Uid);

            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => TruckerInfosCadBankData()));



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
                                          checkIfExistMovegoingNow(querySnapshot);
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

                                            setState(() {
                                              showJobPopUp=true;
                                              isLoading=false;
                                            });



                                          },
                                          //child: Text(map['name']),
                                          child: ListLine(map),
                                        );
                                        //return Trucker(querySnapshot.docs[index]);

                                      } ),);

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

                    isLoading==true
                    ? Center(child: CircularProgressIndicator(),)
                    : Container(),

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

                  ],
                )
            );
          },
        );
      },
    );
  }

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

  Future<void> checkIfExistMovegoingNow(QuerySnapshot querySnapshot) async {

    int i = 0;
    while(i<querySnapshot.size){

      if(querySnapshot.docs[i]['situacao'] == 'accepted'){

        DateTime scheduledDate = DateUtils().convertDateFromString(querySnapshot.docs[i]['selectedDate']);
        DateTime scheduledDateAndTime = DateUtils().addMinutesAndHoursFromStringToAdate(scheduledDate, querySnapshot.docs[i]['selectedTime']);
        final dif = DateUtils().compareTwoDatesInMinutes(DateTime.now(), scheduledDateAndTime);

        if(dif.isNegative) {
          //a data já expirou

          MoveClass _moveClass = MoveClass();
          Map<String, dynamic> map = querySnapshot.docs[i].data();
          _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

          /*
          Future.delayed(Duration(seconds: 5)).then((_) {
            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => AvaliationPage(_moveClass)));
          });

           */

        } else if(dif<=60 && dif>15){

          _displaySnackBar(context, "Você possui uma mudança agendada às "+querySnapshot.docs[i]['selectedTime']);

        } else if(dif<=15){
          //ta na hora da mudança. Abrir a pagina de mudança
          MoveClass _moveClass = MoveClass();
          Map<String, dynamic> map = querySnapshot.docs[i].data();
          _moveClass = MoveClass().passDataFromQuerySnapshotToMoveClass(map);

          _moveClass = await MoveClass().getTheCoordinates(_moveClass, _moveClass.enderecoOrigem, _moveClass.enderecoDestino).whenComplete(() {

            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => MoveDayPage(_moveClass)));


          });


        } else {

          //do nothing, falta mt ainda

        }


      }

    i++;
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

  void DenyJob() async {

    await FirestoreServices().confirmJobDeny(mapSelected['moveId'], () {_onSucessDenyJob();}, () {_onFailureDenyJob();});

  }

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

  Future<void> calculateDistance() async {

    distance = await MoveClass().getTheDistanceFromTwoAddress(mapSelected['endereco_origem'], mapSelected['endereco_destino']);
    setState(()  {
      distance = distance;
    });


  }

  void checkFBconnection() async {

    //SharedPrefsUtils().deletePageOneInfo();

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
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

      checkIfNeedUserInfos(userModel);

    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
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
    } else if(pageDone==2){

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

      //user ja completou tudo
      SharedPrefsUtils().loadPageOneInfo(userModel);
      //obs a página dois só tem a cnh, n precisa ler
      SharedPrefsUtils().loadPageThreeInfo(userModel);
      userModel.updateTruckerInfoOk(true);

      //novos métodos após todas verificações
      checkIfUserHasCancelmentsNotify(userModel);
    }


  }

  Future<void> checkIfUserHasCancelmentsNotify(UserModel userModel) async {

    FirestoreServices().checkIfUserHasCancelmentsNotify(userModel.Uid, userModel, () {_onSucessShowUserCancelment(userModel);});
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
    await FirestoreServices().getUserInfoCheckWhatIsMissing(userModelGLobal, () {goToPage1OfUserInfos(context); }, () {goToPage2OfUserInfos(context); }, () {goToPage3OfUserInfos(context); });

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







