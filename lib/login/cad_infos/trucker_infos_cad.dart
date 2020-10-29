import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_from_cnh_page.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_page.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'file:///C:/Users/Thiago/flutterProjectsII/fretes_go_freteiro/lib/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';


//base that works
//https://walkingtree.tech/flutter-plugins-implementing-camera-pictures-video/?unapproved=1182&moderation-hash=2bd620ea5ae028e6bfcea9b9aa18b1e8#comment-1182


//pagina 1 é esta - infos pessoais
//pagina 2 é trucker_infos_cad_info_profs - info profissional como a cnh
//pagina 3 é trucker_infos_cad_car_info - infos do carro (foto, placa)

class TruckerInfosCadUserInfo extends StatefulWidget {
  @override
  _TruckerInfosCadUserInfoState createState() => _TruckerInfosCadUserInfoState();
}

class _TruckerInfosCadUserInfoState extends State<TruckerInfosCadUserInfo> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  List<File> attachmentList = [];
  File _imageProfile;
  String _uploadedImageProfileFileURL;



  TextEditingController _apelidoController = TextEditingController();
  var _maskFormatterPhone = new MaskTextInputFormatter(mask: '(##) ####-#####)', filter: { "#": RegExp(r'[0-9]') });
  final TextEditingController _phoneController = TextEditingController();
  TextEditingController _adressController = TextEditingController();

  String adressFound="";
  double latitude;
  double longitude;

  bool isLoading=false;

  UserModel userModelGlobal;




  @override
  Widget build(BuildContext context) {

    double heightPercent = MediaQuery.of(context).size.height;
    double widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        userModelGlobal = userModel;

        print("uid");
        print(userModel.Uid);
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(centerTitle: true, title: Text("Informações pessoais")),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(height: 25.0,),

                  WidgetsConstructor().makeText("Precisamos destas informações para você começar a aparecer para os clientes na nossa plataforma.", Colors.blue, 15.0, 0.0, 15.0, "center"),

                  WidgetsConstructor().makeEditText(_apelidoController, "Como quer aparecer no app? (nome ou apelido)", null),

                  WidgetsConstructor().makeEditTextForPhoneFormat(_phoneController, "Seu telefone com whatsapp", _maskFormatterPhone),

                  SizedBox(height: 15.0,),

                  //botão de ajuda sobre a info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //EditText  para o endereço
                      //btn de informação
                      Container(
                        width: widthPercent*0.15,
                        child: Container(
                          decoration: WidgetsConstructor().myBoxDecoration(Colors.blue, Colors.blue, 1.0, 3.0),
                          child: IconButton(icon: Icon(Icons.help_center, color: Colors.white,), onPressed: () {

                            Alert(
                              context: context,
                              type: AlertType.info,
                              title: "Endereço da sua base",
                              desc: "O endereço da sua base é o ponto onde seu veículo fica. É a partir deste endereço que você aparecerá ou não para os clientes que estejam buscando um profissional. ",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Ok",
                                    style: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  width: widthPercent*0.45,
                                )
                              ],
                            ).show();

                          },),
                        ),
                      )

                    ],
                  ),

                  //barra de busca do endereço
                  Row(
                    children: [

                      Container(
                        width: widthPercent*0.79,
                        child: WidgetsConstructor().makeEditText(_adressController, "Endereço que parte o veículo", null),
                      ),

                      //btn de busca do endereço
                      Container(
                        width: widthPercent*0.15,
                        child: Container(
                          decoration: WidgetsConstructor().myBoxDecoration(Colors.blue, Colors.blue, 1.0, 3.0),
                          child: IconButton(icon: Icon(Icons.help_center, color: Colors.white,), onPressed: () {

                            //fecha o teclado
                            FocusScopeNode currentFocus = FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              //remove o foco (isto fecha o teclado)
                              currentFocus.unfocus();
                            }

                            findAddress(_adressController);

                          },),
                        ),
                      )

                    ],
                  ),

                  //resumo do enderçeo encontrado
                  adressFound == "nao"
                      ? WidgetsConstructor().makeText("Sem endereço definido", Colors.redAccent, 14.0, 10.0, 0.0, null)
                      : adressFound != ""
                      ? WidgetsConstructor().makeText(adressFound, Colors.blue, 14.0, 10.0, 0.0, null)
                      : Container(),

                  isLoading == true
                      ? Center(child: CircularProgressIndicator())
                      : Container(),

                  WidgetsConstructor().makeText("Sua foto no app", Colors.blue, 17.0, 20.0, 10.0, "center"),

                  //linha com a foto do perfil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      GestureDetector(
                        onTap: (){
                          _settingModalBottomSheet(context, 1);
                        },
                        child: _imageProfile != null
                            ? Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: FileImage(_imageProfile), // picked file
                                  fit: BoxFit.fill)),
                        )
                            :
                        Image.asset("images/avatar.png", width: 150, height: 150,),
                      ),

                      SizedBox(width: widthPercent*0.05,),

                      GestureDetector(
                        child: Container(width: widthPercent*0.15, height: 50.0, color: Colors.blue,
                          child: Icon(Icons.camera_alt_outlined, color: Colors.white,),),
                        onTap: (){
                          _settingModalBottomSheet(context, 1);
                        },
                      ),

                      SizedBox(width: widthPercent*0.15,),
                    ],
                  ),

                  SizedBox(height: 50.0,),

                  GestureDetector(
                    onTap: (){

                      if(_apelidoController.text.isEmpty){
                        _displaySnackBar(context, "Informe o nome ou apelido que deseja usar.");
                      } else if(_phoneController.text.isEmpty){
                        _displaySnackBar(context, "Informe o telefone com whatsapp que deseja usar");
                      } else if(adressFound == "" || adressFound == "nao"){
                        _displaySnackBar(context, "Informe um endereço válido");
                      } else if(_imageProfile == null){
                        _displaySnackBar(context, "Precisamos de uma foto sua");
                      } else {
                        //salvar
                         save(userModel, latitude, longitude, _apelidoController.text, _phoneController.text,
                             adressFound);
                      }

                      //aqui precisa salvar as coisas no bd e shared
                      /*
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TruckerInfosCadInfoProfs()));

                   */
                    },
                    child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.75, 50.0, 2.0, 4.0, "Próximo", Colors.white, 16.0),
                  ),


                  SizedBox(height: 40.0,),


                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void save(UserModel userModel, double latitude, double longitude, String nome, String phone,
  String adressFound) async {

    setState(() {
      isLoading=true;
    });

    //salva a imagem
    String path = 'profile/${userModelGlobal.Uid.toString()}';

      StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(path);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageProfile);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then(
              (value) {

            _uploadedImageProfileFileURL = value;
            saveData(userModel.Uid, latitude, longitude, nome, phone,
                adressFound);


          });



    /*
    await FirestoreServices().saveUserInfo(userModel, latitude, longitude, _apelidoController.text, _phoneController.text,
        adressFound, () {_onSucess1(); }, () {_onFailure1(); });

     */

  }

  Future<void> saveData(String uid, double latitude, double longitude, String nome, String phone, String adressFound) async {

    await FirestoreServices().saveUserInfo(uid, latitude, longitude, _apelidoController.text, _phoneController.text,
        adressFound, _uploadedImageProfileFileURL, () {_onSucess1(); }, () {_onFailure1(); });
  }

  void _showCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    attachmentList.clear();

    final pickedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          //builder: (context) => TakePicturePage(camera: camera)));
            builder: (context) => TakePicturePage(camera: camera)));
    setState(() {

      attachmentList.add(File(pickedImage));
      _imageProfile = attachmentList.first;


      //uploadFile();
    });
    // return result;
  }

  void _removeImage(File pickedFile) {
    setState(() {
      attachmentList.remove(pickedFile);
    });
  }

  void findAddress(TextEditingController controller) async {

    setState(() {
      isLoading=true;
    });

    String addressInformed = controller.text;

      var addresses = await Geocoder.local.findAddressesFromQuery(addressInformed);
      var first = addresses.first;

      if(addresses.length>=1){
        /*
        setState(() async {
          adressFound = first.addressLine + " - " + first.adminArea;
        });

         */
        adressFound = first.addressLine + " - " + first.adminArea;
        //agora vamos pegar as coordenadas
        await getTheCoordinates(adressFound);

        //exibe uma popup informando que o endereço foi achado
        Alert(
          context: context,
          type: AlertType.success,
          title: "Encontramos!",
          desc: "O endereço foi definido com sucesso. ",
          buttons: [
            DialogButton(
              child: Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();

        setState(() {
          adressFound = adressFound;
          isLoading=false;
        });

      } else {

        setState(() {
          isLoading=false;
          adressFound = "nao";
        });

        _displaySnackBar(context, "Especifique melhor o endereço. Estamos encontrando multiplos resultados");
      }



  }

  Future getTheCoordinates(@required String addressOrigem) async {


    var addresses = await Geocoder.local.findAddressesFromQuery(addressOrigem);

    var first = addresses.first;
    latitude = first.coordinates.latitude;
    longitude = first.coordinates.longitude;

  }

  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER
        _imageProfile = await ImagePicker.pickImage(
            source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera": // CAMERA CAPTURE CODE

        _showCamera();
        break;
    }

    if (_imageProfile != null) {
      //print("You selected  image : " + imageFile.path);
      setState(() {
        //debugPrint("SELECTED IMAGE PICK   $imageFile");

      });
    } else {
      print("You have not taken image");
    }
  }

  void _settingModalBottomSheet(context, int option) {
    //if option 1 exibe as duas opções
    //if option 2 exibe apenas galeria
    //if option 3 exibe apenas camera
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 200,
            child: Column(
              children: [
                WidgetsConstructor().makeText("Selecione a origem da foto", Colors.blue, 17.0, 15.0, 20.0, "center"),
                new Wrap(
                  children: <Widget>[
                    option == 1 || option == 2 ?
                    new ListTile(
                        title: new Text('Gallery'),
                        onTap: () => {


                          imageSelector(context, "gallery"),
                          Navigator.pop(context),


                        }) : Container(),
                    option == 1 || option == 3 ?
                    new ListTile(
                      title: new Text('Camera'),
                      onTap: () => {

                        _removeImage(_imageProfile),
                        imageSelector(context, "camera"),
                        Navigator.pop(context)


                      },
                    ) : Container(),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _onSucess1(){

    //chamar salvamentos 2
    _displaySnackBar(context, "Pronto!");
    setState(() {
      isLoading=false;
    });
    //abrir a proxima pagina
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadInfoProfs()));

  }

  void _onFailure1(){
    //encerrar loading e indicar erro
    _displaySnackBar(context, "Ocorreu um erro. Nenhuma informação foi salva");
    setState(() {
      isLoading=false;
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

}



