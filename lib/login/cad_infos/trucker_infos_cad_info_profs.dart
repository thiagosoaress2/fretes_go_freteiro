import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_from_cnh_page.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_page.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';

class TruckerInfosCadInfoProfs extends StatefulWidget {
  @override
  _TruckerInfosCadInfoProfsState createState() => _TruckerInfosCadInfoProfsState();
}

class _TruckerInfosCadInfoProfsState extends State<TruckerInfosCadInfoProfs> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  List<File> attachmentList = [];
  File _imageCnh;
  String _uploadedImageCnhFileURL;

  bool isLoading=false;


  @override
  Widget build(BuildContext context) {

    double heightPercent = MediaQuery.of(context).size.height;
    double widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(centerTitle: true, title: Text("Informações profissionais")),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(height: 25.0,),

                  WidgetsConstructor().makeText("Agora precisamos da sua CNH.", Colors.blue, 15.0, 0.0, 15.0, "center"),

                  //help btn
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
                              title: "Por que precisamos da sua CNH?",
                              desc: "É uma medida de segurança. Mantemos a identificação dos profissionais que trabalham conosco em sigilo. Os usuários não terão acesso a esta informação. ",
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

                  SizedBox(height: 25.0,),

                  //linha com foto da CNH
                  Row(
                      children:[

                        SizedBox(width: widthPercent*0.05,),
                        GestureDetector(
                          child: Container(

                              width: 150, height: 100,
                              child: _imageCnh == null
                                  ? Image.asset("images/cnhavatar.jpg", fit: BoxFit.fill)
                                  : Image.file(_imageCnh, fit: BoxFit.fill,)
                          ),
                          onTap: (){
                            _settingModalBottomSheet(context, 3);
                          },
                        ),
                        SizedBox(width: widthPercent*00.05,),
                        GestureDetector(
                          child: Container(width: widthPercent*0.15, height: 50.0, color: Colors.blue,
                            child: Icon(Icons.camera_alt_outlined, color: Colors.white,),),
                          onTap: (){
                            _settingModalBottomSheet(context, 3);
                          },
                        ),

                      ]
                  ),

                  SizedBox(height: 20.0,),

                  isLoading == true
                      ? Center(child: CircularProgressIndicator())
                      : Container(),

                  SizedBox(height: 20.0,),

                  GestureDetector(
                    onTap: (){

                      if(_imageCnh!=null){
                        save(userModel.Uid);
                      }

                      /*
                  //aqui precisa salvar as coisas no bd e shared
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TruckerInfosCadCarInfo()));
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

  void save(String uid) async {

    setState(() {
      isLoading=true;
    });

    //salva a imagem
    String path = 'cnh/${uid.toString()}';

    StorageReference firebaseStorageRef =
    FirebaseStorage.instance.ref().child(path);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageCnh);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then(
            (value) {

          _uploadedImageCnhFileURL = value;
          saveData(uid);


        });



    /*
    await FirestoreServices().saveUserInfo(userModel, latitude, longitude, _apelidoController.text, _phoneController.text,
        adressFound, () {_onSucess1(); }, () {_onFailure1(); });

     */

  }

  Future<void> saveData(String uid) async {

    await FirestoreServices().saveUserCNHinfo(uid, _uploadedImageCnhFileURL, () {_onSucess1(); }, () {_onFailure1(); });
  }

  void _onSucess1(){

    //chamar salvamentos 2
    _displaySnackBar(context, "CNH salva");
    setState(() {
      isLoading=false;
    });
    //abrir a proxima pagina
    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadCarInfo()));

  }

  void _onFailure1(){
    //encerrar loading e indicar erro
    _displaySnackBar(context, "Ocorreu um erro. A informação não foi salva");
    setState(() {
      isLoading=false;
    });
  }

  void _showCamera() async {

    setState(() {
      attachmentList.clear();
    });

    final cameras = await availableCameras();
    final camera = cameras.first;

    final pickedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicturePage(camera: camera)));
            //builder: (context) => TakePictureFromCnh(camera: camera)));
    setState(() {
      attachmentList.add(File(pickedImage));
      _imageCnh = attachmentList.first;


      //uploadFile();
    });
    // return result;
  }

  void _removeImage(File pickedFile) {
    setState(() {
      attachmentList.remove(pickedFile);
    });
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER
        _imageCnh = await ImagePicker.pickImage(
            source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera": // CAMERA CAPTURE CODE

        _showCamera();
        break;
    }

    if (_imageCnh != null) {
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

                          _removeImage(_imageCnh),
                          imageSelector(context, "gallery"),
                          Navigator.pop(context),


                        }) : Container(),
                    option == 1 || option == 3 ?
                    new ListTile(
                      title: new Text('Camera'),
                      onTap: () => {

                        _removeImage(_imageCnh),
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
