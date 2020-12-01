class AvaliationClass {

  String userName;
  String userId;
  double userRate;
  int avaliations;
  double newRate=0;

  AvaliationClass(this.userName, this.userId, this.userRate, this.avaliations);

  AvaliationClass.Empty();

  double calculateAvaliation(double value, int avaliations, double _userRate){

    double _totalRate = _userRate+value;
    int _totalAvaliations = avaliations+1;
    return _totalRate/_totalAvaliations;
  }


}