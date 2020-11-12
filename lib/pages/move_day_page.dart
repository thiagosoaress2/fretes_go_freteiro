import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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

  GoogleMapController mapController;

  MoveClass moveClass = MoveClass();

  //final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng _initialcameraposition;
  LatLng _origemPos;
  LatLng _destinyPos;

  final Map<String, Marker> _markers = {};

  Set<Marker> markers = {};

  Location _location = Location();

  BitmapDescriptor pinLocationIcon; //somente para o icone customizado
  //BitmapDescriptor userLocationIcon;

  LatLng userLocationLatLng;

  Completer<GoogleMapController> _controller = Completer();

  //https://medium.com/flutter-community/ad-custom-marker-images-for-your-google-maps-in-flutter-68ce627107fc   <<<custom marker

  //https://levelup.gitconnected.com/how-to-add-google-maps-in-a-flutter-app-and-get-the-current-location-of-the-user-dynamically-2172f0be53f6
  //posicao do user

  Position position;

  @override
  void initState() {

    _getCurrentLocation();

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'images/markerico.png').then((onValue) {
      pinLocationIcon = onValue;
    });

    /*
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'images/carrinhobaby.jpg').then((value) {
        userLocationIcon = value;
    });
     */
  }

  void _getCurrentLocation() async {
    await Geolocator.getCurrentPosition().then((value) => {
      position = value
    }).whenComplete(() {
      userLocationLatLng = LatLng(position.latitude, position.longitude);
      _addMaker2("user", userLocationLatLng);
    });


  }

  void _addMaker2(String markerId, LatLng position){
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        icon: pinLocationIcon,
      ),
    );
  }






  Future<void> _onMapCreated(GoogleMapController controller) async {
    //final googleOffices = await locations.getGoogleOffices();

    print(moveClass);
    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId(moveClass.idPedido), //endereco origem
        position: LatLng(-22.858635, -43.100542),
        infoWindow: InfoWindow(
          title: "Endereço origem",
          snippet: moveClass.enderecoOrigem,
        ),
      );
      _markers[moveClass.userId] = marker;
    });
  }

  void _addMarker(String markerId, double lat, double long, String title, String snippet){
    _markers.clear();
    final marker = Marker(
      markerId: MarkerId(markerId), //endereco origem
      position: LatLng(lat, long),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );
    _markers[moveClass.userId] = marker;
  }




  @override
  Widget build(BuildContext context) {

    print(widget._moveClass.userId);
    moveClass = widget._moveClass;
    _initialcameraposition = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _origemPos = LatLng(moveClass.latEnderecoOrigem, moveClass.longEnderecoOrigem);
    _destinyPos = LatLng(moveClass.latEnderecoDestino, moveClass.longEnderecoDestino);

    print('entrou em move_day_page');


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(

            title: Text('Mapa'), centerTitle: true,
          ),
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


  void _placeMarkers(){

    print(moveClass.freteiroId);

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
