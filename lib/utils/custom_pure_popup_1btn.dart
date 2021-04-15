import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class CustomPurePopup1Btn extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String title;
  String text;
  String btn1Text;

  CustomPurePopup1Btn(this.heightPercent,this.widthPercent, this.title, this.text, this.btn1Text);


  @override
  Widget build(BuildContext context) {

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        title: Text(''),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          width: widthPercent,
          child: contentBox(context),
        ),
      ),
    );


  }

  contentBox(context){
    return Container(
      color: Colors.white,
      height: heightPercent,
      width: widthPercent,
      child: Column(
        children: [
          //imagem
          Center(
            child: Container(
              height: heightPercent*0.3,
              width: widthPercent*0.7,
              child: Image.asset('images/popup/alert.png', fit: BoxFit.contain,),
            ),
          ),
          //titulo
          Text(title, textAlign: TextAlign.center ,style: TextStyle(fontWeight: FontWeight.bold ,color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.5))),
          SizedBox(height: heightPercent*0.05,),

          Padding(
              child: Text(text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0)),
          SizedBox(height: heightPercent*0.10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: widthPercent*0.4,
                height: heightPercent*0.06,
                child: RaisedButton(
                  color: CustomColors.yellow,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(btn1Text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                ),
              )  ,
            ],
          ),


        ],
      ),
    );
  }

}


/*
class CustomPurePopup1Btn extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String title;
  String text;
  String btn1Text;

  CustomPurePopup1Btn(this.heightPercent,this.widthPercent, this.title, this.text, this.btn1Text);


  @override
  Widget build(BuildContext context) {

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        title: Text(''),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          width: widthPercent,
          child: contentBox(context),
        ),
      ),
    );


  }

  contentBox(context){
    return Stack(
      children: [

        Positioned(
          top: heightPercent*0.02,
          left: 0.0,
          right: 0.0,

          child: Container(
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.white, 0.0, 4.0),
            child: Column(
              children: [
                SizedBox(height: heightPercent*0.06,),
                Padding(padding: EdgeInsets.all(10.0,),
                  child: Text(text, style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                ),
                SizedBox(height: heightPercent*0.05,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: widthPercent*0.50,

                      height: heightPercent*0.06,
                      child: FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(btn1Text, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      ),
                    ),

                  ],
                )

              ],
            ),
          ),
        ),


        //barra titulo
        Positioned(
          top: 0.0,
          left: widthPercent*0.1,
          right: widthPercent*0.1,
          child: Container(
            alignment: Alignment.center,
            width: widthPercent*0.50,
            height: heightPercent*0.07,
            decoration: WidgetsConstructor().myBoxDecoration(CustomColors.blue, CustomColors.blue, 2.0, 4.0),
            child: Text(title, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
          ),
        ),

      ],
    );
  }

}


 */