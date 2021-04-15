import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

class HistoricModel extends Model {

  Query _query;
  double _total=0.0;
  String _filter;
  bool totalWasCalculated=false;
  String textInformingExibition='Exibindo este mês';
  bool firstLoad=true;

  void restoreModel(){
    _query=null;
    _total=0.0;
    _filter=null;
    totalWasCalculated=false;
    textInformingExibition='Exibindo tudo';
    firstLoad=true;
  }


  void updateQuery (Query value, bool shouldNotify){
    _query = value;
    if(shouldNotify==true){
      notifyListeners();
    }
  }
  get query=>_query;


  void updateTotal(double value, bool shouldNotify){
    _total = value;
    if(shouldNotify==true){
      notifyListeners();
    }
  }
  get total=>_total;

  void notifyListenersOfTotal(){
    notifyListeners();
  }

  void updateFiler(String value){
    _filter = value;
    notifyListeners();
  }
  get filter=>_filter;

}