
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_car_info.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad_info_profs.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadInfoBar.dart';
import 'package:fretes_go_freteiro/login/cad_infos/widget_cadinfo_appbar.dart';
import 'package:fretes_go_freteiro/models/cad_infos_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path/path.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

ScrollController _scrollController;
FocusNode _otherBankFocusNode;
class TruckerInfosCadBankData extends StatelessWidget {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  double heightPercent;
  double widthPercent;
  var _maskFormatterCpf = new MaskTextInputFormatter(mask: '###.###.###-##)', filter: { "#": RegExp(r'[0-9]') });
  var _maskFormatterCNPJ = new MaskTextInputFormatter(mask: '###.###.###/####-##)', filter: { "#": RegExp(r'[0-9]') });
  String uid;

  @override
  Widget build(BuildContext context) {

    _scrollController = ScrollController();
    _otherBankFocusNode = FocusNode();

    if(heightPercent==null){
      heightPercent = MediaQuery.of(context).size.height;
      widthPercent = MediaQuery.of(context).size.width;
    }

    return ScopedModelDescendant<CadInfosModel>(
      builder: (BuildContext context, Widget widget, CadInfosModel cadInfosModel){

        return ScopedModelDescendant<UserModel>(
          builder: (BuildContext context, Widget widget, UserModel userModel){
            uid = userModel.Uid;

            if(cadInfosModel.firstLoad==true){
              cadInfosModel.firstLoad=false;
              _loadUsersInfoFromShared(cadInfosModel, uid, context);
            }

            VoidCallback closeCallBack = () => {
              Navigator.of(context).pop(),
              cadInfosModel.updatePageClearChache(4),
              Navigator.push(context, MaterialPageRoute(builder: (context) => TruckerInfosCadCarInfo()))
            };

            return Scaffold(
              key: _scaffoldKey,
              body: Container(
                width: widthPercent,
                height: heightPercent,
                color: Colors.white,
                child: Stack(
                  children: [


                    //corpo
                    Positioned(
                      top: heightPercent*0.27,
                      left: 10.0,
                      right: 10.0,
                      bottom: 0.0,
                      child: Container(
                        height: heightPercent*0.87,
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: ListView(
                            controller: _scrollController,
                            children: [

                              //texto inicial
                              Container(
                                width: widthPercent,
                                child: Text('Estas informações são importantes para que você receba seus pagamentos.', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(1.7))),
                              ),
                              //textField Nome
                              Container(
                                width: widthPercent,
                                child: TextField(

                                    controller: cadInfosModel.nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Nome completo do títular',

                                    ),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.text
                                ),
                              ),
                              SizedBox(height: heightPercent*0.03,),
                              Container(
                                width: widthPercent,
                                child: Text('Tipo de documento da conta', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                              ),
                              SizedBox(height: heightPercent*0.03,),
                              Container(
                                decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.blue, 1.0, 7.0),
                                width: widthPercent,
                                child: _buildRadioOptionsCpfOrCnpj(context, cadInfosModel),
                              ),
                              cadInfosModel.cpfOrCnpj=='cpf' ?
                              Container(
                                width: widthPercent,
                                child: TextField(

                                    controller: cadInfosModel.cpfController,
                                    decoration: InputDecoration(
                                      labelText: 'CPF do títular',

                                    ),
                                    inputFormatters: [_maskFormatterCpf],
                                    autocorrect: false,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number
                                ),
                              )
                                  : Container(
                                width: widthPercent,
                                child: TextField(

                                    controller: cadInfosModel.cnpjController,
                                    decoration: InputDecoration(
                                      labelText: 'CNPJ do títular',

                                    ),
                                    inputFormatters: [_maskFormatterCNPJ],
                                    autocorrect: false,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number
                                ),
                              ),
                              SizedBox(height: heightPercent*0.03,),
                              //Linha com agencia e conta
                              Row(
                                children: [
                                  //agencia
                                  Container(
                                    width: widthPercent*0.30,
                                    child: TextField(

                                        controller: cadInfosModel.agencyController,
                                        decoration: InputDecoration(
                                          labelText: 'Agência',

                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number
                                    ),
                                  ),
                                  SizedBox(width: widthPercent*0.04,),
                                  //conta
                                  Container(
                                    width: widthPercent*0.33,
                                    child: TextField(

                                        controller: cadInfosModel.accountController,
                                        decoration: InputDecoration(
                                          labelText: 'Conta - dígito',

                                        ),
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number
                                    ),
                                  ),
                                  //traço divisor
                                  Container(
                                    padding: EdgeInsets.only(top: 15.0),
                                    alignment: Alignment.bottomCenter,
                                    child: Text(' _ '),
                                  ),
                                  //digito
                                  Container(
                                    width: widthPercent*0.08,
                                    child: TextField(

                                        controller: cadInfosModel.digitController,
                                        decoration: InputDecoration(
                                          labelText: ' ',

                                        ),
                                        textInputAction: TextInputAction.done,
                                        keyboardType: TextInputType.number
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(height: heightPercent*0.020,),
                              //radio button conta corrente ou poupança
                              _buildRadioOptionsBankTypeSelection(context, cadInfosModel),
                              SizedBox(height: heightPercent*0.020,),
                              //titulo Banco
                              Container(
                                width: widthPercent,
                                child: Text('Banco', style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                              ),
                              SizedBox(height: heightPercent*0.005,),
                              //radio boxes com o nome dos bancos
                              Container(
                                decoration: WidgetsConstructor().myBoxDecoration(Colors.grey[100], Colors.blue, 1.0, 7.0),
                                child: _buildRadioOptionsBank(context, cadInfosModel),
                              ),
                              cadInfosModel.bank == 'outro'
                                  ? _textFieldWithFocusNode(cadInfosModel.otherBankController, 'informe o nome do banco', widthPercent*0.50)
                                  : Container(),
                              SizedBox(height: heightPercent*0.05,),
                              Padding(padding: EdgeInsets.all(15.0),
                              child: Container(
                                  width: widthPercent,
                                  alignment: Alignment.center,
                                  height: heightPercent*0.13,
                                  child: RaisedButton(
                                    child: Text('Finalizar', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
                                    color: CustomColors.yellow,
                                    onPressed: (){

                                      _onClickFinalize(cadInfosModel, context, userModel.Uid);

                                    },
                                  )
                              ),
                              ),


                            ],
                          ),
                        ),
                      ),
                    ),


                    //barra informando a posição no cad
                    Positioned(
                      top: heightPercent*0.16,
                      left: 0.0,
                      right: 0.0,
                      child: WidgetCadInfoBar(4, heightPercent, widthPercent),
                    ),
                    //appbar
                    Positioned(
                        top: heightPercent*0.05,
                        left: 0.0,
                        right: 0.0,
                        child: WidgetCadInfoAppBar(heightPercent, widthPercent, 'Informações bancárias', '', closeCallBack)
                    ),
                  ],
                ),
              ),
            );
          },
        );

      },
    );
  }

  void _onClickFinalize(CadInfosModel cadInfosModel, BuildContext context, String uid){

    if(cadInfosModel.nameController.text.isEmpty){
      _displaySnackBar(context, 'Informe o nome do títular da conta');
    } else if(cadInfosModel.agencyController.text.isEmpty){
      _displaySnackBar(context, 'Informe a agência');
    } else if(cadInfosModel.accountController.text.isEmpty){
      _displaySnackBar(context, 'Informe o número da conta');
    } else if(cadInfosModel.digitController.text.isEmpty){
      _displaySnackBar(context, 'Informe o dígito verificador da conta');
    } else if(cadInfosModel.bank==null){
      _displaySnackBar(context, 'Informe o banco');
    } else if(cadInfosModel.bank=='outro' && cadInfosModel.otherBankController.text.isEmpty){
      _displaySnackBar(context, 'Informe o banco');
    } else if(cadInfosModel.cpfOrCnpj=='cpf' && cadInfosModel.cpfController.text.isEmpty) {
      _displaySnackBar(
          context, 'Informe o CPF do titular da conta');
    } else if(cadInfosModel.cpfOrCnpj!='cpf' && cadInfosModel.cnpjController.text.isEmpty) {
      _displaySnackBar(
          context, 'Informe o CNPJ do titular da conta');
    } else if(cadInfosModel.cpfOrCnpj=='cpf' && cadInfosModel.cpfController.text.length != 14){
      _displaySnackBar(context, 'Verifique o cpf. Formato inválido.');

    } else if(cadInfosModel.cpfOrCnpj!='cpf' && cadInfosModel.cnpjController.text.length != 19){
      _displaySnackBar(context, 'Verifique o Cnpj. Formato inválido.');

    } else {
      //chegou
      cadInfosModel.updateIsLoading(true);
      _saveData(cadInfosModel, context, uid);
    }

  }

  Future<void> _saveData(CadInfosModel cadInfosModel, BuildContext context, String uid) async {

    if (cadInfosModel.bank == 'outro') {
      cadInfosModel.updateBank(cadInfosModel.otherBankController.text);
    }

    String cpfOrCnpj;
    if(cadInfosModel.cpfOrCnpj=='cpf'){
      cpfOrCnpj = cadInfosModel.cpfController.text.replaceAll('.', '').trim();
      cpfOrCnpj = cpfOrCnpj.replaceAll('-', '').trim();
    } else {
      cpfOrCnpj = cadInfosModel.cnpjController.text.replaceAll('.', '').trim();
      cpfOrCnpj = cpfOrCnpj.replaceAll('-', '').trim();
      cpfOrCnpj = cpfOrCnpj.replaceAll('/', '').trim();
    }
    print(cpfOrCnpj);

    /*
      String cpf = cadInfosModel.cpfController.text.replaceAll('.', '').trim();
      cpf = cpf.replaceAll('-', '').trim();

     */

      //await FirestoreServices().saveBankInfo(cadInfosModel, cpf, uid, () {_onSucessUpdateData(cadInfosModel, context);}, () {_onFailureUpdateData(cadInfosModel, context);});
    await FirestoreServices().saveBankInfo(cadInfosModel, cpfOrCnpj, uid, () {_onSucessUpdateData(cadInfosModel, context);}, () {_onFailureUpdateData(cadInfosModel, context);});

  }

  Future<void> _onSucessUpdateData(CadInfosModel cadInfosModel, BuildContext context) async {
    //SharedPrefsUtils().updateAllInfoDone(4);

    bool isNew = true;
    int pageDone = await SharedPrefsUtils().checkIfAdditionalInfoIsDone();
    if (pageDone >= 4) { //se o dado existe
      isNew = false;
    }

    await FirestoreServices().placeUserInSearch(isNew, uid, () {_onSucessPlaceUserInSearch(cadInfosModel, isNew, context);}, () {_onFailurePlaceUserInSearch(cadInfosModel, context);}); //vai sair para a proxima pag

  }

    void _onFailureUpdateData(CadInfosModel cadInfosModel, BuildContext context){
    cadInfosModel.updateIsLoading(false);
      _displaySnackBar(context, "Ocorreu um erro. As informações não foram salvas. Verifique a sua conexão com a internet.");
    }


  void _onSucessPlaceUserInSearch(CadInfosModel cadInfosModel, bool isNew, BuildContext context){

    if(isNew==true){
      SharedPrefsUtils().updateAllInfoDone(4);
    }

    //chamar salvamentos 2
    //await SharedPrefsUtils().savePageThreeInfo(userModel); estes dados bancários nao ficarão no shared
    _displaySnackBar(context, "Pronto, tudo salvo. Agora é só esperar os clientes.");
    cadInfosModel.updateIsLoading(false);
    Future.delayed(Duration(seconds: 2)).then((value) {
      //abrir a proxima pagina
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    });

  }

  void _onFailurePlaceUserInSearch(CadInfosModel cadInfosModel, BuildContext context){
    cadInfosModel.updateIsLoading(false);
    _displaySnackBar(context, "Ocorreu um erro. As informações não foram salvas. Verifique a sua conexão com a internet.");
  }





  //carregando infos
  void _loadUsersInfoFromShared(CadInfosModel cadInfosModel, String id, BuildContext context) async {


    void _afterLoadPageFourUserInfos(){

      //agora salvar no shared para da proxima vez ele ler do shared e n precisar baixar. Caso tenha encontrado data no fb
      if(cadInfosModel.bank!=null){
        _updateInfoOnScreenToUser(cadInfosModel, context);
      }
      //retira a janela de loading
      cadInfosModel.updateInitialLoadIsDone(true);

    }

    await FirestoreServices().loadBankInfo(cadInfosModel, id, () {_afterLoadPageFourUserInfos();});

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



  //Widgets
  Widget _buildRadioOptionsCpfOrCnpj(BuildContext context, CadInfosModel cadInfosModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RadioButton(
          description: "CPF",
          value: "cpf",
          groupValue: cadInfosModel.cpfOrCnpj,
          onChanged: (value) => cadInfosModel.updateCpfOrCnpj(value),
        ),
        RadioButton(

          description: "CNPJ",
          value: "cnpj",
          groupValue: cadInfosModel.cpfOrCnpj,
          onChanged: (value) => cadInfosModel.updateCpfOrCnpj(value),
        ),
      ],
    );
  }

  Widget _buildRadioOptionsBankTypeSelection(BuildContext context, CadInfosModel cadInfosModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RadioButton(
          description: "Conta corrente",
          value: "cc",
          groupValue: cadInfosModel.acountType,
          onChanged: (value) => cadInfosModel.updateAcountType(value),
        ),
        RadioButton(

          description: "Poupança",
          value: "poup",
          groupValue: cadInfosModel.acountType,
          onChanged: (value) => cadInfosModel.updateAcountType(value),
        ),
      ],
    );
  }

  Widget _buildRadioOptionsBank(BuildContext context, CadInfosModel cadInfosModel) {
    return Column(
      children: [

        Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: RadioButton(
                description: "Bco do Brasil",
                value: "bb",
                groupValue: cadInfosModel.bank,
                onChanged: (value) => cadInfosModel.updateBank(value),
              ),),
            Flexible(
              flex: 1,
              child: RadioButton(

                description: "Bradesco",
                value: "bradesco",
                groupValue: cadInfosModel.bank,
                onChanged: (value) => cadInfosModel.updateBank(value),
              ),
            ),
          ],
        ),

        Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: RadioButton(
                description: "Caixa",
                value: "caixa",
                groupValue: cadInfosModel.bank,
                onChanged: (value) => cadInfosModel.updateBank(value),
              ),),

