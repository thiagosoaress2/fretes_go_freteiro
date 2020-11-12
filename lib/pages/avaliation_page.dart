import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';

class AvaliationPage extends StatefulWidget {
  MoveClass moveClass = MoveClass();

  AvaliationPage(this.moveClass);

  @override
  _AvaliationPageState createState() => _AvaliationPageState();
}

class _AvaliationPageState extends State<AvaliationPage> {


  @override
  Widget build(BuildContext context) {

    print(widget.moveClass.userId);
    print('entrou em avaliation');

    return Container();
  }

}
