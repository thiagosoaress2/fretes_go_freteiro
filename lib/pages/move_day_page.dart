import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/avaliation_page.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';


class MoveDayPage extends StatefulWidget {
  MoveClass _moveClass = MoveClass();

  MoveDayPage(this._moveClass);

  @override
  _MoveDayPageState createState() => _MoveDayPageState();
}

typedef Marker MarkerUpdateAction(Marker marker); //pra q serve?


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class _MoveDayPageState extends State<MoveDayPage> {

  bool shoudLoadIt=true;

  //https://codelabs.developers.google.com/codelabs/google-maps-in-flutter#3


  bool mapIsOk=false;

  double heightPercent;
  double widthPercent;

  GoogleMapController mapController;

  MoveClass moveClass = MoveClass();

  //final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _initialcameraposition;
  LatLng _origemPos;
  LatLng _destinyPos;

  Set<Marker> markers = {};
  BitmapDescriptor origemLocation; //somente para o icone customizado
  BitmapDescriptor destinoLocation;

  BitmapDescriptor pinLocationIcon; //somente para o icone customizado
  BitmapDescriptor userLocationIcon; //imagem para o icone do user

  LatLng userLocationLatLng;

  Completer<GoogleMapController> _controller = Completer();

  bool _showAlertFinishMove=false;

  Location location = new Location();

  String truckerId;

  bool firstLoad=true;

  bool _showExpandedOptions=true;

  @override
  void initState() {

    //_getCurrentLocation();

    /*
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/markerico.png').then((onValue) {
      pinLocationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/markerico.png').then((value) {
      userLocationIcon = value;
    });

     */

  }

  @override
  Widget build(BuildContext context) {

    print('mapa move_day_page');

    moveClass = widget._moveClass;
    if(firstLoad==true){
      firstLoad=false;
      _setupIcons();
      _loadInitialData();
    }


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        truckerId=userModel.Uid;

        heightPercent = MediaQuery
            .of(context)
            .size
            .height;
        widthPercent = MediaQuery
            .of(context)
            .size
            .width;

        return Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: [

              //mapa e barra inferior
              Container(
                height: heightPercent,
                width: widthPercent,
                child: mapIsOk==true ? _googleMap(heightPercent*0.55) : Container(height: heightPercent, color: Colors.white ,child: Center(child: CircularProgressIndicator(),),),
              ),

              //barra inferior
              Positioned(
                top: _showExpandedOptions==true ? heightPercent*0.60 : heightPercent*0.80,
                bottom: 0.0,
                left: widthPercent*0.05,
                right: widthPercent*0.05,
                child: _bottomBar(),
              ),

              //opções laterais
              Positioned(
                top: heightPercent*0.20,
                right: 0.0,
                left: widthPercent*0.8,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: heightPercent*0.02,),

                      relatarProblemaBtn(),
                      Text('Relatar um problema', textAlign: TextAlign.center ,style: TextStyle(color: Colors.black,fontSize: ResponsiveFlutter.of(context).fontSize(1.3))),
                      SizedBox(height: heightPercent*0.02,),

                    ],
                  ),
                ),
              ),


              //fake app bar
              Positioned(
                top: 30.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  width: widthPercent,
                  height: heightPercent*0.10,

                  child: Row(
                    children: [

                      Column(
                        children: [
                          IconButton(icon: Icon(Icons.keyboard_arrow_left, size: 45.0, color: CustomColors.blue,), onPressed: (){
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => HomePage()));
                          }),
                          Text('Início', textAlign: TextAlign.center ,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(1.2))),
                        ],
                      ),
                      SizedBox(width: widthPercent*0.03,),
                      Container(
                        width: widthPercent*0.70,
                        child:Text('Acompanhe sua mudança', textAlign: TextAlign.center ,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
                      ),

                    ],
                  ),
                ),
              ),

              _showAlertFinishMove==true
                  ? _confirmFinishMovePopup()
                  : Container(),

            ],
          ),

        );
      },
    );
  }



  //primeiros meths na ordem
  void _setupIcons(){


    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/map/markerorigem.png').then((onValue) {
      origemLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/map/markerdestino.png').then((onValue) {
      destinoLocation = onValue;
    });

  }

  Future<void> _loadInitialData(){
    _initialcameraposition = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _origemPos = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _destinyPos = LatLng(moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);

    setState(() {
      mapIsOk=true;
    });

    _saveLastKnownPositionInFb();

    //_addMarkerOrigem();
    //_addMarkerDestino();

  }




  void _saveLastKnownPositionInFb() {

    Future.delayed(Duration(seconds: 90)).whenComplete(() async {

      await location.getLocation().then((LocationData currentLocation) {
        userLocationLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
      });

      //markers.removeWhere((item) => item.markerId.value == 'user');
      markers.removeWhere((item) => item.markerId.value == 'origem');
      markers.removeWhere((item) => item.markerId.value == 'destino');

      //save position to firebase so user can track
      FirestoreServices().saveLastUserLocation(truckerId, userLocationLatLng.latitude, userLocationLatLng.longitude);

      _saveLastKnownPositionInFb();
    });

  }

  void _addMarkerUser(){

    markers.add(
      Marker(
        markerId: MarkerId('user'),
        position: userLocationLatLng,
        icon: userLocationIcon,
        infoWindow: InfoWindow(
            title: "Você"),
      ),
    );

    setState(() {
      markers = markers;
    });

  }

  void _addMarkerOrigem(){

    markers.add(
      Marker(
        markerId: MarkerId('Endereço origem'),
        position: _origemPos,
        icon: origemLocation,
        infoWindow: InfoWindow(
            title: "Origem"),
      ),
    );

    setState(() {

    });
  }

  void _addMarkerDestino(){

    markers.add(
      Marker(
        markerId: MarkerId('Endereço destino'),
        position: _destinyPos,
        icon: destinoLocation,
        infoWindow: InfoWindow(
            title: "Destino"),
      ),
    );

  }



  _goBack(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
  }



  //Widgets
  Widget _googleMap(double heightSelected){
    return Container(
      height: heightSelected,
      child: GoogleMap(
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        markers: markers,
        initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 12.0,),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);

          await location.getLocation().then((LocationData currentLocation) {
            userLocationLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
          });


          setState(() {

            //_addMarkerUser();

            _addMarkerOrigem();

            _addMarkerDestino();

          });

        },


      ),
    );
  }

  Widget _bottomBar() {

    return Container(
      decoration: WidgetsConstructor().myBoxDecoration(_showExpandedOptions==true ? Colors.white : Colors.transparent, Colors.transparent, 0.0, 7.0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        child: Column(
          children: [
            //botao que expande ou diminui
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: Icon(_showExpandedOptions==true ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded, color: CustomColors.blue, size: 60,), onPressed: (){
                  setState(() {
                    _showExpandedOptions=!_showExpandedOptions;
                  });
                })
              ],
            ),

            SizedBox(height: heightPercent*0.02,),
            _showExpandedOptions==true ? WidgetsConstructor().makeText("Origem: ", Colors.blue, 15.0, 0.0, 2.0, null) : Container(),
            _showExpandedOptions==true ? Container(
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ) : Container(),
            _showExpandedOptions==true ? WidgetsConstructor().makeText("Destino: ", Colors.blue, 15.0, 0.0, 2.0, null) : Container(),
            _showExpandedOptions==true ? Container(
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoDestino, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ) : Container(),
            SizedBox(height: 5.0,),
            Container(
              height: heightPercent*0.08,
              width: widthPercent*0.85,
              child: RaisedButton(
                color: Colors.redAccent,
                onPressed: (){
                  setState(() {
                    _showAlertFinishMove=true;
                  });
                },
                child: Text('A mudança acabou?', textAlign: TextAlign.center ,style: TextStyle(color: Colors.white,fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
              ),
            ),

          ],
        ),
      ),
    );

  }

  Widget relatarProblemaBtn(){

    return FloatingActionButton(
        backgroundColor: CustomColors.brown,
        child: Icon(Icons.report_problem, color: Colors.white,),
        onPressed: (){
          _displaySnackBar(context, "Este serviço ainda não está disponível nesta plataforma");
        }
    );

  }

  Widget finalizarSmallBtn(){

    return FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.check, color: Colors.white,),
        onPressed: (){
          setState(() {
            _showAlertFinishMove=true;
          });
        }
    );

  }

  Widget _confirmFinishMovePopup(){


    void _onSucessFinish(){
      _displaySnackBar(context, 'Pronto! Preparando avaliação');

      Future.delayed(Duration(seconds: 2)).whenComplete(() {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => AvaliationPage(moveClass)));
      });
    }

    void _onFailFinish(){
      _displaySnackBar(context, "Ocorreu um erro. Verifique sua internet e tente novamente");
    }

    return GestureDetector(
      onTap: (){
        setState(() {
          _showAlertFinishMove=false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.75),
        height: heightPercent,
        width: widthPercent,
        child: Center(
          child: Container(
            width: widthPercent*0.8,
            height: heightPercent*0.55,
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.white, 3.0, 10.0),
            child: Column(
              children: [
                //close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: () {
                        setState(() {
                          _showAlertFinishMove=false;
                        });
                      },
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    height: heightPercent*0.20,
                    width: widthPercent*0.3,
                    child: Image.asset('images/popup/alert.png', fit: BoxFit.contain,),
                  ),
                ),
                Text('Encerrar a mudança e avaliar o cliente?', textAlign: TextAlign.center ,style: TextStyle(color: CustomColors.blue,fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
                SizedBox(height: heightPercent*0.05,),
                Container(
                  height: heightPercent*0.10,
                  width: widthPercent*0.75,
                  child: RaisedButton(
                    color: CustomColors.yellow,
                    onPressed: (){

                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => AvaliationPage(moveClass)));


                    },
                    child: Text('Finalizar e avaliar', textAlign: TextAlign.center ,style: TextStyle(color: Colors.white,fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),

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







/* versao funcionando mas feia
class MoveDayPage extends StatefulWidget {
  MoveClass _moveClass = MoveClass();

  MoveDayPage(this._moveClass);

  @override
  _MoveDayPageState createState() => _MoveDayPageState();
}

typedef Marker MarkerUpdateAction(Marker marker); //pra q serve?


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class _MoveDayPageState extends State<MoveDayPage> {

  bool shoudLoadIt=true;

  //https://codelabs.developers.google.com/codelabs/google-maps-in-flutter#3

  double heightPercent;
  double widthPercent;

  GoogleMapController mapController;

  MoveClass moveClass = MoveClass();

  //final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _initialcameraposition;
  LatLng _origemPos;
  LatLng _destinyPos;

  Set<Marker> markers = {};
  BitmapDescriptor origemLocation; //somente para o icone customizado
  BitmapDescriptor destinoLocation;

  BitmapDescriptor pinLocationIcon; //somente para o icone customizado
  BitmapDescriptor userLocationIcon; //imagem para o icone do user

  LatLng userLocationLatLng;

  Completer<GoogleMapController> _controller = Completer();

  bool _showAlertFinishMove=false;

  Location location = new Location();

  String truckerId;

  bool firstLoad=true;

  @override
  void initState() {

    //_getCurrentLocation();
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerOrigem.png').then((onValue) {
      origemLocation = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/maps/markerdestino.png').then((onValue) {
      destinoLocation = onValue;
    });

    /*
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/markerico.png').then((onValue) {
      pinLocationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/markerico.png').then((value) {
      userLocationIcon = value;
    });

     */

  }

  @override
  Widget build(BuildContext context) {

    print('mapa move_day_page');

    moveClass = widget._moveClass;
    if(firstLoad==true){
        //firstLoad=false;
      _loadInitialData();
    }


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        truckerId=userModel.Uid;

        heightPercent = MediaQuery
            .of(context)
            .size
            .height;
        widthPercent = MediaQuery
            .of(context)
            .size
            .width;

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

            title: Text('Mapa'), centerTitle: true,
          ),

          body: Stack(
            children: [

              Column(
                children: [

                  _googleMap(heightPercent*0.55),

                  _bottomBar(),


                ],
              ),

              _showAlertFinishMove==true
                  ? _confirmFinishMovePopup()
                  : Container(),

            ],
          ),

          /*
          body: GoogleMap(
            myLocationEnabled: true,
            markers: markers,
            initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 15.0,),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);

              setState(() {

                /*
                _location.onLocationChanged.listen((userPos) {
                  userLocationLatLng = LatLng(userPos.latitude, userPos.longitude);


                  /*
                  markers.add(
                    Marker(
                      markerId: MarkerId('user'),
                      position: LatLng(userLocationLatLng.latitude, userLocationLatLng.longitude),
                      icon: userLocationIcon,
                    ),
                  );

                  markers.add(
                    Marker(
                      markerId: MarkerId('origem'),
                      position: _origemPos,
                      icon: pinLocationIcon,
                    ),
                  );

                  markers.add(
                    Marker(
                      markerId: MarkerId('destino'),
                      position: _destinyPos,
                      icon: pinLocationIcon,
                    ),
                  );

                   */


                  /*
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(userPos.latitude, userPos.longitude), zoom: 12.0),
                    ),
                  );

                   */
                });

                 */



                markers.add(
                  Marker(
                    markerId: MarkerId('origem'),
                    position: _origemPos,
                    icon: pinLocationIcon,
                  ),
                );

                markers.add(
                  Marker(
                    markerId: MarkerId('destino'),
                    position: _destinyPos,
                    icon: pinLocationIcon,
                  ),
                );

              });
            },


          ),

           */

          /*
          body: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialcameraposition,
              zoom: 15.0,
            ),
            markers: _markers.values.toSet(),
          ),
           */

          /*
    body: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: LatLng(40.730610, -73.935242), zoom: 14.0)
          ),
           */
        );
      },
    );
  }




  void _saveLastKnownPositionInFb() {

    Future.delayed(Duration(seconds: 90)).whenComplete(() async {

      await location.getLocation().then((LocationData currentLocation) {
        userLocationLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
      });

      markers.removeWhere((item) => item.markerId.value == 'user');
      markers.removeWhere((item) => item.markerId.value == 'origem');
      markers.removeWhere((item) => item.markerId.value == 'destino');
      setState(() {
        _addMarkerUser();
        _addMarkerOrigem();
        _addMarkerDestino();
      });

      //save position to firebase
      FirestoreServices().saveLastUserLocation(truckerId, userLocationLatLng.latitude, userLocationLatLng.longitude);

      _saveLastKnownPositionInFb();
    });

  }

  void _addMarkerUser(){

    markers.add(
      Marker(
        markerId: MarkerId('user'),
        position: userLocationLatLng,
        icon: userLocationIcon,
        infoWindow: InfoWindow(
            title: "Você"),
      ),
    );

    setState(() {
      markers = markers;
    });

  }

  void _addMarkerOrigem(){

    markers.add(
      Marker(
        markerId: MarkerId('origem'),
        position: _origemPos,
        icon: pinLocationIcon,
        infoWindow: InfoWindow(
            title: "Origem"),
      ),
    );

  }

  void _addMarkerDestino(){

    markers.add(
      Marker(
        markerId: MarkerId('destino'),
        position: _destinyPos,
        icon: pinLocationIcon,
        infoWindow: InfoWindow(
            title: "Destino"),
      ),
    );

  }

  void _loadInitialData(){
    _initialcameraposition = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _origemPos = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _destinyPos = LatLng(moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);
  }

  _goBack(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
  }



  //Widgets
  Widget _googleMap(double heightSelected){
    return Container(
      height: heightSelected,
      child: GoogleMap(
        myLocationEnabled: true,
        markers: markers,
        initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 12.0,),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);

          await location.getLocation().then((LocationData currentLocation) {
            userLocationLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
          });


          setState(() {

            //_addMarkerUser();

            _addMarkerOrigem();

            _addMarkerDestino();

          });

          _saveLastKnownPositionInFb();
        },


      ),
    );
  }

  Widget _bottomBar() {

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        child: Column(
          children: [
            WidgetsConstructor().makeText("Origem: ", Colors.blue, 15.0, 0.0, 2.0, null),
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 5.0),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ),
            WidgetsConstructor().makeText("Destino: ", Colors.blue, 15.0, 0.0, 2.0, null),
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 5.0),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoDestino, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ),
            SizedBox(height: 5.0,),
            GestureDetector(
              onTap: (){
                setState(() {
                  _showAlertFinishMove=true;
                });
              },
              child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.85, heightPercent*0.08, 2.0, 4.0, "Finalizar mudança", Colors.white, 17.0),
            ),

          ],
        ),
      ),
    );

  }

  Widget _confirmFinishMovePopup(){


    void _onSucessFinish(){
      _displaySnackBar(context, 'Pronto! Preparando avaliação');

      Future.delayed(Duration(seconds: 2)).whenComplete(() {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => AvaliationPage(moveClass)));
      });
    }

    void _onFailFinish(){
      _displaySnackBar(context, "Ocorreu um erro. Verifique sua internet e tente novamente");
    }

    return GestureDetector(
      onTap: (){
        setState(() {
          _showAlertFinishMove=false;
        });
      },
      child: Container(
        height: heightPercent,
        width: widthPercent,
        child: Center(
          child: Container(
            width: widthPercent*0.8,
            height: heightPercent*0.6,
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0),
            child: Column(
              children: [
                //close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: () {
                        setState(() {
                          _showAlertFinishMove=false;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 80.0,),
                WidgetsConstructor().makeText("Você tem certeza que deseja encerrar esta mudança e avaliar o cliente?", Colors.blue, 18.0, 0.0, 20.0, 'center'),
                GestureDetector(
                  onTap: (){

                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => AvaliationPage(moveClass)));



                    /*
                    void _onSucess(){
                      if(moveClass.situacao=='user_finished'){
                        //pode apagar
                        FirestoreServices().FinishAmove(moveClass); //aqui apaga e cria um histórico
                      } else {
                        FirestoreServices().updateMoveSituationTruckerQuit('trucker_finished',truckerId ,moveClass, () {_onSucessFinish();}, () {_onFailFinish();});
                      }

                    }

                    void _onFail(){

                      _displaySnackBar(context, "Ops, ocorreu um erro");
                      setState(() {
                        isLoading=false;
                      });
                    }

                    //carrega situação atual
                    FirestoreServices().loadMoveSituation(moveClass, () {_onSucess();}, () { _onFail();});


                     */
                  },
                  child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.5, 60.0, 2.0, 4.0, 'Finalizar', Colors.white, 18.0),
                )
              ],
            ),
          ),
        ),
      ),

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


 */


