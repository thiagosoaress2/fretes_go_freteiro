import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/camera_widgets/take_picture_page.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TruckerInfosCadCarInfo extends StatefulWidget {
  @override
  _TruckerInfosCadCarInfoState createState() => _TruckerInfosCadCarInfoState();
}


/*    O QUE FALTA

dados do carro como placa,
foto do carro e
foto do motorista

 */

class _TruckerInfosCadCarInfoState extends State<TruckerInfosCadCarInfo> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  ScrollController _scrollController; //scroll screen to bottom

  List<File> attachmentList = [];
  File _imageCar;
  String _uploadedImageCarFileURL;

  String carro;


  @override
  Widget build(BuildContext context) {


    double heightPercent = MediaQuery.of(context).size.height;
    double widthPercent = MediaQuery.of(context).size.width;


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(centerTitle: true, title: Text("Informações do veículo")),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 25.0,),

              WidgetsConstructor().makeText("Quase pronto. Agora só precisamos das informações do seu veículo.", Colors.blue, 15.0, 0.0, 15.0, "center"),

              WidgetsConstructor().makeText("Escolher modelo", Colors.blue, 17.0, 20.0, 10.0, "center"),

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
                          title: "Como escolher",
                          desc: "Escolha o veículo que melhor se encaixa com o seu. Lembre-se, exagerar no tamanho pode acabar gerando más avaliações dos usuários.",
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

              SizedBox(height: 40.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "carroca";
                        carro = "carroca";
                        scrollToBottom();
                      });
                    },
                    //color: carSelected=="carroca" ? Colors.red : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Carroça (sem motor)", Colors.blue, 15.0)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "pickupP";
                        carro = "pickupP";
                        scrollToBottom();
                      });

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Pickup pequena", Colors.blue, 15.0)
                      ],
                    ),
                  )


                ],
              ), //primeira linha dos caminhoes para escolher
              SizedBox(height: 30.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "pickupG";
                        carro = "pickupG";
                        scrollToBottom();
                      });

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Pickup grande", Colors.blue, 15.0)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "kombiA";
                        carro = "kombiA";
                        scrollToBottom();
                      });

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Kombi aberta", Colors.blue, 15.0)
                      ],
                    ),
                  )


                ],
              ), //primeira linha dos caminhoes para escolher
              SizedBox(height: 30.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "caminhaoPA";
                        carro = "caminhaoPA";
                        scrollToBottom();
                      });

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Caminhão pequeno aberto", Colors.blue, 15.0)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "kombiF";
                        carro = "kombiF";
                        scrollToBottom();
                      });

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Kombi fechada", Colors.blue, 15.0)
                      ],
                    ),
                  )

                ],
              ), //segunda linha dos caminhoes para escolher
              SizedBox(height: 30.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "caminhaoBP";
                        carro = "caminhaoBP";
                        scrollToBottom();
                      });

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Caminhão baú pequeno", Colors.blue, 15.0)
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      setState(() {
                        //carSelected = "caminhaoBG";
                        carro = "caminhaoBG";
                        scrollToBottom();
                      });

                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(height: 50.0, width: widthPercent*0.25, child: Image.asset("images/carrinhobaby.jpg"),),
                        WidgetsConstructor().makeSimpleText("Caminhão baú grande", Colors.blue, 15.0)
                      ],
                    ),
                  )


                ],
              ), //terceira linha dos caminhoes para escolher
              SizedBox(height: 30.0,),

              carro != null
                  ? WidgetsConstructor().makeText("Veículo selecionado", Colors.blue, 15.0, 0.0, 15.0, "center")
                  : Container(),

              carro != null
                  ? Image.asset('images/caminhaozinho.jpg', width: 250, height: 250,)
                  : Container(),


              SizedBox(height: 100.0,),


              WidgetsConstructor().makeText("Foto do seu veículo", Colors.blue, 18.0, 0.0, 20.0, "center"),

              //linha com foto do veículo
              Row(
                  children:[

                    SizedBox(width: widthPercent*0.05,),
                    GestureDetector(
                      child: Container(

                          width: 200, height: 200,
                          child: _imageCar == null
                              ? Image.asset("images/carrinhobaby.jpg", fit: BoxFit.fill)
                              : Image.file(_imageCar, fit: BoxFit.fill,)
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
                        _settingModalBottomSheet(context, 1);
                      },
                    ),

                  ]
              ),

              SizedBox(height: 40.0,),

              GestureDetector(
                onTap: (){
                  //aqui precisa salvar as coisas no bd e shared
                  /*
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => TruckerInfosCadCarInfo()));

                   */
                  _displaySnackBar(context, "Acabou o cad");
                },
                child: WidgetsConstructor().makeButton(Colors.blue, Colors.blue, widthPercent*0.75, 50.0, 2.0, 4.0, "Próximo", Colors.white, 16.0),
              ),

              SizedBox(height: 40.0,),
            ],
          ),
        ),
      ),
    );
  }



  void _showCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    final pickedImage = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicturePage(camera: camera)));
    setState(() {
      attachmentList.add(File(pickedImage));
      _imageCar = attachmentList.first;


      //uploadFile();
    });
    // return result;
  }

  void _removeImage(File pickedFile) {
    setState(() {
      attachmentList.remove(pickedFile);
    });
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('freteiros_cnh'+'uid');
    //.child('freteiros_cnh/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_imageCar);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        _uploadedImageCarFileURL = fileURL;
        print(_uploadedImageCarFileURL); //isto salva no bd do user
      });
    });
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":

      /// GALLERY IMAGE PICKER
        _imageCar = await ImagePicker.pickImage(
            source: ImageSource.gallery, imageQuality: 90);
        break;

      case "camera": // CAMERA CAPTURE CODE

        _showCamera();
        break;
    }

    if (_imageCar != null) {
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

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
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
