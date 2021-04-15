import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class CustomPurePopup extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String title;
  String text;
  String btn1Text;
  String btn2Text;
  int progress;
  VoidCallback okCallBack;

  CustomPurePopup(this.heightPercent,this.widthPercent, this.title, this.text, this.btn1Text, this.btn2Text, this.progress, this.okCallBack);


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
      height: heightPercent*0.9,
      width: widthPercent*0.9,
      child: Stack(
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
                  Text('Você já completou', style: TextStyle(color: Colors.black, fontSize: ResponsiveFlutter.of(context).fontSize(1.3))),
                  Padding(padding: EdgeInsets.all(10.0,),
                    child:
                    Stack(
                      children: [
                        Container(height: heightPercent*0.03, decoration: WidgetsConstructor().myBoxDecoration(Colors.grey[300], Colors.grey[300], 1.0, 45.0), ),
                        //obs: widthPercent*0.60 representa 100 da barra completa.
                        //obs 2 - progress==99 significa 0 e progress==4 significa 100%
                        Container(height: heightPercent*0.03, width: progress==99 ? 0.0 : progress==1 ? widthPercent*0.15 : progress==2 ? widthPercent*0.30 : progress==3 ? widthPercent*0.45 : widthPercent*0.60, decoration: WidgetsConstructor().myBoxDecoration(CustomColors.yellow, CustomColors.yellow, 1.0, 45.0), ),
                        Container(
                          alignment: Alignment.center,
                          width: widthPercent, child: Text(progress==99 ? '0%' : progress==1 ? '25%' : progress==2 ? '50%' : progress==3 ? '75%' : '100%', style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(1.8))),)
                      ],
                    ),
                  ),
                  SizedBox(height: heightPercent*0.05,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: widthPercent*0.30,

                        height: heightPercent*0.05,
                        child: FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(btn1Text, style: TextStyle(color: Colors.black54, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                        ),
                      ),
                      Container(
                        width: widthPercent*0.35,
                        color: CustomColors.yellow,
                        height: heightPercent*0.08,
                        child: FlatButton(
                          onPressed: () {
                            //onClickOkBtn();
                            okCallBack();
                          },
                          child: Text(btn2Text, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                        ),
                      )
                    ],
                  )

                ],
              ),
            ),
          ),

          /*
        //botao
        Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    flex: 1,
                    child: Container(
                      child: FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(btn1Text, style: TextStyle(color: Colors.black54, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      ),
                    )),
                Divider(height: heightPercent*0.10, color: Colors.deepOrangeAccent,),
                Flexible(
                    flex: 1,
                    child: Container(
                      child: FlatButton(
                        onPressed: () {
                          //onClickOkBtn();
                          okCallBack();
                        },
                        child: Text(btn2Text, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.0))),
                      ),
                    )),
              ],
            )
        ),


         */

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
      ),
    );
  }

}
