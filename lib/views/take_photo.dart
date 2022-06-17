import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePhoto extends StatefulWidget {
  final CameraDescription? camera;

  TakePhoto({this.camera});

  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera as CameraDescription,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  Future<XFile?> takePicture() async {
    if (_controller.value.isTakingPicture) {
      return null;
    }

    try {
      XFile file = await _controller.takePicture();
      return file;
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Tomar fotografía"),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffb621132),
      ),
      floatingActionButton: SizedBox(
        height: 100.0,
        width: 100.0,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Color(0xffb621132),
            onPressed: () async {
              final file = await takePicture();
              Navigator.of(context).pop(file != null ? file.path : null);
            },
            child: Icon(Icons.camera_alt, color: Color(0xffbffffff)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
                children: <Widget>[
                  Center(
                    child:Transform.scale(
                        scale: 1 /
                            (_controller.value.aspectRatio  * mediaSize.aspectRatio),
                        child: CameraPreview(_controller)
                    ),)]);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}