import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:responsive_flutter/responsive_flutter.dart';
import 'package:scoped_model/scoped_model.dart';

class WidgetLoadingScreeen extends StatelessWidget {
  String title;
  String text;
  WidgetLoadingScreeen(this.title, this.text);

  double heightPercent;
  double widthPercent;

  @override
  Widget build(BuildContext context) {

    heightPercent = MediaQuery.of(context).size.height;
    widthPercent = MediaQuery.of(context).size.width;

    return Container(
      width: widthPercent,
      height: heightPercent,
      color: Colors.black87.withOpacity(0.5),
      child: Center(
        child: Container(
            decoration: WidgetsConstructor().myBoxDecoration(Colors.white, CustomColors.blue, 3.0, 7.0),
            width: widthPercent*0.90,
            height: heightPercent*0.25,
            //color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: heightPercent*0.07,
                  child: Text(title, style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(2))),
                  width: widthPercent*0.89, color: CustomColors.blue,
                ),
                SizedBox(height: heightPercent*0.05,),
                Row(
                  children: [
                    SizedBox(width: widthPercent*0.05,),
                    CircularProgressIndicator(),
                    SizedBox(width: widthPercent*0.05,),
                    Container(
                      child: Text(text, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2))),
                    )
                  ],
                )
              ],
            )
        ),
      ),
    );
  }
}