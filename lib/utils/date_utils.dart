import 'package:date_format/date_format.dart';

//needs to add date_format: ^1.0.8 to pubspec.yaml

class DateUtils {

  String convertStringFromDate(DateTime strDate) {
    final newDate = formatDate(strDate, [dd, '/', mm, '/', yyyy]);
    return newDate;
  }

  DateTime convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate.split('/').reversed.join());
    return todayDate;
  }

  String returnThisMonthAndYear() {
    var monthYear = DateTime.now();
    final formatted = formatDate(monthYear, [mm, '/', yyyy]);
    return formatted;
  }

  String _returnMeXDaysInFutureFromThisDate(String strDate, int daysToAdd){
    DateTime theDate = convertDateFromString(strDate);
    var thirtyDaysFromNow = theDate.add(new Duration(days: daysToAdd));
    String formattedDate = convertStringFromDate(thirtyDaysFromNow);
    return formattedDate;
  }

  bool doesThisDateIsBigger (String date1, String date2){
    var date1Formatted = convertDateFromString(date1);
    var date2Formatted = convertDateFromString(date2);

    final difference = date2Formatted.difference(date1Formatted).inDays;

    if (difference>=0){
      return false; //data 1 é maior
    } else {
      return true; //data2 é maior
    }
  }

  bool doesThisDateIsBiggerThanToday (String date){

    var dateFormatted = convertDateFromString(date);
    var today = DateTime.now();

    final difference = today.difference(dateFormatted).inDays;
    print (date);
    print("Difference é "+difference.toString());

    if(difference>=0){
      return false;  //data informada é maior do que hoje
    } else {
      return true; //data informada é menor do que hoje
    }


  }

  String giveMeTheYear(DateTime date){

    return date.year.toString();
  }

  String giveMeTheMonth(DateTime date){

    return date.month.toString();
  }

  String giveMeTheDateToday(){
    var today = DateTime.now();
    return convertStringFromDate(today);
  }

  DateTime addDaysToDate(DateTime originalDate, int daysToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day+daysToAdd);
    return newDate;
  }

  DateTime subDaysFromDate(DateTime originalDate, int daysToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day-daysToSub);
    return newDate;
  }

  DateTime addMonthsToDate(DateTime originalDate, int monthToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month+monthToAdd, originalDate.day);
    return newDate;
  }

  DateTime subMonthsFromDate(DateTime originalDate, int monthsToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month-monthsToSub, originalDate.day);
    return newDate;
  }

  DateTime addYeasToDate(DateTime originalDate, int yearsToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year+yearsToAdd, originalDate.month, originalDate.day);
    return newDate;
  }

  DateTime subYearsFromDate(DateTime originalDate, int yearsToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year-yearsToSub, originalDate.month, originalDate.day);
    return newDate;
  }

  DateTime addHourToDate(DateTime originalDate, int hoursToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour+hoursToAdd, originalDate.minute);
    return newDate;
  }

  DateTime subHoursFromDate(DateTime originalDate, int hoursToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour-hoursToSub, originalDate.minute);
    return newDate;
  }

  DateTime addMinutesToDate(DateTime originalDate, int minutesToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute+minutesToAdd);
    return newDate;
  }

  DateTime subMinutesFromDate(DateTime originalDate, int minutesToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute-minutesToSub);
    return newDate;
  }

  DateTime addMinutesAndHoursFromStringToAdate(DateTime originalDate, String time){

    //time needs to be in hh:mm format
    DateTime newDate;
    var ar = time.split(":"); //cria um array
    int hourNew = int.parse(ar.first); //hora
    int minuteNew = int.parse(ar.last); //minuto
    newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, hourNew, minuteNew);
    return newDate;

  }

}
