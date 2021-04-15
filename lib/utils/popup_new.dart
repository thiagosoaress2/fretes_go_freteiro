import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';
import 'package:responsive_flutter/responsive_flutter.dart';



//ATENCAO ESTE CODIOG FUCNIONA MAS NAO ESTA EM USO

class PopupNew extends StatelessWidget {
  bool oneButton;
  String title;
  double heightPercent;
  double widthPercent;
  String text;
  String btn1Text;
  String btn2Text;
  VoidCallback closeCallBack;
  VoidCallback actionCallBack;
  PopupNew(this.heightPercent, this.widthPercent,this.oneButton, this.title, this.text, this.btn1Text, this.btn2Text, this.closeCallBack, this.actionCallBack);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Container(
            color: Colors.white,
            height: heightPercent*0.85,
            width: widthPercent*0.9,
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
                oneButton == false ?
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
                          Navigator.of(context).pop();
                        },
                        child: Text(btn1Text, textAlign: TextAlign.center ,style: TextStyle(color: CustomColors.blue, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                      ),
                    )  ,
                    SizedBox(width: widthPercent*0.03,),
                    Container(
                      width: widthPercent*0.4,
                      height: heightPercent*0.10,
                      child: RaisedButton(
                        color: CustomColors.yellow,
                        onPressed: (){
                          actionCallBack();
                        },
                        child: Text(btn2Text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                      ),
                    )  ,
                    SizedBox(width: widthPercent*0.03,),
                  ],
                )
                //um botão
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: widthPercent*0.4,
                      height: heightPercent*0.10,
                      child: RaisedButton(
                        color: CustomColors.yellow,
                        onPressed: (){
                          actionCallBack();
                        },
                        child: Text(btn2Text, textAlign: TextAlign.center ,style: TextStyle(color: Colors.white, fontSize: ResponsiveFlutter.of(context).fontSize(3.0))),
                      ),
                    )  ,
                  ],
                ),


              ],
            ),
          ),
        ),
      ),
    );

  }
}
