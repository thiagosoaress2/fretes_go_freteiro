import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {

  Future<void> saveBasicInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('uid', userModel.Uid);
    await prefs.setString('email', userModel.Email);
    await prefs.setString('all_info_done', userModel.AllInfoIsDone);

  }

  Future<void> loadBasicInfoFromSharedPrefs(UserModel userModel) async {
    //MoveClass moveClass = MoveClass.empty();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String value = (prefs.getString('uid').toString());
    userModel.updateUid(value);
    value = (prefs.getString('email').toString());
    userModel.updateEmail(value);
    int value2 = (prefs.getInt('all_info_done'));
    userModel.updateAllInfoDone(value2);

  }

  Future<void> saveFireStoreInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('fullName', userModel.FullName);
    await prefs.setString('image', userModel.Image);
    await prefs.setString('apelido', userModel.Apelido);
    await prefs.setDouble('latlong', userModel.LatLong);

  }

  Future<void> savePageOneInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('image', userModel.Image);
    await prefs.setString('apelido', userModel.Apelido);
    await prefs.setDouble('latlong', userModel.LatLong);
    await prefs.setString('phone', userModel.Phone);
    await prefs.setString('address', userModel.Address);
    await prefs.setInt('all_info_done', 1);

  }

  //para testes apenas
  Future<void> deletePageOneInfo() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('all_info_done', 99);
    await prefs.remove("image");
    await prefs.remove("apelido");
    await prefs.remove("latlong");
    await prefs.remove("phone");
    await prefs.remove("address");


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

  //pagina 2 só tem a CNH. Como o user nunca vai precisa acessa-la, n vamos salvar no sharedprefs
  Future<void> savePageTwoInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('all_info_done', 2);

  }

  Future<void> savePageThreeInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('vehicle', userModel.Vehicle);
    await prefs.setString('vehicle_image', userModel.VehicleImage);
    await prefs.setString('vehicle_placa', userModel.Placa);
    await prefs.setInt('all_info_done', 3);

  }

  Future<void>loadPageThreeInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String value = (prefs.getString('vehicle').toString());
    userModel.updateVehicle(value);
    value = (prefs.getString('vehicle_image').toString());
    userModel.updateVehicleImage(value);
    value = (prefs.getString('vehicle_placa').toString());
    userModel.updatePlaca(value);
  }

  Future<void> saveAval(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('aval', userModel.Aval);

  }

  Future<String> getUid () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = (prefs.getString('uid'));
    print(uid);
    return uid;
  }

  Future<bool> thereIsBasicInfoSavedInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = 'nao';
    uid = (prefs.getString('uid'));
    if(uid==null){
      return false;
    } else {
      return true;
    }

  }

  Future<bool> thereIsFireStoreInfoSavedInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    double latlong;
    latlong = (prefs.getDouble('latlong'));
    if(latlong==null){
      return false;
    } else {
      return true;
    }

  }

  Future<int> checkIfAdditionalInfoIsDone() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int value = (prefs.getInt('all_info_done'));
    if(value!=null){
      return value;
    } else {
      return 99;
    }

  }

  Future<void> updateAllInfoDone(int value) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('all_info_done', value);

  }

  Future<void> clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }


}