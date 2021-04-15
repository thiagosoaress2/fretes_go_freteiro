import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_page.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadInfoBar.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadinfo_appbar.dart';
import 'package:fretes_go_freteiro/models/cad_infos_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/custom_pure_popup_1btn.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widget_load_screen.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class TruckerInfosCadInfoProfs extends StatelessWidget {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  List<File> attachmentList = [];
  String _uploadedImageCnhFileURL;

  bool needCheck=true;

  double heightPercent;
  double widthPercent;

  int _pageDone;

  @override
  Widget build(BuildContext context) {

    if(heightPercent==null){
      heightPercent = MediaQuery
          .of(context)
          .size
          .height;
      widthPercent = MediaQuery
          .of(context)
          .size
          .width;
    }

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        return ScopedModelDescendant<CadInfosModel>(
          builder: (BuildContext context, Widget widget, CadInfosModel cadInfosModel){


            if(cadInfosModel.firstLoad==true){
              cadInfosModel.firstLoad=false;
              _loadUsersInfoFromShared(cadInfosModel, userModel.Uid, context);
            }

            VoidCallback closeCallBack = () => {
              cadInfosModel.updatePageClearChache(1),
              Navigator.of(context).pop(),
            Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadUserInfo()))
            };


            return Scaffold(
              key: _scaffoldKey,
              body: Container(
                width: widthPercent,
                height: heightPercent,
                color: Colors.white,
                child: Stack(
                  children: [

                    //corpo com infos
                    Positioned(
                      top: heightPercent*0.27,
                      left: 10.0,
                      right: 10.0,
                      bottom: 0.0,
                      child: Container(
                        height: heightPercent*0.87,
                        child: ListView(
                          children: [

                            SizedBox(height: heightPercent*0.07,),
                            Container(
                              alignment: Alignment.center,
                              width: widthPercent*0.90,
                              child: Text(cadInfosModel.alreadySentCnh==true ? 'Você já nos enviou sua CNH' : 'Agora precisamos da sua CNH', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //EditText  para o endereço
                                //btn de informação
                                Container(
                                  padding: EdgeInsets.only(right: widthPercent*0.03),
                                  child: Container(
                                    child:  IconButton(icon: Icon(Icons.help_outline, color: CustomColors.blue, size: 40.0,
                                    ), onPressed: () {

                                      CustomPurePopup1Btn alert = CustomPurePopup1Btn(heightPercent, widthPercent, 'Ajuda', 'Por que precisamos da sua CNH?\nÉ uma medida de segurança e manteremos a identificação em sigilo. Os usuários não terão acesso a esta informação.', 'Entendi');

                                      showDialog(context: context, builder: (BuildContext context) {return alert;},);

                                      /*
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

                                       */

                                    },),
                                  ),
                                )

                              ],
                            ),
                            SizedBox(height: heightPercent*0.05,),
                            //linha com foto da CNH
                            cadInfosModel.alreadySentCnh==false ?
                                Container(
                                  height: heightPercent*0.40,
                                  child: Stack(
                                    children: [


                                Positioned(
                                  top: 0.0,
                                  left: widthPercent*0.20,
                                  right: widthPercent*0.20,
                                  child: GestureDetector(
                                  child: Container(
                                      width: 150, height: heightPercent*0.20,
                                      child: cadInfosModel.imageCnh == null && cadInfosModel.alreadySentCnh==true
                                          ? Container()
                                          : cadInfosModel.imageCnh == null
                                          ? Image.asset("images/cadinfos/cnhavatar.png", fit: BoxFit.fill)
                                          : Image.file(cadInfosModel.imageCnh, fit: BoxFit.fill,)

                                  ),
                                  onTap: (){
                                    _settingModalBottomSheet(context, 3, cadInfosModel);
                                  },
                                ),
                                ),

                                Positioned(
                                  top: heightPercent*0.15,
                                  right: widthPercent*0.15,
                                  child: GestureDetector(
                                  child: Container(width: widthPercent*0.15, height: 50.0, color: Colors.blue,
                                    child: Icon(Icons.camera_alt_outlined, color: Colors.white,),),
                                  onTap: (){
                                    _settingModalBottomSheet(context, 3, cadInfosModel);
                                  },
                                ),
                                ),


                                    ],
                                  )
                                )
                             : Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: widthPercent*0.20,
                                  height: heightPercent*0.15,
                                  child: Icon(Icons.done, color: Colors.white, size: 50.0,),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CustomColors.blue,
                                  ),
                                ),
                                SizedBox(height: heightPercent*0.03,),
                                Text('Para reenviar sua CNH clique aqui', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),
                                SizedBox(height: heightPercent*0.03,),
                                GestureDetector(
                                  child: Container(width: widthPercent*0.15, height: 50.0, color: Colors.blue,
                                    child: Icon(Icons.camera_alt_outlined, color: Colors.white,),),
                                  onTap: (){
                                    _settingModalBottomSheet(context, 3, cadInfosModel);
                                  },
                                ),
                              ],
                            )

                          ],
                        ),
                      ),
                    ),

                    //appbar
                    Positioned(
                        top: heightPercent*0.05,
                        left: 0.0,
                        right: 0.0,
                        child: WidgetCadInfoAppBar(heightPercent, widthPercent, 'Informação profissional', '', closeCallBack)
                    ),

                    //barra de progresso
                    Positioned(
                      top: heightPercent*0.16,
                      left: 0.0,
                      right: 0.0,
                      child: WidgetCadInfoBar(2, heightPercent, widthPercent),
                    ),

                    Positioned(
                      bottom: heightPercent*0.05,
                      right: 10.0,
                      child: cadInfosModel.alreadySentCnh==true || cadInfosModel.imageCnh!=null
                          ? FloatingActionButton(
                          child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 45.0,),
                          backgroundColor: CustomColors.yellow,
                          onPressed: () async {

                            if(cadInfosModel.alreadySentCnh==true){
                              cadInfosModel.firstLoad=true;
                              Navigator.of(context).pop();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadCarInfo()));
                            } else {
                              save(userModel.Uid, cadInfosModel, context);
                            }



                          }) : Container(),

                    ),


                    //janela loading
                    cadInfosModel.initialLoadIsDone==false
                        ? WidgetLoadingScreeen('Aguarde', 'Recuperando informações')
                        : Container(),

                    cadInfosModel.isLoading==true
                        ? Center(child: CircularProgressIndicator(),)
                        : Container(),

                  ],
                ),
              ),
            );

          },
        );
      },
    );
  }


  void _loadUsersInfoFromShared(CadInfosModel cadInfosModel, String id, BuildContext context) async {

    //a pagina dois so tem a cnh. Nos nao vamos carrega-la....mas o user pode muda-la.
    //tres cenários então: Nunca enviou....vai dar false abaixo. Já enviou, n precisa exibir.
    _pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
    if(_pageDone!=99 && _pageDone>1){ //se o dado existe e se esta página ja está carregada

      cadInfosModel.updateAlreadySentCnh(true);

    }
    cadInfosModel.updateInitialLoadIsDone(true);

  }

  void _settingModalBottomSheet(context, int option, CadInfosModel cadInfosModel) {
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

                          _removeImage(cadInfosModel.imageCnh),
                          imageSelector(context, "gallery", cadInfosModel),
                          Navigator.pop(context),


                        }) : Container(),
                    option == 1 || option == 3 ?
                    new ListTile(
                      title: new Text('Camera'),
                      onTap: () => {

                        _removeImage(cadInfosModel.imageCnh),
                        imageSelector(context, "camera", cadInfosModel),
                        Navigator.pop(context)


                      },
                    ) : Container(),
                  ],
                )
              ],
            ),
          );
        }
    );
  }

  Future imageSelector(BuildContext context, String pickerType, CadInfosModel cadInfosModel) async {
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER
        //cadInfosModel.updateImageCnh(await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 90));
        final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 90);
        File _provisory;

        if(pickedFile!=null){
          _provisory = File(pickedFile.path);
          cadInfosModel.updateImageCnh(_provisory);
        } else {
          _displaySnackBar(context, 'Nenhuma imagem selecionada');
        }

        break;

      case "camera": // CAMERA CAPTURE CODE

        _showCamera(context, cadInfosModel);
        break;
    }

  }

  void _showCamera(BuildContext context, CadInfosModel cadInfosModel) async {

    attachmentList.clear();

    final cameras = await availableCameras();
    final camera = cameras.first;

    final pickedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicturePage(camera: camera)));
    //builder: (context) => TakePictureFromCnh(camera: camera)));

    attachmentList.add(File(pickedImage));
    cadInfosModel.updateImageCnh(attachmentList.first);
    cadInfosModel.updateImageCnh(await compressImageEvenMore(cadInfosModel.imageCnh));


  }

  Future<File> compressImageEvenMore(File file) async {

    // Get file path
    // eg:- "Volume/VM/abcd.jpeg"
    //final filePath = file.absolute.path;
    var _imgPath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    //final lastIndex = _imgPath.lastIndexOf(new RegExp(r'.'))-1; //filePath.lastIndexOf(new RegExp(r'.jp'));
    //final splitted = _imgPath.substring(0, (lastIndex)); //filePath.substring(0, (lastIndex));
    //final outPath = "${splitted}_out${_imgPath.substring(lastIndex)}"; //"${splitted}_out${filePath.substring(lastIndex)}";
    String removedPointPath = _imgPath.replaceAll('.jpg', '');
    removedPointPath = removedPointPath.replaceAll('.jpeg', '');
    removedPointPath = removedPointPath.replaceAll('.png', '');
    final outPath = removedPointPath+'out'+'.jpg';

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      //filePath,
        _imgPath,
        outPath,
        minWidth: 500,
        minHeight: 500,
        quality: 50);

    return compressedImage;
  }

  void _removeImage(File pickedFile) {
    attachmentList.remove(pickedFile);
  }

  void save(String uid, CadInfosModel cadInfosModel, BuildContext context) async {

    cadInfosModel.updateIsLoading(true);

    //salva a imagem
    String _path = 'cnh/${uid.toString()}';

    /*
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(cadInfosModel.imageCnh);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then(
            (value) {

          _uploadedImageCnhFileURL = value;
          saveData(uid, context, cadInfosModel);

        });

     */

    firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance.ref().child(_path);
    firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(cadInfosModel.imageCnh);
    firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.snapshot;
    taskSnapshot.ref.getDownloadURL().then((value) async {

      _uploadedImageCnhFileURL = value;
      saveData(uid, context, cadInfosModel);

    });


    /*
    await FirestoreServices().saveUserInfo(userModel, latitude, longitude, _apelidoController.text, _phoneController.text,
        adressFound, () {_onSucess1(); }, () {_onFailure1(); });

     */

  }

  Future<void> saveData(String uid, BuildContext context, CadInfosModel cadInfosModel) async {

    void _onSucess1(BuildContext context){

      //chamar salvamentos 2
      _displaySnackBar(context, "CNH salva");

      cadInfosModel.updateIsLoading(false);

      if(_pageDone<2){
        //se for maior está apenas atualizando e n precisa
        SharedPrefsUtils().savePageTwoInfo();

      }

      //abrir a proxima pagina
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadCarInfo()));

    }

    void _onFailure1(){
      //encerrar loading e indicar erro
      _displaySnackBar(context, "Ocorreu um erro. A informação não foi salva");
      cadInfosModel.updateIsLoading(false);

    }

    await FirestoreServices().saveUserCNHinfo(uid, _uploadedImageCnhFileURL, _pageDone ,() {_onSucess1(context); }, () {_onFailure1(); });
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