            Flexible(
              flex: 1,
              child: RadioButton(

                description: "Itaú",
                value: "itau",
                groupValue: cadInfosModel.bank,
                onChanged: (value) => cadInfosModel.updateBank(value),
              ),
            ),


          ],
        ),

        Row(
          children: <Widget>[
            Flexible(
                flex: 1,
                child: RadioButton(
                  description: "Santander",
                  value: "santander",
                  groupValue: cadInfosModel.bank,
                  onChanged: (value) => cadInfosModel.updateBank(value),
                )),
            Flexible(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    scrollToDown();
                    _otherBankFocusNode.requestFocus();
                  },
                  child: RadioButton(

                    description: "Outro",
                    value: "outro",
                    groupValue: cadInfosModel.bank,
                    onChanged: (value) => cadInfosModel.updateBank(value),
                  ),
                )
            ),


          ],
        ),

      ],
    );
  }

  Widget _textFieldWithFocusNode(TextEditingController controller, String labelTxt, double width){

    return Container(
      width: width,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: labelTxt),
      ),
    );
  }



  void scrollToDown() {
    final bottomOffset = _scrollController.position.pixels;
    Future.delayed(Duration(milliseconds: 200)).then((value){

      _scrollController.animateTo(
        bottomOffset+200.0,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );

    });

  }


}
