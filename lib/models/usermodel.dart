import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {

  String _uid="";
  String _fullName="";
  String _email="";
  double _latLong=0.0;
  String _image="";
  String _apelido="";
  String _phone="";
  double _rate = 0.0;
  int _aval = 0;
  String _vehicle="";
  String _vehicle_image="";
  String _placa="";
  String _address="";
  bool _truckerInfoOk=false;
  int _allInfoIsDone=0;
  String _moveIdCanceled=''; //esta variavel é usada apenas no cancelamento na home_page para passar dados do firestoreservices para a página na volta
  String _moveGoingNow=''; //id da mudança acontecendo neste instante
  String _nameAcountOwner='';
  String _agency='';
  String _acount='';
  String _digit='';
  String _acountType='';
  String _bank='';
  String _cpfAcountOwner='';

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

  void updateRate(double value) {
    _rate = value;
    notifyListeners();
  }

  get Rate=>_rate;

  void updateVehicle(String value) {
    _vehicle = value;
    notifyListeners();
  }

  void updateAval(int value) {
    _aval = value;
    notifyListeners();
  }

  get Aval=>_aval;


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

  void updateMoveGoingNow(String value) {
    _moveGoingNow = value;
    notifyListeners();
  }

  get MoveGoingNow=>_moveGoingNow;

  void updateNameOwnerAcount(String value) {
    _nameAcountOwner = value;
    notifyListeners();
  }

  get NameAcountOwner=>_nameAcountOwner;

  void updateAgency(String value) {
    _agency = value;
    notifyListeners();
  }

  get Agency=>_agency;

  void updateAcount(String value) {
    _acount = value;
    notifyListeners();
  }

  get Acount=>_acount;

  void updateDigit(String value) {
    _digit = value;
    notifyListeners();
  }

  get Digit=>_digit;

  void updateAcountType(String value) {
    _acountType = value;
    notifyListeners();
  }

  get AcountType=>_acountType;

  void updateBank(String value) {
    _bank = value;
    notifyListeners();
  }

  get Bank=>_bank;

  void updateCpfAcountOwner(String value) {
    _cpfAcountOwner = value;
    notifyListeners();
  }

  get CpfAcountOwner=>_cpfAcountOwner;




  void signOutFromClass(){
    _uid="";
    _fullName="";
    _email="";
    _image="";
    _latLong=0.0;
    _phone="";
    _apelido="";
    _rate=0.0;
    _vehicle="";
    _vehicle_image="";
    _placa="";
    _truckerInfoOk=false;
    _allInfoIsDone=0;
    _moveIdCanceled='';
    _moveGoingNow='';
  }


  //esta função é para fazer o upload pro firestore em formato json
  Map<String, dynamic> toJson(){
    return {
      'uid': _uid,
      'fullName': _fullName,
      'email' : _email,
    };

  }


  void updateMoveIdCancelment(String value) { //esta variavel é usada apenas no cancelamento na home_page para passar dados do firestoreservices para a página na volta
    _moveIdCanceled = value;
    notifyListeners();
  }

  get MoveIdCancelment=>_moveIdCanceled;

}
