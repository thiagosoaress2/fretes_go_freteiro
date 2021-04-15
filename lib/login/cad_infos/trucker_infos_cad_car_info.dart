

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_page.dart';
import 'package:fretes_go_freteiro/classes/truck_class.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_bank_data.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadInfoBar.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadinfo_appbar.dart';
import 'package:fretes_go_freteiro/models/cad_infos_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/custom_pure_popup_1btn.dart';
import 'package:fretes_go_freteiro/utils/globals_constants.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widget_load_screen.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';


ScrollController _scrollController; //scroll screen to bottom

class TruckerInfosCadCarInfo extends StatelessWidget {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  double heightPercent;
  double widthPercent;
  static const int maxLenghtPlaca=7;

  List<File> attachmentList = [];


  @override
  Widget build(BuildContext context) {

    _scrollController = ScrollController();

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
              Navigator.of(context).pop(),
              cadInfosModel.updatePageClearChache(1),
              Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadInfoProfs()))
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
                          controller: _scrollController,
                          children: [

                            //estamos quase terminando
                            Container(
                              alignment: Alignment.center,
                              width: widthPercent,
                              child: Text('Estamos quase terminando!', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(1.7))),
                            ),
                            SizedBox(height: heightPercent*0.03,),
                            //placa e textfield placa
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: widthPercent*0.4,
                                  child: TextFormField(

                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(7),
                                    ],
                                      controller: cadInfosModel.placaController,
                                      decoration: InputDecoration(
                                        labelText: 'Placa do veículo',

                                      ),
                                      textInputAction: TextInputAction.done,
                                      keyboardType: TextInputType.visiblePassword
                                  ),
                                ),
                                SizedBox(width: widthPercent*0.02,),
                                Container(
                                  height: heightPercent*0.10,
                                  width: widthPercent*0.5,
                                  child: _modeloPlaca(cadInfosModel, context),
                                ),
                              ],
                            ),
                            SizedBox(height: heightPercent*0.05,),
                            //titulo tipo de veiculo
                            _tituloTipoDeCarroWithHelpBtn(context),
                            SizedBox(height: heightPercent*0.03,),
                            _vehicleTypeSelectioon(context, cadInfosModel),
                            SizedBox(height: heightPercent*0.05,),
                            _vehiclePhotoTitle(context),
                            SizedBox(height: heightPercent*0.03,),
                            _photoOfCar(context, cadInfosModel),
                            SizedBox(height: heightPercent*0.10,)



                          ],
                        ),
                      ),
                    ),

                    //barra informando a posição no cad
                    Positioned(
                      top: heightPercent*0.16,
                      left: 0.0,
                      right: 0.0,
                      child: WidgetCadInfoBar(3, heightPercent, widthPercent),
                    ),

                    //appbar
                    Positioned(
                        top: heightPercent*0.05,
                        left: 0.0,
                        right: 0.0,
                        child: WidgetCadInfoAppBar(heightPercent, widthPercent, 'Informações do veículo', '', closeCallBack)
                    ),


                    //floatActionButton
                    Positioned(
                      bottom: heightPercent*0.05,
                      right: 10.0,
                      child:  cadInfosModel.placaController.text.isNotEmpty && cadInfosModel.imageVehicle != null && cadInfosModel.vehicle != null
                              || cadInfosModel.placaController.text.isNotEmpty && cadInfosModel.vehicleImageUrl != null && cadInfosModel.vehicle != null
                          ? FloatingActionButton(
                          child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 45.0,),
                          backgroundColor: CustomColors.yellow,
                          onPressed: () async {

                                if(cadInfosModel.vehicle == null){
                                _displaySnackBar(context, "Primeiro selecione o modelo do seu veículo");
                                } else if(cadInfosModel.imageVehicle==null && cadInfosModel.vehicleImageUrl==null){ //se uploadedImageCarFIleURL for diferente de null é pq está atualizando
                                _displaySnackBar(context, "Nos envie uma foto do seu veículo");
                                } else if(cadInfosModel.placaController.text.isEmpty){
                                _displaySnackBar(context, "Informe a placa");
                                } else {

                                  save(userModel.Uid, userModel.Placa, cadInfosModel, context);

                                }


                          }) : Container(),

                    ),

                    /*
                    //janela loading
                    cadInfosModel.initialLoadIsDone==false
                        ? WidgetLoadingScreeen('Aguarde', 'Recuperando informações')
                        : Container(),


                     */
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


    void _afterLoadPageThreeUserInfos(){

      //agora salvar no shared para da proxima vez ele ler do shared e n precisar baixar. Caso tenha encontrado data no fb
      if(cadInfosModel.vehicle!=null){
        _saveInfosOfPageOneInShared(cadInfosModel);
      }

      //retira a janela de loading
      cadInfosModel.updateInitialLoadIsDone(true);
      _updateInfoOnScreenToUser(cadInfosModel, context);


    }

    if(await SharedPrefsUtils().loadIndividualInfo('vehicle')=='null'){
      print('lendo do firebase');
      //ler infos do fb
      //primeiro verifica se existe este dado no fb. SE n existir, é pq o user nunca preencheu
      await FirestoreServices().loadUserCarInfo(cadInfosModel, id, () {_afterLoadPageThreeUserInfos();});

    } else {
      print('lendo do shared');
      cadInfosModel.updateVehicle(await SharedPrefsUtils().loadIndividualInfo('vehicle'));
      cadInfosModel.updateVehicleImageUrl(await SharedPrefsUtils().loadIndividualInfo('vehicle_image'));
      cadInfosModel.updatePlaca(await SharedPrefsUtils().loadIndividualInfo('vehicle_placa'));
      cadInfosModel.updateInitialLoadIsDone(true);
      _updateInfoOnScreenToUser(cadInfosModel, context);
      //pronto. Todas informações da página foram carregadas.
    }


  }

  void _saveInfosOfPageOneInShared(CadInfosModel cadInfosModel){

    SharedPrefsUtils().saveIndividualInfo('vehicle', cadInfosModel.vehicle);
    SharedPrefsUtils().saveIndividualInfo('vehicle_image', cadInfosModel.vehicleImageUrl);
    SharedPrefsUtils().saveIndividualInfo('vehicle_placa', cadInfosModel.placa);
  }

  void _updateInfoOnScreenToUser(CadInfosModel cadInfosModel, BuildContext context){

    cadInfosModel.updatePlacaController(cadInfosModel.placa);
    cadInfosModel.updatePlacaExibicao(cadInfosModel.placa);
    cadInfosModel.updateVehicleImageUrl(cadInfosModel.vehicleImageUrl);
    //falta a foto

    /*
    print('apelido antes de updatar o controller'+cadInfosModel.apelido);
    cadInfosModel.updateApelidoController(cadInfosModel.apelido);
    cadInfosModel.updatePhoneController(cadInfosModel.phone.toString());
    cadInfosModel.updateAddressController(cadInfosModel.address.toString());
    cadInfosModel.updateaddressFound(cadInfosModel.address.toString());
    //carrega latlong
    findAddress(cadInfosModel.addressController, true, cadInfosModel, context);

    //talvez precise atualizar a imagem aqui
    /*
    setState(() {
      _uploadedImageProfileFileURL = userModel.Image.toString();
    });
     */


     */

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
                        title: new Text('Galeria'),
                        onTap: () => {

                          _removeImage(cadInfosModel.imageVehicle),
                          imageSelector(context, "gallery", cadInfosModel),
                          Navigator.pop(context),


                        }) : Container(),
                    option == 1 || option == 3 ?
                    new ListTile(
                      title: new Text('Câmera'),
                      onTap: () => {

                        _removeImage(cadInfosModel.imageVehicle),
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
        //File _provisory = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 90);
        File _provisory;
        final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 90);

        if(pickedFile!=null){
          _provisory = File(pickedFile.path);
          cadInfosModel.updateImageVehicle(await compressImageEvenMore(_provisory));
        } else {
          _displaySnackBar(context, 'Nenhuma imagem selecionada');
        }

        break;

      case "camera": // CAMERA CAPTURE CODE

        _showCamera(context, cadInfosModel);
        break;
    }

  }

  void save(String uid, String placa, CadInfosModel cadInfosModel, BuildContext context) async {

    cadInfosModel.updateIsLoading(true);

    if(cadInfosModel.imageVehicle==null){
      //significa que tá atualizando. Então n precisa trocar a foto pois manterá a do url
      saveData(uid, cadInfosModel, context);
    } else {

      //novo cad
      //salva a imagem primeiro
      String _path = 'carro/${uid.toString()}';

      /*
      StorageReference firebaseStorageRef =
      FirebaseStorage.instance.ref().child(path);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(cadInfosModel.imageVehicle);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then((value) {

            //cadInfosModel.updateImageVehicle(value);
          cadInfosModel.updateVehicleImageUrl(value);
            saveData(uid, cadInfosModel, context);


          }
      );

       */

      firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(_path);
      firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(cadInfosModel.imageVehicle);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.snapshot;
      taskSnapshot.ref.getDownloadURL().then((value) async {

        //cadInfosModel.updateImageVehicle(value);
        cadInfosModel.updateVehicleImageUrl(value);
        saveData(uid, cadInfosModel, context);

      });


    }

  }

  Future<void> saveData(String uid, CadInfosModel cadInfosModel, BuildContext context) async {

    Future<void> _onSucess1(CadInfosModel cadInfosModel) async {

      await SharedPrefsUtils().savePageThreeInfo(cadInfosModel);
      cadInfosModel.updateIsLoading(false);
      cadInfosModel.firstLoad=true;

      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => TruckerInfosCadBankData()));

    }

    void _onFailure(){
      //encerrar loading e indicar erro
      _displaySnackBar(context, "Ocorreu um erro. A informação não foi salva");
      cadInfosModel.updateIsLoading(false);

    }



    cadInfosModel.updatePlaca(cadInfosModel.placaController.text);

    await FirestoreServices().saveUserCarInfo(uid, cadInfosModel.placa, cadInfosModel.imageVehicle, cadInfosModel.vehicleImageUrl, cadInfosModel.vehicle, () {_onSucess1(cadInfosModel); }, () {_onFailure(); });

  }


  void _removeImage(File pickedFile) {
    attachmentList.remove(pickedFile);
  }

  Future<File> compressImageEvenMore(File file) async {

    print('comprimindo');

    // Get file path
    // eg:- "Volume/VM/abcd.jpeg"
    final String _imgPath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    String removedPointPath = _imgPath.replaceAll('.jpg', '');
    removedPointPath = removedPointPath.replaceAll('.jpeg', '');
    removedPointPath = removedPointPath.replaceAll('.png', '');
    final outPath = removedPointPath+'out'+'.jpg';

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
        _imgPath,
        outPath,
        minWidth: 500,
        minHeight: 500,
        quality: 60);

    return compressedImage;
  }

  void _showCamera(BuildContext context, CadInfosModel cadInfosModel) async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    final pickedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicturePage(camera: camera)));

    attachmentList.add(File(pickedImage));
    cadInfosModel.updateImageVehicle(await compressImageEvenMore(attachmentList.first));

    // return result;
  }






  Widget _modeloPlaca(CadInfosModel cadInfosModel, BuildContext context){

    cadInfosModel.placaController.addListener(() {
      cadInfosModel.updatePlacaExibicao(cadInfosModel.placaController.text);

    });

    return Stack(
      children: [

        Positioned(
          bottom: heightPercent*0.01,
          left: 0.0,
          right: 0.0,
          child: Container(
            width: widthPercent,
            alignment: Alignment.bottomCenter,
            color: Colors.grey[300],
            height: heightPercent*0.17,
            child: Padding(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Text(cadInfosModel.placaExibicao, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
            ),
          )
        ),

        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
              width: widthPercent,
              height: heightPercent*0.02,
              color: CustomColors.blue,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 10.0,),
                  Text('Brasil!', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                  Container(width: widthPercent*0.05, color: Colors.green,padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),),
                ],
              )
          ),
        ),


      ],
    );
  }

  Widget _tituloTipoDeCarroWithHelpBtn(BuildContext context){

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Tipo de veículo', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
        Container(
          child:  IconButton(icon: Icon(Icons.help_outline, color: CustomColors.blue, size: 40.0,
          ), onPressed: () {

            CustomPurePopup1Btn alert = CustomPurePopup1Btn(heightPercent, widthPercent, 'Ajuda', 'Escolha o tipo do veículo que melhor se encaixa com o seu. Perceba que exagerar no tamanho pode acabar gerando más avaliações dos usuários.', 'Entendi');

            showDialog(context: context, builder: (BuildContext context) {return alert;},);

          },),
        ),
      ],
    );
  }

  Widget _vehicleTypeSelectioon(BuildContext context, CadInfosModel cadInfosModel){

    return Container(
      width: widthPercent,
      child: Column(
        children: [

          SizedBox(height: heightPercent*0.05,),
          //linha 1 carroca, pickups
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.carroca);
                  scrollToBottom();
                },
                child: Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [
                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_carroca.png', fit: BoxFit.fill,),
                      ),
                      Text('Carroça', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.pickupPequena);
                  scrollToBottom();
                },
                child:
                Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [

                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_pickupp.png', fit: BoxFit.fill,),
                      ),
                      Text('Pickup peq', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                    ],
                  ),
                ),
              ),


              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.pickupGrande);
                  scrollToBottom();
                },
                child:
                Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [

                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_pickupg.png', fit: BoxFit.fill,),
                      ),
                      Text('Pickup G', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                    ],
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: heightPercent*0.07,),
          //linha 2 kombis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.kombiFechada);
                  scrollToBottom();
                },
                child:
                Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [

                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_kombi.png', fit: BoxFit.fill,),
                      ),
                      Text('Kombi', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.kombiAberta);
                  scrollToBottom();
                },
                child:
                Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [

                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_kombia.png', fit: BoxFit.fill,),
                      ),

                      Text('Kombi Aberta', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.4))),

                    ],
                  ),
                ),
              ),


              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.caminhaoBauPequeno);
                  scrollToBottom();
                },
                child:
                Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [

                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_baup.png', fit: BoxFit.fill,),
                      ),

                      Text('Baú peq', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),

                    ],
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: heightPercent*0.07,),
          //linha 3 caminhoes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [


              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.caminhaoBauGrande);
                  scrollToBottom();
                },
                child:
                Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [

                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_baug.png', fit: BoxFit.fill,),
                      ),

                      Text('Baú grande', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),

                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: (){
                  cadInfosModel.updateVehicle(GlobalsConstants.caminhaoPequenoAberto);
                  scrollToBottom();
                },
                child:
                Container(
                  height: heightPercent*0.15,
                  width: widthPercent*0.20,
                  child: Column(
                    children: [

                      Container(
                        width: widthPercent*0.20,
                        height: heightPercent*0.05,
                        child: Image.asset('images/cars/truck_aberto.png', fit: BoxFit.fill,),
                      ),
                      Text('Peq aberto', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),

                    ],
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: heightPercent*0.05,),

          //banner com o carro selecionado
          Padding(
              child: Container(

                  width: widthPercent*0.7,
                  decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 2.0),
                  child: Column(
                    children: [
                      Text('Veículo selecionado', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      Text(cadInfosModel.vehicle == null ? '' : TruckClass.empty().formatCodeToHumanName(cadInfosModel.vehicle), style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      Container(
                        width: widthPercent*0.30,
                        height: heightPercent*0.10,
                        alignment: Alignment.center,
                        child:
                        cadInfosModel.vehicle == null
                            ? Text('Não selecionado', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5)))
                            : cadInfosModel.vehicle==GlobalsConstants.pickupPequena ? Image.asset('images/cars/truck_pickupp.png', fit: BoxFit.fill,)
                            : cadInfosModel.vehicle==GlobalsConstants.carroca ? Image.asset('images/cars/truck_carroca.png', fit: BoxFit.fill,)
                            : cadInfosModel.vehicle==GlobalsConstants.pickupGrande ? Image.asset('images/cars/truck_pickupg.png', fit: BoxFit.fill,)
                            : cadInfosModel.vehicle==GlobalsConstants.kombiAberta  ? Image.asset('images/cars/truck_kombia.png', fit: BoxFit.fill,)
                            : cadInfosModel.vehicle==GlobalsConstants.kombiFechada ? Image.asset('images/cars/truck_kombi.png', fit: BoxFit.fill,)
                            : cadInfosModel.vehicle==GlobalsConstants.caminhaoPequenoAberto ? Image.asset('images/cars/truck_aberto.png', fit: BoxFit.fill,)
                            : cadInfosModel.vehicle==GlobalsConstants.caminhaoBauPequeno ? Image.asset('images/cars/truck_baup.png', fit: BoxFit.fill,)
                            :  Image.asset('images/cars/truck_baug.png', fit: BoxFit.fill,)
                      ),

                    ],
                  )
              ),
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 00.0)),

        ],
      ),
    );
  }

  Widget _vehiclePhotoTitle(BuildContext context){

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Foto do veículo', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
        /*
        Container(
          child:  IconButton(icon: Icon(Icons.help_outline, color: CustomColors.blue, size: 40.0,
          ), onPressed: () {

            CustomPurePopup1Btn alert = CustomPurePopup1Btn(heightPercent, widthPercent, 'Ajuda', 'Escolha o tipo do veículo que melhor se encaixa com o seu. Perceba que exagerar no tamanho pode acabar gerando más avaliações dos usuários.', 'Entendi');

            showDialog(context: context, builder: (BuildContext context) {return alert;},);

          },),
        ),

         */
      ],
    );

  }

  Widget _photoOfCar(BuildContext context, CadInfosModel cadInfosModel){

    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        width: widthPercent*0.80,
        height: heightPercent*0.25,
        margin: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 6.0), //Same as `blurRadius` i guess
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: _photoPlaceHolder(context, cadInfosModel),
      ),
    );


  }
  
  Widget _photoPlaceHolder(BuildContext context, CadInfosModel cadInfosModel){
    
    return GestureDetector(

      onTap: (){
        _settingModalBottomSheet(context, 1, cadInfosModel);
      },
      child: Stack(
        children: [

          Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(widthPercent*0.15, 10.0, widthPercent*0.15, 10.0),
                child: Container(
                  alignment: Alignment.center,
                  width: widthPercent*0.60,
                  child:
                  cadInfosModel.imageVehicle != null
                      ? Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: FileImage(cadInfosModel.imageVehicle), fit: BoxFit.fill)),)
                      : cadInfosModel.vehicleImageUrl != null ? Image.network(cadInfosModel.vehicleImageUrl)
                      : Text('Você ainda não enviou foto', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(1.7))),
                  //Image.asset('images/cadinfos/truckerico.png'),
                ),
              )),

          Positioned(
            bottom: heightPercent*0.01,
            right: widthPercent*0.12,
            child: GestureDetector(
              child: Container(width: widthPercent*0.15, height: 50.0, color: Colors.blue,
                child: Icon(Icons.camera_alt_outlined, color: Colors.white,),),
              onTap: (){
                _settingModalBottomSheet(context, 1, cadInfosModel);
              },
            ),),
        ],
      ),
    );
  }


  void scrollToBottom() {
    final bottomOffset = _scrollController.position.pixels;
    _scrollController.animateTo(
      bottomOffset+heightPercent*0.90,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
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
