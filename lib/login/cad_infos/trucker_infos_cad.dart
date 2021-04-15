
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_page.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadInfoBar.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadinfo_appbar.dart';
import 'package:fretes_go_freteiro/models/cad_infos_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/avaliation_page.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/custom_pure_popup_1btn.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widget_load_screen.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path/path.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';

/// Enum representing the upload task types the example app supports.
enum UploadType {
  /// Uploads a randomly generated string (as a file) to Storage.
  string,
  /// Uploads a file from the device.
  file,
  /// Clears any tasks from the list.
  clear,}


class TruckerInfosCadUserInfo extends StatelessWidget {

  /*
  DOCumentação
  1 passo: A pagina vai tentar carregar informações do shared e caso nao consiga, vai baixar do firebase.
  Estes dados serão salvos no cadInfosModel.
  2 Uma vez que baixou do firebase, salva diretamente no shared para evitar downloads nas proximas vezes.
  3 a variavel initialLoadIsDone é atualizada para true no cadInfoModel e remove a tela de loading
  4 _updateInfoOnScreenToUser(cadInfosModel, context) é chamado para atualizar os dados na tela para o user ver
  As informações que precisamos para esta primeira página são: Apelido, phone, endereço, imagem, latlong.
   */

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar

  double heightPercent;
  double widthPercent;
  List<File> attachmentList = [];
  File _imageProfile;
  String _imgPath;
  var _maskFormatterPhone = new MaskTextInputFormatter(mask: '(##) ####-#####)', filter: { "#": RegExp(r'[0-9]') });
  double latitude;
  double longitude;
  UserModel userModelGlobal;
  bool needCheck=true;
  bool _changedLatLong=false;


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
              Navigator.of(context).pop(),
              cadInfosModel.updatePageClearChache(1),
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()))
            };

            return Scaffold(
              key: _scaffoldKey,
              body: Container(
                height: heightPercent,
                width: widthPercent,
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


                            //banner explicando a página. Só vai aparecer se o user nunca tiver preenchido esta página
                            cadInfosModel.apelidoController.text.isEmpty && cadInfosModel.phoneController.text.isEmpty
                                && cadInfosModel.addressFound == null && cadInfosModel.image == null
                            ? Row(
                              children: [
                                Container(
                                    color: CustomColors.yellow,
                                    width: widthPercent*0.75,
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          Text('Algumas informações antes que você possa', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2))),
                                          Text('ganhar dinheiro!', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(4.0))),
                                        ],
                                      )
                                    )
                                ),
                              ],
                            ) : Container(),

                            SizedBox(height: heightPercent*0.05),

                            ///nome
                            TextField(
                              controller: cadInfosModel.apelidoController,
                              decoration: InputDecoration(labelText: 'Como quer aparecer no app? (nome ou apelido)'),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                            ),
                            //WidgetsConstructor().makeEditText(cadInfosModel.apelidoController, "Como quer aparecer no app? (nome ou apelido)", null),

                            SizedBox(height: heightPercent*0.03,),

                            //telefone
                            TextField(
                              controller: cadInfosModel.phoneController,
                              inputFormatters: [_maskFormatterPhone],
                              autocorrect: false,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: "Seu telefone com whatsapp"),
                            ),
                            //WidgetsConstructor().makeEditTextForPhoneFormat(cadInfosModel.phoneController, "Seu telefone com whatsapp", _maskFormatterPhone),

                            SizedBox(height: heightPercent*0.05,),

                            //botão de ajuda sobre a info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [


                                Text('Ponto de partida do veículo', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2))),
                                //EditText  para o endereço
                                //btn de informação
                                Container(
                                  padding: EdgeInsets.only(right: widthPercent*0.03),
                                  child:
                                  IconButton(icon: Icon(Icons.help_outline, color: CustomColors.blue, size: 50.0,
                                  ), onPressed: () {

                                    CustomPurePopup1Btn alert = CustomPurePopup1Btn(heightPercent, widthPercent, 'Sua base', 'O endereço da sua base é o ponto onde seu veículo fica. É a partir deste endereço que você aparecerá para os clientes que estejam buscando um profissional.', 'Entendi');

                                    showDialog(context: context, builder: (BuildContext context) {return alert;},);

                                  },),
                                )

                                //SizedBox(width: widthPercent*0.05,),

                              ],
                            ),

                            SizedBox(height: heightPercent*0.04,),

                            //barra de busca do endereço
                            Row(
                              children: [

                                Container(
                                  width: widthPercent*0.77,
                                  child: WidgetsConstructor().makeEditText(cadInfosModel.addressController, "Endereço que parte o veículo", null),
                                ),

                                SizedBox(width: widthPercent*0.023,),

                                //btn de busca do endereço
                                Container(
                                  width: widthPercent*0.15,
                                  child: Container(
                                    decoration: WidgetsConstructor().myBoxDecoration(CustomColors.blue, CustomColors.blue, 1.0, 3.0),
                                    child: IconButton(icon: Icon(Icons.search, color: Colors.white,), onPressed: () {

                                      //fecha o teclado
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus) {
                                        //remove o foco (isto fecha o teclado)
                                        currentFocus.unfocus();
                                      }

                                      findAddress(cadInfosModel.addressController, false, cadInfosModel, context); //false indica que o user cliclou no botão e precisa de feedback na tela como o loading

                                    },),
                                  ),
                                )

                              ],
                            ),

                            //resumo do enderçeo encontrado
                            cadInfosModel.addressFound == 'nao' && cadInfosModel.addressController.text.isNotEmpty
                            ? Container(
                              padding: EdgeInsets.all(15.0),
                              decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 1.0),
                              child: Column(
                                children: [
                                  Text('Endereço não localizado', style: TextStyle(color: Colors.redAccent, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                                ],
                              ))
                            : cadInfosModel.addressFound != null  && cadInfosModel.addressController.text.isNotEmpty
                                ? Container(
                                padding: EdgeInsets.all(15.0),
                                decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 2.0, 1.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Endereço localizado', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.5))),
                                    Text(cadInfosModel.addressFound, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2)))
                                  ],
                                ))
                                : Container(),


                            SizedBox(height: heightPercent*0.05,),

                            Text('Sua foto no app', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2))),

                            SizedBox(height: heightPercent*0.05,),

                            Container(
                              height: heightPercent*0.25,
                              child: Stack(
                                children: [

                                  Positioned(
                                    top: 0.0,
                                    bottom: 0.0,
                                    left: widthPercent*0.20,
                                    right: widthPercent*0.20,
                                    child: GestureDetector(
                                      onTap: (){
                                        _settingModalBottomSheet(context, 1, cadInfosModel);
                                      },


                                      child:
                                      cadInfosModel.imageFile != null
                                          ? Container(decoration: BoxDecoration(shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: FileImage(cadInfosModel.imageFile), // picked file
                                              fit: BoxFit.fill)),)
                                          : cadInfosModel.image != null
                                          ? Container(decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(cadInfosModel.image), fit: BoxFit.fill)))
                                          : Image.asset("images/avatar.png"),

                                    ),
                                  ),

                                  Positioned(
                                    top: heightPercent*0.17,
                                    left: widthPercent*0.60,
                                    child: GestureDetector(
                                      child: Container(
                                        decoration: WidgetsConstructor().myBoxDecoration(CustomColors.blue, CustomColors.blue, 1.0, 3.0),
                                        width: widthPercent*0.15, height: 50.0,
                                        child: Icon(Icons.camera_alt_outlined, color: Colors.white,),),
                                      onTap: (){
                                        _settingModalBottomSheet(context, 1, cadInfosModel);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: heightPercent*0.05,),

                            SizedBox(height: 50.0,),

                            /*
                            Container(
                              width: widthPercent*0.75,
                              height: heightPercent*0.10,
                              child: RaisedButton(
                                color: CustomColors.blue,
                                child: Text('Proximo'),
                                onPressed: () async {
                                  if(cadInfosModel.apelidoController.text.isEmpty){
                                    _displaySnackBar(context, "Informe o nome ou apelido que deseja usar.");
                                  } else if(cadInfosModel.phoneController.text.isEmpty){
                                    _displaySnackBar(context, "Informe o telefone com whatsapp que deseja usar");
                                  } else if(cadInfosModel.addressFound == null || cadInfosModel.addressFound == "nao"){
                                    _displaySnackBar(context, "Informe um endereço válido");
                                  } else if(cadInfosModel.imageFile == null && cadInfosModel.image == null){
                                    _displaySnackBar(context, "Precisamos de uma foto sua");
                                  } else if(cadInfosModel.addressController.text != cadInfosModel.addressFound && latitude == null){
                                    _displaySnackBar(context, "Valide o endereço clicando no botão de busca de endereço antes de prosseguir");
                                  } else {

                                    cadInfosModel.updateIsLoading(true);
                                    //ver se mudou algo
                                    int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
                                    if(pageDone==1 || pageDone==2 || pageDone==3 || pageDone==4){

                                      //abaixo verifica se tem algo diferente. Se não tiver, significa que o user n mudou nada e n precisa salvar. Ir para proxima página.
                                      if(cadInfosModel.apelidoController.text == cadInfosModel.apelido && cadInfosModel.phoneController.text == cadInfosModel.phone && cadInfosModel.addressFound == cadInfosModel.address && cadInfosModel.imageFile == null) {

                                        //vai pra proxima página sem salvar nada
                                        //abrir a proxima pagina
                                        cadInfosModel.updateIsLoading(false);
                                        Navigator.of(context).pop();
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadInfoProfs()));

                                      } else {
                                        //significa que algo mudou. Vamos salvar tudo novamente

                                        //caso tenha algo para atualizar
                                        _prepareDataToSave(cadInfosModel, userModel.Uid, context);

                                      }
                                    } else {

                                      //caso tenha algo para atualizar
                                      _prepareDataToSave(cadInfosModel, userModel.Uid, context);


                                    }


                                  }


                                },
                              ),
                            ),

                             */



                          ],
                        ),
                      ),
                    ),

                    //barra informando a posição no cad
                    Positioned(
                      top: heightPercent*0.16,
                      left: 0.0,
                      right: 0.0,
                      child: WidgetCadInfoBar(1, heightPercent, widthPercent),
                    ),

                    //appbar
                    Positioned(
                        top: heightPercent*0.05,
                        left: 0.0,
                        right: 0.0,
                        child: WidgetCadInfoAppBar(heightPercent, widthPercent, 'Informações de exibição', 'Início', closeCallBack)
                    ),

                    //floatActionButton
                    Positioned(
                      bottom: heightPercent*0.05,
                      right: 10.0,
                      child: cadInfosModel.apelidoController.text.isNotEmpty && cadInfosModel.phoneController.text.isNotEmpty
                          && cadInfosModel.addressFound != null && cadInfosModel.image != null
                      ||
                          cadInfosModel.apelidoController.text.isNotEmpty && cadInfosModel.phoneController.text.isNotEmpty
                              && cadInfosModel.addressFound != null && cadInfosModel.imageFile != null

                          ? FloatingActionButton(
                          child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 45.0,),
                          backgroundColor: CustomColors.yellow,
                          onPressed: () async {

                            if(cadInfosModel.apelidoController.text.isEmpty){
                              _displaySnackBar(context, "Informe o nome ou apelido que deseja usar.");
                            } else if(cadInfosModel.phoneController.text.isEmpty){
                              _displaySnackBar(context, "Informe o telefone com whatsapp que deseja usar");
                            } else if(cadInfosModel.addressFound == null || cadInfosModel.addressFound == "nao"){
                              _displaySnackBar(context, "Informe um endereço válido");
                            } else if(cadInfosModel.imageFile == null && cadInfosModel.image == null){
                              _displaySnackBar(context, "Precisamos de uma foto sua");
                            } else if(cadInfosModel.addressController.text != cadInfosModel.addressFound && latitude == null){
                              _displaySnackBar(context, "Valide o endereço clicando no botão de busca de endereço antes de prosseguir");
                            } else {

                              cadInfosModel.updateIsLoading(true);
                              //ver se mudou algo
                              int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
                              if(pageDone==1 || pageDone==2 || pageDone==3 || pageDone==4){

                                //abaixo verifica se tem algo diferente. Se não tiver, significa que o user n mudou nada e n precisa salvar. Ir para proxima página.
                                if(cadInfosModel.apelidoController.text == cadInfosModel.apelido && cadInfosModel.phoneController.text == cadInfosModel.phone && cadInfosModel.addressFound == cadInfosModel.address && cadInfosModel.imageFile == null) {

                                  //vai pra proxima página sem salvar nada
                                  //abrir a proxima pagina
                                  cadInfosModel.updateIsLoading(false);
                                  //limpa variaveis para a proxima página
                                  cadInfosModel.updatePageClearChache(2);
                                  Navigator.of(context).pop();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadInfoProfs()));

                                } else {
                                  //significa que algo mudou. Vamos salvar tudo novamente

                                  //caso tenha algo para atualizar
                                  _prepareDataToSave(cadInfosModel, userModel.Uid, context);

                                }
                              } else {

                                //caso tenha algo para atualizar
                                _prepareDataToSave(cadInfosModel, userModel.Uid, context);


                              }


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
                )
              ),
            );

          },
        );
      },
    );
  }

  void _loadUsersInfoFromShared(CadInfosModel cadInfosModel, String id, BuildContext context) async {



    void _afterLoadPageOneUserInfos(){

      //agora salvar no shared para da proxima vez ele ler do shared e n precisar baixar. Caso tenha encontrado data no fb
      if(cadInfosModel.apelido!=null){
        _saveInfosOfPageOneInShared(cadInfosModel);
      }

      //retira a janela de loading
      cadInfosModel.updateInitialLoadIsDone(true);
      _updateInfoOnScreenToUser(cadInfosModel, context);


    }

    //aqui abaixo é se for um novo cadastro
    void _afterLoadPageOneUserInfos_DataDontExists(){
      cadInfosModel.updateInitialLoadIsDone(true);
    }

    //if(await SharedPrefsUtils().loadIndividualInfo('apelido')=='null'){
    if(await SharedPrefsUtils().loadIndividualInfo('phone')=='null'){
      print('lendo do firebase');
      //ler infos do fb
      //primeiro verifica se existe este dado no fb. SE n existir, é pq o user nunca preencheu
      await FirestoreServices().loadPageOneUserInfos(cadInfosModel, id, (){_afterLoadPageOneUserInfos();}, (){_afterLoadPageOneUserInfos_DataDontExists();});

    } else {
      print('lendo do shared');
      cadInfosModel.updateApelido(await SharedPrefsUtils().loadIndividualInfo('apelido'));
      cadInfosModel.updatephone(await SharedPrefsUtils().loadIndividualInfo('phone'));
      cadInfosModel.updateaddress(await SharedPrefsUtils().loadIndividualInfo('address'));
      cadInfosModel.updateimage(await SharedPrefsUtils().loadIndividualInfo('image'));
      cadInfosModel.updateLatLong(await SharedPrefsUtils().loadIndividualInfoDoble('latlong'));
      cadInfosModel.updateInitialLoadIsDone(true);
      _updateInfoOnScreenToUser(cadInfosModel, context);
      //pronto. Todas informações da página foram carregadas.
    }


  }

  void _saveInfosOfPageOneInShared(CadInfosModel cadInfosModel){

    SharedPrefsUtils().saveIndividualInfo('apelido', cadInfosModel.apelido);
    SharedPrefsUtils().saveIndividualInfo('phone', cadInfosModel.phone);
    SharedPrefsUtils().saveIndividualInfo('address', cadInfosModel.address);
    SharedPrefsUtils().saveIndividualInfo('image', cadInfosModel.image);
    SharedPrefsUtils().saveIndividualDouble('latlong', cadInfosModel.latlong);
  }

  void _updateInfoOnScreenToUser(CadInfosModel cadInfosModel, BuildContext context){

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


  }

  void findAddress(TextEditingController controller, bool itsAutomatic, CadInfosModel cadInfosModel, BuildContext context) async {


    if(
    controller.text.toString().contains("0") || controller.text.toString().contains("1") || controller.text.toString().contains("2") ||
        controller.text.toString().contains("3") || controller.text.toString().contains("4") || controller.text.toString().contains("5") ||
        controller.text.toString().contains("6") || controller.text.toString().contains("7") || controller.text.toString().contains("8") ||
        controller.text.toString().contains("9")) {


      if(itsAutomatic==false){
        cadInfosModel.updateIsLoading(true);
      }

      String addressInformed = controller.text;
      var addresses = await Geocoder.local.findAddressesFromQuery(addressInformed);
      if(addresses.length!=0){
        var first = addresses.first;

        if(addresses.length>=1){

          cadInfosModel.updateaddressFound(first.addressLine + " - " + first.adminArea);
          //agora vamos pegar as coordenadas
          await getTheCoordinates(cadInfosModel.addressFound);

          //exibe uma popup informando que o endereço foi achado

          //só vai salvar mudança na latlong se mudar aqui. Dava erro as vezes pois se o user estivesse atualizando apenas e
          //n mexesse no endereço quando ia salvar nao tinha latlong
          _changedLatLong=true;

          if(itsAutomatic==false){
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
          }

          if(itsAutomatic==false){
            cadInfosModel.updateIsLoading(false);

          }


        } else {

          cadInfosModel.updateaddressFound('nao');

          if(itsAutomatic==false){
            cadInfosModel.updateIsLoading(false);

          }

          _displaySnackBar(context, "Especifique melhor o endereço. Estamos encontrando multiplos resultados");
        }
      } else {

        cadInfosModel.updateIsLoading(false);
        cadInfosModel.updateaddressFound('nao');
        _displaySnackBar(context, "Endereço inválido");

      }

    } else {
      _displaySnackBar(context, "Informe o número da residência");
    }

  }

  Future getTheCoordinates(@required String addressOrigem) async {


    var addresses = await Geocoder.local.findAddressesFromQuery(addressOrigem);

    var first = addresses.first;
    latitude = first.coordinates.latitude;
    longitude = first.coordinates.longitude;

  }


  //metodos da imagem
  Future<File> _settingModalBottomSheet(context, int option, CadInfosModel cadInfosModel) {
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

                          imageSelector(context, "gallery", cadInfosModel),
                          Navigator.pop(context),

                        }) : Container(),
                    option == 1 || option == 3 ?
                    new ListTile(
                      title: new Text('Camera'),
                      onTap: () => {

                        //_removeImage(_imageProfile, cadInfosModel),
                        imageSelector(context, "camera", cadInfosModel),
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

  Future<File> imageSelector(BuildContext context, String pickerType, CadInfosModel cadInfosModel) async {
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER

        File _provisory;
        final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery, imageQuality: 90);

        if(pickedFile!=null){
          _imageProfile = File(pickedFile.path);
          _imageProfile = await compressImage(_imageProfile);
          cadInfosModel.updateImageFile(_imageProfile);
        } else {
          _displaySnackBar(context, 'Nenhuma imagem selecionada');
        }

        break;

        /*
        _imageProfile = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 90);
        _imageProfile = await compressImage(_imageProfile);
        cadInfosModel.updateImageFile(_imageProfile);
        break;
         */

      case "camera": // CAMERA CAPTURE CODE

        _showCamera(context, cadInfosModel);
        break;
    }

    if (_imageProfile != null) {
      //print("You selected  image : " + imageFile.path);
      return _imageProfile;
      /*
      setState(() {
        //debugPrint("SELECTED IMAGE PICK   $imageFile");

      });

       */
    } else {
      print("Você não tirou uma foto");
    }
  }

  Future<File> _showCamera(BuildContext context, CadInfosModel cadInfosModel) async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    attachmentList.clear();

    final pickedImage = await Navigator.push(context,
        MaterialPageRoute(
          //builder: (context) => TakePicturePage(camera: camera)));
            builder: (context) => TakePicturePage(camera: camera)));


    attachmentList.add(File(pickedImage));
    _imageProfile = attachmentList.first;
    //imageCache.clear();
    //imageCache.clearLiveImages();
    _imageProfile = await compressImageEvenMore(_imageProfile);

    cadInfosModel.updateImageFile(_imageProfile);
    return _imageProfile;

  }

  void _removeImage(File pickedFile, CadInfosModel cadInfosModel) {

    //setstate removido
    attachmentList.remove(pickedFile);
    cadInfosModel.updateImageFile(null);

  }

  Future<File> compressImage(File file) async {

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
        minHeight: 500,
        quality: 70);

    return compressedImage;
  }

  //compressão maior para foto tirada com a camera...para ficarem em tamanhos semelhantes
  Future<File> compressImageEvenMore(File file) async {

    print('comprimindo');

    // Get file path
    // eg:- "Volume/VM/abcd.jpeg"
    //final filePath = file.absolute.path;
    _imgPath = file.absolute.path;

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
  //fim dos metodos da imagem


  void _prepareDataToSave(CadInfosModel cadInfosModel, String id, BuildContext context){

    double latlong;
    if(latitude==null && longitude==null){
      latlong = cadInfosModel.latlong;
    } else {
      latlong = latitude+longitude;
    }
    cadInfosModel.updateLatLong(latlong);
    cadInfosModel.updateApelido(cadInfosModel.apelidoController.text);
    cadInfosModel.updatephone(cadInfosModel.phoneController.text);
    cadInfosModel.updateaddress(cadInfosModel.addressFound);

    //salvar
    save(cadInfosModel, latitude, longitude, id, context);

  }

  void save(CadInfosModel cadInfosModel, double latitude, double longitude, String id, BuildContext context) async {


    if(cadInfosModel.imageFile==null){
      //significa que o usuario esta updatando mas nao mudou a foto
      saveData(id, latitude, longitude, cadInfosModel, context);
    } else {

      //salva a imagem
      final String _path = 'profile/${id.toString()}';

      firebase_storage.Reference firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child(_path);
      firebase_storage.UploadTask uploadTask = firebaseStorageRef.putFile(cadInfosModel.imageFile);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask.snapshot; //talvez aqui seja um erro. No site era uploadTask.onComplete
      taskSnapshot.ref.getDownloadURL().then((value) async {

        //_uploadedImageProfileFileURL = value;
        cadInfosModel.updateimage(value);
        saveData(id, latitude, longitude, cadInfosModel, context);

        //salva no shared.
        int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
        SharedPrefsUtils().savePageOneInfoNew(cadInfosModel, pageDone);

      });


      /*
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(_path);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(cadInfosModel.imageFile);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      taskSnapshot.ref.getDownloadURL().then((value) async {

            //_uploadedImageProfileFileURL = value;
            cadInfosModel.updateimage(value);
            saveData(id, latitude, longitude, cadInfosModel, context);

            //salva no shared.
            int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
            SharedPrefsUtils().savePageOneInfoNew(cadInfosModel, pageDone);

          });

       */

    }


  }

  Future<void> saveData(String uid, double latitude, double longitude, CadInfosModel cadInfosModel, BuildContext context) async {

    void _onSucess1(){
      cadInfosModel.updateIsLoading(false);
      cadInfosModel.updatePageClearChache(2); //limpa variaveis para proxima página
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadInfoProfs()));
    }

    void _onFailure1(){
      cadInfosModel.updateIsLoading(false);
      _displaySnackBar(context, 'Ocorreu um erro. As informações não foram salvas.');
    }

    await FirestoreServices().saveUserInfo(uid, latitude, longitude, cadInfosModel.apelido, cadInfosModel.phone, cadInfosModel.addressFound, cadInfosModel.image, true, () {_onSucess1();}, () {_onFailure1();});

    /*
    await FirestoreServices().saveUserInfo(uid, latitude, longitude, _apelidoController.text, _phoneController.text,
        adressFound, _uploadedImageProfileFileURL, () {_onSucess1(); }, () {_onFailure1(); });

     */
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
