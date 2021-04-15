import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/utils/colors.dart';

class WidgetCadInfoBar extends StatelessWidget {
  int position;
  double heightPercent;
  double widthPercent;
  WidgetCadInfoBar(this.position, this.heightPercent, this.widthPercent);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: heightPercent*0.12,
      child: Stack(
        children: [

          Positioned(
            top: heightPercent*0.025,
            left: 2.0,
            right: 2.0,
            bottom: heightPercent*0.01,
            child: Container(
              height: heightPercent*0.07,
              width: widthPercent,
              decoration:
              BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
            ),
          ),

          Positioned(
              top: 0.0,
              left: 4.0,
              right: 4.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ball(1),
                  ball(2),
                  ball(3),
                  ball(4),
                ],
              )),
        ],
      ),
    );
  }

  Widget ball(int positionOfTheBall) {
    return Container(
      height: heightPercent*0.08,
      width: widthPercent*0.20,
      decoration:
      BoxDecoration(
        shape: BoxShape.circle,
        color: position==positionOfTheBall ? CustomColors.blue : Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 3.0, //                   <--- border width here
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 1,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],

      ),

      child:
      Icon(
        positionOfTheBall==1 ?Icons.person_pin_circle_rounded
            : positionOfTheBall==2 ? Icons.wysiwyg
            : positionOfTheBall==3 ? Icons.car_rental
            : Icons.attach_money,
         color: position==positionOfTheBall ?  Colors.white : CustomColors.blue,
        size: position==positionOfTheBall ? 35.0 : 25.0,),

    );
  }
}
