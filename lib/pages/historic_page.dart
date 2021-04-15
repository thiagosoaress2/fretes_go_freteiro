import 'package:after_layout/after_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/models/historic_model.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/services/firestore_services.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/date_utils.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';


class HistoricPage extends StatefulWidget {
  String userId;
  HistoricPage(this.userId);

  @override
  _HistoricPageState createState() => _HistoricPageState();
}

double _total=0.0;

bool firstLoad=true;

class _HistoricPageState extends State<HistoricPage> with AfterLayoutMixin {
  HistoricModel historicModel = HistoricModel();

  double heightPercent;

  double widthPercent;

  List<QueryDocumentSnapshot> globalMaps;
  int querySize=0;

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModel(
      model: historicModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Histórico'),
          centerTitle: true,
          automaticallyImplyLeading: true,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){

            historicModel.firstLoad=true;
            historicModel.updateFiler(null);
            historicModel.textInformingExibition='Exibindo informações deste mês';
            firstLoad=true;

            Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => HomePage()));
          },),
        ),
        body: _landPage(),
      ),
    );
  }

  Widget _landPage(){
    return ScopedModelDescendant<HistoricModel>(
      builder: (BuildContext context, Widget widget, HistoricModel historicModel){

        if(historicModel.firstLoad==true){
          historicModel.firstLoad=false;

          //aplica o filtro pra exibir apenas este mês
          String _hoje = DateServices().giveMeTheDateToday(); //pega data de hoje
          String _esteMes = retorneOmesDestaData(_hoje); //pega apenas o mês
          historicModel.updateFiler(_esteMes);

          _updateQueryInFirstLoad();
        }


        return Container(
            padding: EdgeInsets.all(10.0),
            width: widthPercent,
            height: heightPercent,
            color: Colors.white,
            child: Column(
              children: [
                Container(height: heightPercent*0.10,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(historicModel.textInformingExibition),
                          Container(
                            width: widthPercent*0.40,
                            child: RaisedButton(
                              onPressed: (){
                                _total=0;

                                //_selectDate(context);
                                /*
                                historicModel.textInformingExibition='Exibindo este mês';
                                String _hoje = DateUtils().giveMeTheDateToday(); //pega data de hoje
                                String _esteMes = retorneOmesDestaData(_hoje); //pega apenas o mês
                                historicModel.updateFiler(_esteMes);
                                firstLoad=true; //libera update valor para atualizar a tela
                                //updateValor();
                                 */


                                showMonthPicker(
                                  context: context,
                                  firstDate: DateTime(DateTime.now().year - 1, 5),
                                  lastDate: DateTime(DateTime.now().year + 1, 9),
                                  initialDate: selectedDate ?? DateTime.now(),
                                  locale: Locale("pt"),
                                ).then((date) {
                                  if (date != null) {

                                    String _dataStr = DateServices().convertStringFromDate(date); //pega data de hoje
                                    print('data em STR');
                                    print(_dataStr);
                                    String _esteMes = retorneOmesDestaData(_dataStr); //pega apenas o mês
                                    historicModel.updateFiler(_esteMes);
                                    //firstLoad=true; //libera update valor para atualizar a tela
                                    historicModel.textInformingExibition='Exibindo $_dataStr';
                                    recalculateTotal(historicModel);

                                    /*
                                    setState(() {
                                      selectedDate = date;
                                    });

                                     */
                                  }
                                });

                              },
                              child: Text('Escolher mês', style: TextStyle(color: Colors.white),),
                              color: CustomColors.blue,
                            ),
                          )
                        ],
                      )
                    ],
                  )
                  ,),
                StreamBuilder<QuerySnapshot>(
                  stream: historicModel.query.snapshots(),
                  builder: (context, stream){

                    if (stream.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (stream.hasError) {
                      return Center(child: Text(stream.error.toString()));
                    } else if(stream.connectionState == ConnectionState.active){

                      QuerySnapshot querySnapshot = stream.data;
                      querySize = querySnapshot.docs.length;
                      globalMaps = querySnapshot.docs;

                      _total=0.0;


                      return querySnapshot.size == 0
                          ? Center(child: Text("Nada para exibir"),)
                          : Expanded(
                        child: ListView.builder(
                            itemCount: querySnapshot.size,
                            itemBuilder: (context, index){

                              Map<String, dynamic> map = querySnapshot.docs[index].data();

                              //mes que ta sendo chamado
                              String _mes = retorneOmesDestaData(querySnapshot.docs[index]['data']);

                              if(querySize==index+1 && firstLoad==true){
                                //updateValor();
                                firstLoad=false;
                                historicModel.notifyListenersOfTotal();

                              }

                              return historicModel.filter == null
                                  ?   _linhaDoExtrato(map, historicModel)
                                  : _mes == historicModel.filter
                                  ?  _linhaDoExtrato(map, historicModel)
                                  : Container();

                            }
                        ),
                      );

                    }

                  },
                ),
                Container(
                  height: heightPercent*0.10,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:'),
                      //Text(_total.toStringAsFixed(2)),
                      Text(historicModel.total.toStringAsFixed(2).replaceAll('.', ',')),
                    ],
                  ),
                )
              ],
            )
        );

      },
    );
  }

  Widget _linhaDoExtrato(Map map, HistoricModel historicModel){

    print('total antes de somar'+_total.toString());
    _total = _total+map['preco'];
    print('total agora é '+_total.toString());
    historicModel.updateTotal(_total, false);

    String _valor = map['preco'].toStringAsFixed(2).replaceAll('.', ',');
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(map['data']),
          Text('R\$${_valor}'),
        ],
      ),
      children: [
        Text('Horário: ${map['hora']}'),
        Divider(),
        Text('Origem: ${map['origem']}'),
        SizedBox(height: 10.0,),
        Text('Destino: ${map['destino']}'),
      ],

    );


  }

  String retorneOmesDestaData(String data){
    var string = data;
    List<String> list =  string.split('/');
    print(list);
    print(list[1]);
    return list[1];
  }

  String retorneMesEmString(String mes){
    print('mes '+mes);
    if(mes=='01'){
      print('entrou em janeiro');
      return 'janeiro';
    } else if(mes=='02'){
      return 'fevereiro';
    } else if(mes=='03'){
      return 'março';
    } else if(mes=='04'){
      return 'abril';
    } else if(mes=='05'){
      return 'maio';
    } else if(mes=='06'){
      return 'junho';
    } else if(mes=='07'){
      return 'julho';
    } else if(mes=='08'){
      return 'agosto';
    } else if(mes=='09'){
      return 'setembro';
    } else if(mes=='10'){
      return 'outubro';
    } else if(mes=='11'){
      return 'novembro';
    } else{
      return 'dezembro';
    }
  }

  void recalculateTotal(HistoricModel historicModel){
    double _newTotal=0.0;

    int cont=0;
    while(cont<globalMaps.length){

      if(historicModel.filter==null){
        //sem filtro, soma tudo
        _newTotal = globalMaps[cont]['preco']+_newTotal;
      } else {
        //com filtro, só soma se for o mes selecionado
        String _mes = retorneOmesDestaData(globalMaps[cont]['data']);
        print(_mes);
        if(_mes==historicModel.filter){
          _newTotal= globalMaps[cont]['preco']+_newTotal;
        }
      }

      cont++;
    }

    _total = _newTotal;
    historicModel.updateTotal(_newTotal, true);

    //setState(() {
      //_total = _newTotal;
    //});


  }

  void _updateQueryInFirstLoad(){
    historicModel.updateQuery(FirebaseFirestore.instance.collection(FirestoreServices.historicPathTrucker).doc(widget.userId).collection('historico').where('freteiro', isEqualTo: widget.userId).orderBy('data'), false);
  }

  void updateValor(){

    Future.delayed(Duration(seconds: 5)).then((value) {
      if(firstLoad==true){
        firstLoad=false;
        setState(() {

        });
      }
    });


  }

  @override
  void afterFirstLayout(BuildContext context) {


  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }


}


