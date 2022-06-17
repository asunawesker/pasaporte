import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pasaporte/views/login.dart';
import 'package:pasaporte/views/take_photo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/http_service.dart';
import 'card_picture..dart';

late String? token;

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  final HttpService _httpUploadService = HttpService();
  late CameraDescription _cameraDescription;
  List<String> _images = [];
  var imagePath = "";

  @override
  void initState() {
    super.initState();
    availableCameras().then((cameras) {
      final camera = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.back)
          .toList()
          .first;
      setState(() {
        _cameraDescription = camera;
      });
    }).catchError((err) {
      print(err);
    });
  }

  Future<void> presentAlert(BuildContext context,
      {String title = '', String message = '', Function()? ok}) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text('$title'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text('$message'),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  // style: greenText,
                ),
                onPressed: ok != null ? ok : Navigator.of(context).pop,
              ),
            ],
          );
        });
  }

  void presentLoader(BuildContext context, {
    String text = 'Aguarde...',
    bool barrierDismissible = false,
    bool willPop = true})
  {
    showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (c) {
        return WillPopScope(
          onWillPop: () async {
            return willPop;
          },
          child: AlertDialog(
            content: Container(
              child: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 20.0,
                  ),
                  Text(
                    text,
                    style: TextStyle(fontSize: 18.0),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void logout() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("token");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Escanear documentos"),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffb621132),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
            onPressed: ()  => logout(),
          )
        ],
      ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  height: size.width * 1.4,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CardPicture(
                          onTap: () async {
                            final String? imagePath =
                            await Navigator.of(context)
                                .push(MaterialPageRoute(
                                builder: (_) => TakePhoto(
                                  camera: _cameraDescription,
                                )
                            )
                          );
                          if (imagePath != null) {
                            setState(() {
                              _images.add(imagePath);
                              this.imagePath = imagePath;
                            });
                          }
                          }
                        ),
                        // CardPicture(),
                        // CardPicture(),
                      ] +
                          _images
                              .map((String path) => CardPicture(
                            imagePath: path,
                          ))
                              .toList()),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffb621132),
                                borderRadius: BorderRadius.circular(25)),
                                child: RawMaterialButton(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  onPressed: () async {
                                    presentLoader(context, text: 'Enviando imagen');
                                    await _httpUploadService
                                        .uploadPhotos(_images);
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _images.clear();
                                    });
                                  },
                                  child: Center(
                                      child: Text(
                                        'Enviar Fotografía',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.bold),
                                      )),
                                )),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ));
  }
}