/*
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class MoveDayPage extends StatefulWidget {
  MoveClass _moveClass = MoveClass();

  MoveDayPage(this._moveClass);

  @override
  _MoveDayPageState createState() => _MoveDayPageState();
}

typedef Marker MarkerUpdateAction(Marker marker); //pra q serve?


final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class _MoveDayPageState extends State<MoveDayPage> {

  /*
  List<Marker> myMarker = [];

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

   */
  bool shoudLoadIt=true;

  //https://codelabs.developers.google.com/codelabs/google-maps-in-flutter#3

  double heightPercent;
  double widthPercent;

  GoogleMapController mapController;

  MoveClass moveClass = MoveClass();

  //final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _initialcameraposition;
  LatLng _origemPos;
  LatLng _destinyPos;

  final Map<String, Marker> _markers = {};

  Set<Marker> markers = {};

  BitmapDescriptor pinLocationIcon; //somente para o icone customizado
  BitmapDescriptor userLocationIcon; //imagem para o icone do user

  LatLng userLocationLatLng;

  Completer<GoogleMapController> _controller = Completer();

  //https://medium.com/flutter-community/ad-custom-marker-images-for-your-google-maps-in-flutter-68ce627107fc   <<<custom marker

  //https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6
  //posicao do user

  Position position;

  bool _showAlertFinishMove=false;

  bool _isGettingUserPositionInProcess=false;
  bool _isFirstBuild=true;

  @override
  void initState() {

    _getCurrentLocation();

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/markerico.png').then((onValue) {
      pinLocationIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      //'images/carrinhobaby.jpg').then((value) {  //usar a imagem correta
        'images/markerico.png').then((value) {
        userLocationIcon = value;
    });

  }

  @override
  Widget build(BuildContext context) {

    moveClass = widget._moveClass;
    _loadInitialData();

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        heightPercent = MediaQuery
            .of(context)
            .size
            .height;
        widthPercent = MediaQuery
            .of(context)
            .size
            .width;

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

            title: Text('Mapa'), centerTitle: true,
          ),

          body: Stack(
            children: [

              Column(
                children: [

                  _googleMap(heightPercent*0.55),

                  _bottomBar(),


                ],
              ),

              _showAlertFinishMove==true
              ? _confirmFinishMovePopup()
              : Container(),

            ],
          ),

          /*
          body: GoogleMap(
            myLocationEnabled: true,
            markers: markers,
            initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 15.0,),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);

              setState(() {

                /*
                _location.onLocationChanged.listen((userPos) {
                  userLocationLatLng = LatLng(userPos.latitude, userPos.longitude);


                  /*
                  markers.add(
                    Marker(
                      markerId: MarkerId('user'),
                      position: LatLng(userLocationLatLng.latitude, userLocationLatLng.longitude),
                      icon: userLocationIcon,
                    ),
                  );

                  markers.add(
                    Marker(
                      markerId: MarkerId('origem'),
                      position: _origemPos,
                      icon: pinLocationIcon,
                    ),
                  );

                  markers.add(
                    Marker(
                      markerId: MarkerId('destino'),
                      position: _destinyPos,
                      icon: pinLocationIcon,
                    ),
                  );

                   */


                  /*
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: LatLng(userPos.latitude, userPos.longitude), zoom: 12.0),
                    ),
                  );

                   */
                });

                 */



                markers.add(
                  Marker(
                    markerId: MarkerId('origem'),
                    position: _origemPos,
                    icon: pinLocationIcon,
                  ),
                );

                markers.add(
                  Marker(
                    markerId: MarkerId('destino'),
                    position: _destinyPos,
                    icon: pinLocationIcon,
                  ),
                );

              });
            },


          ),

           */

          /*
          body: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialcameraposition,
              zoom: 15.0,
            ),
            markers: _markers.values.toSet(),
          ),
           */

          /*
    body: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: LatLng(40.730610, -73.935242), zoom: 14.0)
          ),
           */
        );
      },
    );
  }



  void _getCurrentLocation() async {

    if(_isFirstBuild==true){
      _isFirstBuild=false;

      await Geolocator.getCurrentPosition().then((value) => {
        position = value
      }).whenComplete(() {

        userLocationLatLng = LatLng(position.latitude, position.longitude);

        //markers.removeWhere((item) => item.markerId.value == 'user');

        _addMarkerUser();

        _updateUserLocationInfinite();

      });

    }

  }

  //atualiza a posição do user a cada 90 seg
  void _updateUserLocationInfinite() async {

    if(_isGettingUserPositionInProcess==false){
      _isGettingUserPositionInProcess=true;

      //agora atualizar a posição no mapa
      Future.delayed(Duration(seconds: 20)).then((_) async {

        await Geolocator.getCurrentPosition().then((value) => {
          position = value
        }).whenComplete(() {

          LatLng lastUserLocation = userLocationLatLng;
          userLocationLatLng = LatLng(position.latitude, position.longitude);

          if(lastUserLocation.latitude == userLocationLatLng.latitude && lastUserLocation.longitude == userLocationLatLng.longitude){
            //do nothing. Significa que o user nao saiu do lugar, então nao mexer nem alterar nada
          } else {
           // markers.removeWhere((item) => item.markerId.value == 'user');

            markers.clear();

            _addMarkerUser();
            _addMarkerDestino();
            _addMarkerOrigem();

            FirestoreServices().saveLastUserLocation(moveClass.idPedido, userLocationLatLng.latitude, userLocationLatLng.longitude);
          }

          Future.delayed(Duration(seconds: 20)).whenComplete(() {

            _isGettingUserPositionInProcess=false;
            _updateUserLocationInfinite(); //call

          });


        });

      });


    }


  }

  void _addMarkerUser(){

    markers.add(
      Marker(
        markerId: MarkerId('user'),
        position: userLocationLatLng,
        icon: userLocationIcon,
      ),
    );

    setState(() {
      markers = markers;
    });

  }

  void _addMarkerOrigem(){

    markers.add(
      Marker(
        markerId: MarkerId('origem'),
        position: _origemPos,
        icon: pinLocationIcon,
      ),
    );

  }

  void _addMarkerDestino(){

    markers.add(
      Marker(
        markerId: MarkerId('destino'),
        position: _destinyPos,
        icon: pinLocationIcon,
      ),
    );

  }

  void _loadInitialData(){
    _initialcameraposition = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _origemPos = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _destinyPos = LatLng(moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);
  }

  _goBack(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HomePage()));
  }



  //Widgets
  Widget _googleMap(double heightSelected){
    return Container(
      height: heightSelected,
      child: GoogleMap(
        myLocationEnabled: true,
        markers: markers,
        initialCameraPosition: CameraPosition(target: _initialcameraposition, zoom: 15.0,),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);

          setState(() {

            _addMarkerOrigem();

            _addMarkerDestino();

          });
        },


      ),
    );
  }
  
  Widget _bottomBar() {
    
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        child: Column(
          children: [
            WidgetsConstructor().makeText("Origem: ", Colors.blue, 15.0, 0.0, 2.0, null),
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 5.0),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoOrigem, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ),
            WidgetsConstructor().makeText("Destino: ", Colors.blue, 15.0, 0.0, 2.0, null),
            Container(
              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 5.0),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: WidgetsConstructor().makeText(moveClass.enderecoDestino, Colors.black, 15.0, 0.0, 0.0, null),
              ),
            ),
            SizedBox(height: 5.0,),
            GestureDetector(
              onTap: (){
                setState(() {
                  _showAlertFinishMove=true;
                });
              },
              child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.85, heightPercent*0.08, 2.0, 4.0, "Finalizar mudança", Colors.white, 17.0),
            ),

          ],
        ),
      ),
    );
    
  }

  Widget _confirmFinishMovePopup(){

    return GestureDetector(
      onTap: (){
        setState(() {
          _showAlertFinishMove=false;
        });
      },
      child: Container(
        height: heightPercent,
        width: widthPercent,
        child: Center(
          child: Container(
            width: widthPercent*0.8,
            height: heightPercent*0.6,
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 3.0, 4.0),
            child: Column(
              children: [
                //close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CloseButton(
                      onPressed: () {
                        setState(() {
                          _showAlertFinishMove=false;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 80.0,),
                WidgetsConstructor().makeText("Você tem certeza que deseja encerrar esta mudança e avaliar o cliente?", Colors.blue, 18.0, 0.0, 20.0, 'center'),
                GestureDetector(
                  onTap: (){
                    print('click do botão');
                  },
                  child: WidgetsConstructor().makeButton(Colors.blue, Colors.white, widthPercent*0.5, 60.0, 2.0, 4.0, 'Finalizar', Colors.white, 18.0),
                )
              ],
            ),
          ),
        ),
      ),

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


 */