/*
class HistoricPage extends StatefulWidget {
  String userId;
  HistoricPage(this.userId);

  @override
  _HistoricPageState createState() => _HistoricPageState();
}

  double _total=0.0;

 bool firstLoad=true;

class _HistoricPageState extends State<HistoricPage> with AfterLayoutMixin {
  HistoricModel historicModel = HistoricModel();

  double heightPercent;

  double widthPercent;

  List<QueryDocumentSnapshot> globalMaps;
  int querySize=0;

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return ScopedModel(
        model: historicModel,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Histórico'),
            centerTitle: true,
            automaticallyImplyLeading: true,
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){

              historicModel.firstLoad=true;
              historicModel.updateFiler(null);
              historicModel.textInformingExibition='Exibindo tudo';
              firstLoad=true;

              Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => HomePage()));
            },),
          ),
          body: _landPage(),
        ),
    );
  }

  Widget _landPage(){
    return ScopedModelDescendant<HistoricModel>(
      builder: (BuildContext context, Widget widget, HistoricModel historicModel){

        if(historicModel.firstLoad==true){
          historicModel.firstLoad=false;
          _updateQueryInFirstLoad();
        }


        return Container(
            padding: EdgeInsets.all(10.0),
            width: widthPercent,
            height: heightPercent,
            color: Colors.white,
            child: Column(
              children: [
                Container(height: heightPercent*0.10,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(historicModel.textInformingExibition),
                        Container(
                          width: widthPercent*0.20,
                          child: RaisedButton(
                            onPressed: (){
                              _total=0;
                              historicModel.textInformingExibition='Exibindo este mês';
                              String _hoje = DateUtils().giveMeTheDateToday(); //pega data de hoje
                              String _esteMes = retorneOmesDestaData(_hoje); //pega apenas o mês
                              //String _esteMes = retorneMesEmString(_hoje);
                              //_esteMes = retorneMesEmString(_esteMes);
                              //print('_esteMesFinal '+_esteMes);
                              historicModel.updateFiler(_esteMes);
                              //recalculateTotal(historicModel);
                              firstLoad=true; //libera update valor para atualizar a tela
                              //updateValor();


                            },
                            child: Text('Este mês'),
                            color: CustomColors.blue,
                          ),
                        )
                      ],
                    )
                  ],
                )
                  ,),
                StreamBuilder<QuerySnapshot>(
                  stream: historicModel.query.snapshots(),
                  builder: (context, stream){

                    if (stream.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (stream.hasError) {
                      return Center(child: Text(stream.error.toString()));
                    } else if(stream.connectionState == ConnectionState.active){

                      QuerySnapshot querySnapshot = stream.data;
                      querySize = querySnapshot.docs.length;
                      globalMaps = querySnapshot.docs;

                      _total=0.0;


                      return querySnapshot.size == 0
                          ? Center(child: Text("Nada para exibir"),)
                          : Expanded(
                        child: ListView.builder(
                            itemCount: querySnapshot.size,
                            itemBuilder: (context, index){

                              Map<String, dynamic> map = querySnapshot.docs[index].data();

                              //mes que ta sendo chamado
                              String _mes = retorneOmesDestaData(querySnapshot.docs[index]['data']);

                              if(querySize==index+1 && firstLoad==true){
                                //updateValor();
                                firstLoad=false;
                                historicModel.notifyListenersOfTotal();

                              }

                              return historicModel.filter == null
                              ?   _linhaDoExtrato(map, historicModel)
                              : _mes == historicModel.filter
                                ?  _linhaDoExtrato(map, historicModel)
                                  : Container();

                            }
                        ),
                      );

                    }

                  },
                ),
                Container(
                  height: heightPercent*0.10,
                  child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:'),
                      //Text(_total.toStringAsFixed(2)),
                      Text(historicModel.total.toStringAsFixed(2).replaceAll('.', ',')),
                    ],
                  ),
                )
              ],
            )
        );

        },
    );
  }

  Widget _linhaDoExtrato(Map map, HistoricModel historicModel){

    print('total antes de somar'+_total.toString());
    _total = _total+map['preco'];
    print('total agora é '+_total.toString());
    historicModel.updateTotal(_total, false);

    String _valor = map['preco'].toStringAsFixed(2).replaceAll('.', ',');
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(map['data']),
          Text('R\$${_valor}'),
        ],
      ),
      children: [
        Text('Horário: ${map['hora']}'),
        Divider(),
        Text('Origem: ${map['origem']}'),
        SizedBox(height: 10.0,),
        Text('Destino: ${map['destino']}'),
      ],

    );


  }

  String retorneOmesDestaData(String data){
    var string = data;
    List<String> list =  string.split('/');
    print(list);
    print(list[1]);
    return list[1];
  }

  String retorneMesEmString(String mes){
    print('mes '+mes);
    if(mes=='01'){
      print('entrou em janeiro');
      return 'janeiro';
    } else if(mes=='02'){
      return 'fevereiro';
    } else if(mes=='03'){
      return 'março';
    } else if(mes=='04'){
      return 'abril';
    } else if(mes=='05'){
      return 'maio';
    } else if(mes=='06'){
      return 'junho';
    } else if(mes=='07'){
      return 'julho';
    } else if(mes=='08'){
      return 'agosto';
    } else if(mes=='09'){
      return 'setembro';
    } else if(mes=='10'){
      return 'outubro';
    } else if(mes=='11'){
      return 'novembro';
    } else{
      return 'dezembro';
    }
  }

  void recalculateTotal(HistoricModel historicModel){
    double _newTotal=0.0;

    int cont=0;
    while(cont<globalMaps.length){

      if(historicModel.filter==null){
        //sem filtro, soma tudo
        _newTotal = globalMaps[cont]['preco'];
      } else {
        //com filtro, só soma se for o mes selecionado
        String _mes = retorneOmesDestaData(globalMaps[cont]['data']);
        print(_mes);
        if(_mes==historicModel.filter){
          _newTotal= globalMaps[cont]['preco'];
        }
      }

      cont++;
    }
    _total = _newTotal;

  }

  void _updateQueryInFirstLoad(){
    historicModel.updateQuery(FirebaseFirestore.instance.collection(FirestoreServices.historicPathTrucker).doc(widget.userId).collection('historico').where('freteiro', isEqualTo: widget.userId).orderBy('data'), false);
  }

  void updateValor(){

    Future.delayed(Duration(seconds: 5)).then((value) {
      if(firstLoad==true){
        firstLoad=false;
        setState(() {

        });
      }
    });


  }

  @override
  void afterFirstLayout(BuildContext context) {


  }
}


 */