import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoped_model/scoped_model.dart';

class HomeModel extends Model {

  bool _showJobPopUp=false;
  bool _showJobConfirmationPopup=false;
  bool _showJobDeclinationPopup=false;
  bool _showJobCancelmentByUser=false;
  String _popUpsCode='no'; //codigo da popup. Por este código sabemos o que deverá serexibido na tela.
  bool _isLoading=false; //exibe o loading na tela
  double _distance; //mostra a distância entre os endereços do frete que são exibidos no card
  bool _showCalendar=false; //exibe esconde o calendário com os eventos marcados no calendário
  bool _showDrawer=false;  //exibe esconde menu
  bool _showCustomPupUp1Btn=false; //n tinha uso...*************** ver se pode apagar tranquilo ao final
  bool _showCustomPopup=false; //verifica se precisa exibir a popup **************** ver se pode apagar no final...parecue sem uso
  String _popupStrTxt; //texto da popup costumizavel
  String _popupStrTitle;
  int _indexPosition;
  Query _query;
  bool _msgCanBeShown=false; //esta variavel vai marcar que a variavel _querysnapshot já tem dados e pode exibir a popup
  bool _userGotMsg=false; //vai impedir do usuario receber mensagens repetidas

  bool _userIsLoggedIn;  //se for null vai fazer verificação
  void updateUserIsLoggedIn(bool value){
    _userIsLoggedIn = value;
    notifyListeners();
  }
  get UserIsLoggedIn=>_userIsLoggedIn;

  void updateshowJobPopUp(bool value){
    _showJobPopUp=value;
    notifyListeners();
  }
  get showJobPopUp=>_showJobPopUp;

  void updateshowJobConfirmationPopup(bool value){
    _showJobConfirmationPopup=value;
    notifyListeners();
  }
  get showJobConfirmationPopup=>_showJobConfirmationPopup;

  void updateshowJobDeclinationPopup(bool value){
    _showJobDeclinationPopup=value;
    notifyListeners();
  }
  get showJobDeclinationPopup=>_showJobDeclinationPopup;

  void updateshowJobCancelmentByUser(bool value){
    _showJobCancelmentByUser=value;
    notifyListeners();
  }
  get showJobCancelmentByUser=>_showJobCancelmentByUser;

  void updatepopUpsCode(String value){
    updateUserGotMsg(true);
    _popUpsCode=value;
    notifyListeners();
  }
  get popUpsCode=>_popUpsCode;

  void setIsLoading(bool value){
    _isLoading=value;
    notifyListeners();
  }
  get isLoading=>_isLoading;

  void updateDistance(double value){
    _distance = value;
    notifyListeners();
  }
  get distance=>_distance;

  void updateShowCalendar(bool value){
    _showCalendar = value;
    notifyListeners();
  }
  get showCalendar=>_showCalendar;

  void updateShowDrawer(){
    _showDrawer=!_showDrawer;
    notifyListeners();
  }
  get showDrawer=>_showDrawer;

  void updateShowCustomPupUp1Btn(bool value){
    _showCustomPupUp1Btn = value;
    notifyListeners();
  }
  get showCustomPupUp1Btn=>_showCustomPupUp1Btn;

  void updateShowCustomPupup(bool value){
    _showCustomPopup = value;
    notifyListeners();
  }
  get showCustomPopup=>_showCustomPopup;

  void updatePopupStrTxt(String value){
    _popupStrTxt = value;
    notifyListeners();
  }
  get popupStrTxt=>_popupStrTxt;

  void updatePopupStrTitle(String value){
    _popupStrTitle=value;
    notifyListeners();
  }
  get popupStrTitle=>_popupStrTitle;

  void updateIndexPosition(int value){
    _indexPosition = value;
    notifyListeners();
  }
  get indexPosition=>_indexPosition;

  void updateQuery (Query value){
    _query = value;
    notifyListeners();
  }
  get query=>_query;

  void updateMsgCanBeShown(bool value){
    _msgCanBeShown = value;
    notifyListeners();
  }
  get msgCanBeShown=>_msgCanBeShown;

  void updateUserGotMsg(bool value){
    _userGotMsg = value;
  }
  get userGotMsg=>_userGotMsg;


}