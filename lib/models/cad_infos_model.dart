import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:scoped_model/scoped_model.dart';

class CadInfosModel extends Model {

  //variaveis compartilhadas entre páginas
  bool firstLoad=true;
  bool _isLoading=false;
  bool _initialLoadIsDone=false;
  File _imageFile;
  int _page;

  //variaveis da pgina 1 (truckerInfosCad)
  String _apelido;
  String _phone;
  String _address;
  String _addressFound;
  String _image;
  double _latlong;
  final TextEditingController apelidoController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();


  //variaveis da página2
  File _imageCnh;
  bool _alreadySentCnh=false;


  //variaveis da página 3
  String _vehicle;
  String _vehicleImageUrl; //este é o url depois de fazer upload
  File _imageVehicle; //este é o arquivo de imagem
  String _placa;
  final TextEditingController placaController = TextEditingController();
  String _placaExibicao='';

  //variaveis da págona 4
  TextEditingController nameController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  TextEditingController digitController = TextEditingController();
  TextEditingController agencyController = TextEditingController();
  TextEditingController otherBankController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();

  String acountType='cc';
  String bank;
  String cpfOrCnpj='cpf';


  //metodos da página 4
  void updateAcountType(String value){
    acountType = value;
    notifyListeners();
  }
  get AcountType=>acountType;

  void updateBank(String value){
    bank = value;
    notifyListeners();
  }
  get Bank=>bank;

  void updateCpfOrCnpj(String value){
    cpfOrCnpj=value;
    notifyListeners();
  }
  get CpfOrCnpj=>cpfOrCnpj;


  //metodos das páginas 2
  void updatePageClearChache(int value){
    _page=value;
    if(_page==1){
      firstLoad=true;
      _isLoading=false;
      _imageFile=null;
      _initialLoadIsDone=false;
    } else if(_page==2){
      //2 é a pagina do cnh
      firstLoad=true;
      _isLoading=false;
      _imageFile=null;
      _initialLoadIsDone=false;
      _imageCnh=null;
      _alreadySentCnh=false;
    } else if(_page==3){
      //aqui é a pagina do carro
    } else if(_page==4){
      //aqui é a pagina 4 do banco
      firstLoad=true;
      _isLoading=false;
      _initialLoadIsDone=false;
    }
    notifyListeners();
  }

  void updateImageCnh(File value){
    _imageCnh = value;
    notifyListeners();
  }
  get imageCnh=>_imageCnh;

  void updateAlreadySentCnh(bool value){
    _alreadySentCnh=value;
    notifyListeners();
  }
  get alreadySentCnh=>_alreadySentCnh;


  void updateInitialLoadIsDone(bool value){
    _initialLoadIsDone = value;
    notifyListeners();
  }
  get initialLoadIsDone=>_initialLoadIsDone;

  void updateApelido(String value){
    _apelido = value;
    notifyListeners();
  }
  get apelido=>_apelido;

  void updatephone(String value){
    _phone = value;
    notifyListeners();
  }
  get phone=>_phone;

  void updateaddress(String value){
    _address = value;
    notifyListeners();
  }
  get address=>_address;

  void updateaddressFound(String value){
    _addressFound = value;
    notifyListeners();
  }
  get addressFound=>_addressFound;

  void updateimage(String value){
    _image = value;
    notifyListeners();
  }
  get image=>_image;

  void updateLatLong(double value){
    _latlong = value;
    notifyListeners();
  }
  get latlong=>_latlong;

  void updateIsLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }
  get isLoading=>_isLoading;

  void updateApelidoController(String value){
    apelidoController.text = value;
    notifyListeners();
  }
  get apelidoControllerText=>apelidoController.text;

  void updatePhoneController(String value){
    phoneController.text = value;
    notifyListeners();
  }
  get phoneControllerText=>phoneController.text;

  void updateAddressController(String value){
    addressController.text = value;
    notifyListeners();
  }
  get addressControllerText=>addressController.text;

  void updateImageFile(File value){
    _imageFile = value;
    notifyListeners();
  }
  get imageFile=>_imageFile;


  //metodos da pagina 3

  void updateVehicle(String value){
    _vehicle = value;
    notifyListeners();
  }
  get vehicle=>_vehicle;

  void updateVehicleImageUrl(String value){
    _vehicleImageUrl=value;
    notifyListeners();
  }
  get vehicleImageUrl=>_vehicleImageUrl;

  void updateImageVehicle(File value){
    _imageVehicle = value;
    notifyListeners();
  }
  get imageVehicle=>_imageVehicle;

  void updatePlaca(String value){
    _placa = value;
    notifyListeners();
  }
  get placa=>_placa;

  void updatePlacaController(String value){
    placaController.text = value;
    notifyListeners();
  }
  get placaControllerText=>placaController.text;

  void updatePlacaExibicao(String value){
    _placaExibicao = value;
    notifyListeners();
  }
  get placaExibicao=>_placaExibicao;

}
