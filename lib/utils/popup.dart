import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class Popup {

  Widget popupWithOneButton(context, heightPercent, widthPercent, String title, String text, String txtBtn, VoidCallback callback1){

    return Stack(
      children: [

        Container(
          width: widthPercent,
          height: heightPercent,
          color: Colors.black54.withOpacity(0.6),
        ),

        Positioned(
          top: heightPercent*0.03,
          left: widthPercent*0.05,
          right: widthPercent*0.05,
          bottom: heightPercent*0.02,
          child: Container(
            height: heightPercent*0.8,
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.white, 0.0, 5.0),
            child: Column(

              children: [
                Container(
                  width: widthPercent*0.9,
                  height: heightPercent*0.25,
                  decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellow, CustomColors.yellow, 1.0, 5.0),
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: widthPercent*0.9,
                      child: WidgetsConstructor().makeText(title, CustomColors.yellow, 25.0, 30.0, 20.0, 'center'),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                      child: Container(
                        height: heightPercent*0.30,
                        child: SingleChildScrollView(
                          child: WidgetsConstructor().makeText(text, Colors.black, 16.0, 0.0, 0.0, 'no'),
                        ),
                      ),
                    ),
                    Container(
                      height: 2.0,
                      width: widthPercent*0.9,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 0.02,),
                  ],
                ),

                Container(
                  child: FlatButton(
                    child: WidgetsConstructor().makeText(txtBtn, Colors.black, 18.0, 0.0, 0.0, 'center'),
                    onPressed: (){
                      callback1();
                    },
                  ),
                  color: Colors.white,
                  width: widthPercent*0.90,
                  height: heightPercent*0.10,
                ),
              ],
            ),
          ),),

        Positioned(
          top: heightPercent*0.03,
          left: 10.0,
          right: 10.0,
          child: Image.asset('images/popup/myboxes.png'),

        )


      ],
    );

  }


  Widget popupWithTwoButtons(context, heightPercent, widthPercent, String title, String text, String txtBtn, VoidCallback callback1, String txtBtn2, VoidCallback callback2){

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Container(
            color: Colors.white,
            height: heightPercent*0.85,
            width: widthPercent*0.9,
            child: ListView(
              children: [
                //imagem
                Center(
                  child: Container(
                    height: heightPercent*0.20,
                    width: widthPercent*0.50,
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
                //dois botões
                Row(
                  children: [
                    SizedBox(width: widthPercent*0.03,),
                    Container(
                      width: widthPercent*0.4,
                      height: heightPercent*0.10,
                      child: RaisedButton(
                        color: Colors.white,
                        onPressed: (){
                          callback1();
                        },
                        child: Text(txtBtn, textAlign: TextAlign.center ,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                      ),
                    )  ,
                    SizedBox(width: widthPercent*0.03,),
                    Container(
                      width: widthPercent*0.4,
                      height: heightPercent*0.10,
                      child: RaisedButton(
                        color: CustomColors.yellow,
                        onPressed: (){
                          callback2();
                        },
                        child: Text(txtBtn2, textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                      ),
                    )  ,
                    SizedBox(width: widthPercent*0.03,),
                  ],
                ),


              ],
            ),
          ),
        ),
      ),
    );

  }

  /*
  Widget popupWithTwoButtons(context, heightPercent, widthPercent, String title, String text, String txtBtn, VoidCallback callback1, String txtBtn2, VoidCallback callback2){

    return Stack(
      children: [

        Container(
          width: widthPercent,
          height: heightPercent,
          color: Colors.black54.withOpacity(0.6),
        ),

        Positioned(
          top: heightPercent*0.10,
          left: widthPercent*0.05,
          right: widthPercent*0.05,
          child: Container(
            height: heightPercent*0.8,
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, Colors.white, 0.0, 5.0),
            child: Column(

              children: [
                Container(
                  width: widthPercent*0.9,
                  height: heightPercent*0.25,
                  decoration: WidgetsConstructor().myBoxDecoration(CustomColors.brown, CustomColors.brown, 1.0, 5.0),
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: widthPercent*0.9,
                      child: WidgetsConstructor().makeText(title, CustomColors.brown, 25.0, 30.0, 20.0, 'center'),
                    ),
                    Padding(padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                      child: Container(
                        height: heightPercent*0.30,
                        child: SingleChildScrollView(
                          child: WidgetsConstructor().makeText(text, Colors.black, 16.0, 0.0, 0.0, 'no'),
                        ),
                      ),
                    ),
                    Container(
                      height: 2.0,
                      width: widthPercent*0.9,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 0.02,),
                  ],
                ),

                Row(
                  children: [

                    Container(
                      child: FlatButton(
                        child: WidgetsConstructor().makeText(txtBtn, Colors.black, 16.0, 0.0, 0.0, 'center'),
                        onPressed: (){
                          callback1();
                        },
                      ),
                      color: Colors.white,
                      width: widthPercent*0.44,
                      height: heightPercent*0.10,
                    ),

                    Container(
                      height: heightPercent*0.08,
                      width: 2.0,
                      color: Colors.grey[300],
                    ),

                    Container(
                      child: FlatButton(
                        child: WidgetsConstructor().makeText(txtBtn2, Colors.red, 16.0, 0.0, 0.0, 'center'),
                        onPressed: (){
                          callback2();
                        },
                      ),
                      color: Colors.white,
                      width: widthPercent*0.44,
                      height: heightPercent*0.10,
                    ),


                  ],
                )

              ],
            ),
          ),),

        Positioned(
          top: heightPercent*0.10,
          left: 10.0,
          right: 10.0,
          child: Image.asset('images/popup/myboxes.png'),

        )


      ],
    );

  }


   */
}