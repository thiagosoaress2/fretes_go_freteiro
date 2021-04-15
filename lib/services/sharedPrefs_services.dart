import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsServices {

  Future<void> saveApelido (String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apelido', value); //salva
  }

  Future<String> loadApelido () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = (prefs.getString('apelido') ?? '');
    return value;//recupera
  }


}