/*
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_from_cnh_page.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_page.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
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

  bool needCheck=true;

  bool alreadySentCnh=false;

  UserModel userModelGlobal;

  int pageDone;

  Future<void> loadPageInfo(UserModel userModel) async {

    pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
    if(pageDone!=99 && pageDone>1){ //se o dado existe e se esta página ja está carregada

      setState(() {
        alreadySentCnh = true;
      });

    }
  }


  @override
  Widget build(BuildContext context) {

    double heightPercent = MediaQuery.of(context).size.height;
    double widthPercent = MediaQuery.of(context).size.width;

    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        if(needCheck==true){
          needCheck=false;
          loadPageInfo(userModel);
        }

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

                  userModel.TruckerInfoOk == true || alreadySentCnh == true
                  ? WidgetsConstructor().makeText("Você já enviou sua CNH para nós.", Colors.redAccent, 15.0, 10.0, 0.0, "center")
                  : Container(),

                  isLoading == true
                      ? Center(child: CircularProgressIndicator())
                      : Container(),

                  SizedBox(height: 20.0,),

                  GestureDetector(
                    onTap: (){

                      if(userModel.TruckerInfoOk == true || alreadySentCnh == true){

                        //abrir a proxima pagina
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadCarInfo()));

                      } else {

                        if(_imageCnh!=null){
                          save(userModel.Uid);
                          userModelGlobal = userModel;
                        }

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

    await FirestoreServices().saveUserCNHinfo(uid, _uploadedImageCnhFileURL, pageDone ,() {_onSucess1(); }, () {_onFailure1(); });
  }

  void _onSucess1(){

    //chamar salvamentos 2
    _displaySnackBar(context, "CNH salva");
    setState(() {
      isLoading=false;
    });
    SharedPrefsUtils().savePageTwoInfo(userModelGlobal);
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

    attachmentList.add(File(pickedImage));
    _imageCnh = attachmentList.first;

    setState(() async {
      _imageCnh = await compressImageEvenMore(_imageCnh);


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

  Future<File> compressImageEvenMore(File file) async {

    print('comprimindo');

    // Get file path
    // eg:- "Volume/VM/abcd.jpeg"
    final filePath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        minWidth: 500,
        minHeight: 400,
        quality: 40);

    return compressedImage;
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