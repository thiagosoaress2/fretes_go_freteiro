import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/login/cad_infos/trucker_infos_cad.dart';
import 'package:fretes_go_freteiro/pages/home_page.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:responsive_flutter/responsive_flutter.dart';

class WidgetCadInfoAppBar extends StatelessWidget {
  double heightPercent;
  double widthPercent;
  String title;
  String backText;
  VoidCallback callback;
  WidgetCadInfoAppBar(this.heightPercent, this.widthPercent, this.title, this.backText, this.callback);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthPercent*0.97,
      height: heightPercent*0.13,
      child: Row(
        children: [

          Container(
            width: widthPercent*0.12,
            child: Column(

              children: [
                IconButton(icon: Icon(Icons.arrow_back, color: CustomColors.blue, size: 40.0,), onPressed: (){

                  callback();

                }),

                Padding(
                    child: Text(backText, style: TextStyle(color: Colors.grey[300], fontSize: ResponsiveFlutter.of(context).fontSize(1.7))),
                    padding: EdgeInsets.only(left: widthPercent*0.02)),




              ],
            ),
          ),

          Container(
            height: heightPercent*0.08,
            alignment: Alignment.topLeft,
            width: widthPercent*0.88,
            padding: EdgeInsets.only(left: widthPercent*0.08),
            child: Text(title, style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(2.5))),
          ),


        ],
      ),
    );
  }
}
