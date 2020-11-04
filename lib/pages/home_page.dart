import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/pages/email_verify_view.dart';
import 'package:fretes_go_freteiro/login/services/new_auth_service.dart';
import 'package:fretes_go_freteiro/menu/drawer.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';

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

  Map mapSelected;
  int indexSelected;




  @override
  void initState() {
    super.initState();
    checkFBconnection();

  }


  @override
  void dispose() {
    super.dispose();
    needCheck=true;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget child, UserModel userModel) {
        userModelGLobal = userModel;
        //isLoggedIn(userModel);
        return ScopedModelDescendant<NewAuthService>(
          builder: (BuildContext context, Widget child, NewAuthService newAuthService) {



            if(needCheck==true){
              needCheck=false;
                //se nao está logado n precisa verificar nada. Pois ele pode fazer login quando quiser
              if(userIsLoggedIn==true){
                checkEmailVerified(userModel, newAuthService);
              }
            }

            Query query = FirebaseFirestore.instance.collection("agendamentos_aguardando").where('id_freteiro', isEqualTo: userModel.Uid);


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


                                        Map<String, dynamic> map = querySnapshot.docs[index].data();
                                        return GestureDetector(
                                          onTap: (){

                                            setState(() {

                                              indexSelected = index;
                                              mapSelected = map;
                                              showJobPopUp=true;

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
                  ],
                )
            );
          },
        );
      },
    );
  }

  Widget ListLine(Map map){

    return Container(
      decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 3.0),
      child: Column(
        children: [
          Row(
            children: [
              WidgetsConstructor().makeText("Situação: ", Colors.blue, 15.0, 10.0, 5.0, null),
              WidgetsConstructor().makeText("Aqui vai ser criado", Colors.black, 15.0, 10.0, 5.0, null),
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
              WidgetsConstructor().makeText("Valor: ", Colors.black, 15.0, 0.0, 5.0, null),
              WidgetsConstructor().makeText("R\$ "+map['valor'].toStringAsFixed(2), Colors.black, 15.0, 0.0, 5.0, null),
            ],
          ),

        ],
      )
    );
  }

  Widget JobPopUp(){

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
          Text(mapSelected['id_freteiro']),

        ],
      ),
    );

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
    await newAuthService.loadUser(userModel);

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
        await FirestoreServices().loadUserInfos(userModel, () {_onSucessLoadInfos(userModel);}, () {_onFailureLoadInfos();});
      }


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
      }


    } else{

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmailVerify()));

    }
  }

  void _onSucessLoadInfos(UserModel userModel) {
    //passar data para sharedPrefs evitando querys
    if(userModel.AllInfoIsDone==1){
      SharedPrefsUtils().savePageOneInfo(userModel);
    } else if(userModel.AllInfoIsDone==2){
      SharedPrefsUtils().savePageTwoInfo(userModel);
    } else if(userModel.AllInfoIsDone==3){
      SharedPrefsUtils().savePageThreeInfo(userModel);
    } else {
      //ready nothing, fez nada
    }



  }

  void _onFailureLoadInfos(){
    //faz nada. precisa cadastrar
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







