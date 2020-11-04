import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {

  String _uid="";
  String _fullName="";
  String _email="";
  double _latLong=0.0;
  String _image="";
  String _apelido="";
  String _phone="";
  double _aval = 0.0;
  String _vehicle="";
  String _vehicle_image="";
  String _placa="";
  String _address="";
  bool _truckerInfoOk=false;
  int _allInfoIsDone=0;

  //UserModel({this.uid, this.fullName, this.email, this.userRole});
  //UserModel();

  void updateUid(String value) {
    _uid = value;
    notifyListeners();
  }

  get Uid=>_uid;

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  get Email=>_email;

  void updateFullName(String value) {
    _fullName = value;
    notifyListeners();
  }

  get FullName=>_fullName;

  void updateLatLoong(double value) {
    _latLong = value;
    notifyListeners();
  }

  get LatLong=>_latLong;

  void updateImage(String value) {
    _image = value;
    notifyListeners();
  }

  get Image=>_image;

  void updateApelido(String value) {
    _apelido = value;
    notifyListeners();
  }

  get Apelido=>_apelido;

  void updatePhone(String value) {
    _phone = value;
    notifyListeners();
  }

  get Phone=>_phone;

  void updateAval(double value) {
    _aval = value;
    notifyListeners();
  }

  get Aval=>_aval;

  void updateVehicle(String value) {
    _vehicle = value;
    notifyListeners();
  }

  get Vehicle=>_vehicle;

  void updateVehicleImage(String value) {
    _vehicle_image = value;
    notifyListeners();
  }

  get VehicleImage=>_vehicle_image;

  void updateAddress(String value) {
    _address = value;
    notifyListeners();
  }

  get Address=>_address;

  void updateTruckerInfoOk(bool value) {
    _truckerInfoOk = value;
    notifyListeners();
  }

  get TruckerInfoOk=>_truckerInfoOk;

  void updatePlaca(String value) {
    _placa = value;
    notifyListeners();
  }

  get Placa=>_placa;

  void updateAllInfoDone(int value) {
    _allInfoIsDone = value;
    notifyListeners();
  }

  get AllInfoIsDone=>_allInfoIsDone;

  void signOutFromClass(){
    _uid="";
    _fullName="";
    _email="";
    _image="";
    _latLong=0.0;
    _phone="";
    _apelido="";
    _aval=0.0;
    _vehicle="";
    _vehicle_image="";
    _placa="";
    _truckerInfoOk=false;
    _allInfoIsDone=0;
  }


  //esta função é para fazer o upload pro firestore em formato json
  Map<String, dynamic> toJson(){
    return {
      'uid': _uid,
      'fullName': _fullName,
      'email' : _email,
    };

  }

}
