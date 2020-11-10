import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class MoveDayPage extends StatefulWidget {
  @override
  _MoveDayPageState createState() => _MoveDayPageState();
}

typedef Marker MarkerUpdateAction(Marker marker); //pra q serve?

MoveClass _moveClass = MoveClass();

final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

class _MoveDayPageState extends State<MoveDayPage> {

  List<Marker> myMarker = [];

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  bool shoudLoadIt=true;


  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }


  @override
  Widget build(BuildContext context) {



    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        if(shoudLoadIt==true){
          shoudLoadIt=false;
          loadMoveClass(userModel);
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text('Mapa'),),
          body: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: LatLng(40.730610, -73.935242), zoom: 14.0)
          ),
        );
      },
    );
  }

  void loadMoveClass(UserModel userModel) async {

    FirestoreServices().loadMoveClass(userModel, _moveClass, () {_onFailLoadMoveClass();}).whenComplete(() => _placeMarkers());
  }

  void _onFailLoadMoveClass(){
    _displaySnackBar(context, "Ocorreu um erro ao carregar os dados");
  }

  void _placeMarkers(){

    print(_moveClass.freteiroId);

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
