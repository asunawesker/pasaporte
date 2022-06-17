import 'dart:io';
import 'package:flutter/material.dart';

class CardPicture extends StatelessWidget {
  CardPicture({this.onTap, this.imagePath});

  final Function()? onTap;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (imagePath != null) {
      return Card(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
          width: size.width * .80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            image: DecorationImage(
                fit: BoxFit.cover, image: FileImage(File(imagePath as String))),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffb621132),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3.0, 3.0),
                        blurRadius: 2.0,
                      )
                    ]
                ),
                /*child: IconButton(onPressed: (){
                  print("eliminando");
                  print(imagePath);
                }, icon: Icon(Icons.delete, color: Colors.white)),*/
              )
            ],
          ),
        ),
      );
    }

    return Card(
        elevation: 3,
        child: InkWell(
          onTap: this.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 25),
            alignment: Alignment.center,
            width: size.width * .80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toca para tomar fotografía',
                  style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                Icon(
                  Icons.photo_camera,
                  color: Color(0xffb621132),
                  size: 40.0,
                )
              ],
            ),
          ),
        ));
  }
}