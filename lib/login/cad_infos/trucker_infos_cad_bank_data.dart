import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:scoped_model/scoped_model.dart';

class TruckerInfosCadBankData extends StatefulWidget {
  @override
  _TruckerInfosCadBankDataState createState() => _TruckerInfosCadBankDataState();
}

class _TruckerInfosCadBankDataState extends State<TruckerInfosCadBankData> {

  final _scaffoldKey = GlobalKey<ScaffoldState>(); //para snackbar
  ScrollController _scrollController;

  double heightPercent;
  double widthPercent;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _digitController = TextEditingController();
  TextEditingController _agencyController = TextEditingController();
  TextEditingController _otherBankController = TextEditingController();

  var _maskFormatterCpf = new MaskTextInputFormatter(mask: '###.###.###-##)', filter: { "#": RegExp(r'[0-9]') });
  final TextEditingController _cpfController = TextEditingController();

  String AcountType='cc';
  String bank;

  FocusNode _otherBankFocusNode;



  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _otherBankFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _otherBankFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double heightPercent = MediaQuery.of(context).size.height;
    double widthPercent = MediaQuery.of(context).size.width;


    return ScopedModelDescendant<UserModel>(
      builder: (BuildContext context, Widget widget, UserModel userModel){

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(centerTitle: true, title: Text("Informações bancárias")),
          body: Padding(
            padding: EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [

                  WidgetsConstructor().makeText("Estas informações são importantes para que você receba seus pagamentos", Colors.blue, 18.0, 25.0, 20.0, 'center'),

                  _textField(_nameController, "Nome do titular da conta", widthPercent*0.85),
                  SizedBox(height: 20.0,),
                  _textFieldNumberOnly(_agencyController, "Agência", widthPercent*0.85),
                  SizedBox(height: 20.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10.0,),
                      _textFieldNumberOnly(_accountController, "Conta - dígito", widthPercent*0.45),
                      Text(' _ '),
                      _textFieldNumberOnly(_digitController, "", widthPercent*0.15),
                    ],
                  ),
                  SizedBox(height: 10.0,),
                  _buildRadioOptionsBankTypeSelection(context),
                  WidgetsConstructor().makeText("Informe o banco", Colors.blue, 16.0, 15.0, 10.0, 'center'),
                  Container(
                    decoration: WidgetsConstructor().myBoxDecoration(Colors.grey[100], Colors.blue, 2.0, 7.0),
                    child: _buildRadioOptionsBank(context),
                  ),
                  bank == 'outro'
                      ? _textFieldWithFocusNode(_otherBankController, 'Informe o banco', widthPercent*0.85, _otherBankFocusNode)
                      :Container(),
                  SizedBox(height: 20.0,),
                  Container(
                    width: widthPercent*0.85,
                    child: WidgetsConstructor().makeEditTextForPhoneFormat(_cpfController, 'CPF do titular', _maskFormatterCpf),
                  ),
                  SizedBox(height: 20.0,),
                  WidgetsConstructor().makeButtonWithCallBack(Colors.blue, Colors.white, widthPercent*0.90, 80.0, 2.0, 4.0, 'Finalizar cadastro', Colors.white, 18.0, () {_onClickFinalize();}),
                  SizedBox(height: 20.0,),

                ],
              ),
            ),
          )
        );
      },
    );
  }

  void _onClickFinalize(){

    if(_nameController.text.isEmpty){
      _displaySnackBar(context, 'Informe o nome', Colors.red);
    } else if(_agencyController.text.isEmpty){
      _displaySnackBar(context, 'Informe a agência', Colors.red);
    } else if(_accountController.text.isEmpty){
      _displaySnackBar(context, 'Informe o número da conta', Colors.red);
    } else if(_digitController.text.isEmpty){
      _displaySnackBar(context, 'Informe o dígito verificador da conta', Colors.red);
    } else if(bank==null){
      _displaySnackBar(context, 'Informe o banco', Colors.red);
    } else if(bank=='outro' && _otherBankController.text.isEmpty){
      _displaySnackBar(context, 'Informe o banco', Colors.red);
    } else if(_cpfController.text.isEmpty){
      _displaySnackBar(context, 'Informe o CPF do titular da conta', Colors.red);
    } else {
      //chegou
      print('foi')
    }

  }


  //Widgets
  Widget _buildRadioOptionsBankTypeSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RadioButton(
          description: "Conta corrente",
          value: "cc",
          groupValue: AcountType,
          onChanged: (value) => setState(
                () => AcountType = value,
          ),
        ),
        RadioButton(

          description: "Poupança",
          value: "poup",
          groupValue: AcountType,
          onChanged: (value) => setState(
                () => AcountType = value,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOptionsBank(BuildContext context) {
    return Column(
      children: [

        Row(
          children: <Widget>[
            Flexible(
              flex: 1,
              child: RadioButton(
              description: "Banco do Brasil",
              value: "bb",
              groupValue: bank,
              onChanged: (value) => setState(
                    () => bank = value,
              ),
            ),),
            Flexible(
              flex: 1,
              child: RadioButton(

                description: "Bradesco",
                value: "bradesco",
                groupValue: bank,
                onChanged: (value) => setState(
                      () => bank = value,
                ),
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
                  groupValue: bank,
                  onChanged: (value) => setState(
                        () => bank = value,
                  ),
                ),),

            Flexible(
              flex: 1,
              child: RadioButton(

              description: "Itaú",
              value: "itau",
              groupValue: bank,
              onChanged: (value) => setState(
                    () => bank = value,
              ),
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
              groupValue: bank,
              onChanged: (value) => setState(
                    () => bank = value,
              ),
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
                    groupValue: bank,
                    onChanged: (value)=> setState(
                          () => bank = value,
                    ),
                  ),
                )
            ),


          ],
        ),

      ],
    );
  }

  Widget _textFieldNumberOnly(TextEditingController controller, String labelTxt, double width){

    return Container(
      width: width,
      child: TextField(

          controller: controller,
          decoration: InputDecoration(labelText: labelTxt),
          keyboardType: TextInputType.number
      ),
    );

  }

  Widget _textField(TextEditingController controller, String labelTxt, double width){

    return Container(
      width: width,
      child: TextField(
        controller: controller,
        //focusNode: focusNode,
        decoration: InputDecoration(labelText: labelTxt),
      ),
    );
  }

  Widget _textFieldWithFocusNode(TextEditingController controller, String labelTxt, double width, FocusNode focusNode){

    return Container(
      width: width,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(labelText: labelTxt),
      ),
    );
  }

  void scrollToBottom() {
    final bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      bottomOffset,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  void scrollToDown() {
    final bottomOffset = _scrollController.position.pixels;
    _scrollController.animateTo(
      bottomOffset+150.0,
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  _displaySnackBar(BuildContext context, String msg, Color color) {

    final snackBar = SnackBar(
      content: Text(msg),
      backgroundColor: color,
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
