import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fretes_go_freteiro/utils/widgets_constructor.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class TakePictureFromCnh extends StatefulWidget {

  final CameraDescription camera;
  TakePictureFromCnh({@required this.camera});

  @override
  _TakePictureFromCnhState createState() => _TakePictureFromCnhState();
}

class _TakePictureFromCnhState extends State<TakePictureFromCnh> {

  final fileName = DateTime.now().millisecondsSinceEpoch.toString();
  var vidPath;
  CameraController _cameraController;
  Future<void> _initializeCameraControllerFuture;
  int _selectedIndex = 0;
  bool _start = false;
  bool _isRec = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 1) {
        _start = !_start;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _cameraController =
        CameraController(widget.camera, ResolutionPreset.medium);

    _initializeCameraControllerFuture = _cameraController.initialize();
    _fileInit();
  }



  void _fileInit() async {
    vidPath = join((await getTemporaryDirectory()).path, '${fileName}.mp4');
  }

  void _takePicture(BuildContext context) async {
    try {
      await _initializeCameraControllerFuture;

      if (_selectedIndex == 0) {
        final imgPath =
        join((await getTemporaryDirectory()).path, '${fileName}.png');
        await _cameraController.takePicture(imgPath);
        Navigator.pop(context, imgPath);
      } else {
        if (_start) {
          await _cameraController.startVideoRecording(vidPath);
          setState(() {
            _start = !_start;
            _isRec = !_isRec;
          });
        } else {
          _cameraController.stopVideoRecording();
          setState(() {
            _isRec = !_isRec;
          });
          Navigator.pop(context, vidPath);
        }
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: _initializeCameraControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_cameraController);
              } else {
                return Center(child: CircularProgressIndicator(backgroundColor: Colors.green,));
              }
            },
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  child:   _selectedIndex == 1 ? _isRec == true?Icon(Icons.pause, color: Colors.white):Icon(Icons.play_arrow, color: Colors.white) : Icon(Icons.camera, color: Colors.white),
                  onPressed: () {
                    _takePicture(context);
                  },
                ),
              ),
            ),
          ),

          Positioned(
              top: 0.0,
              left: 25.0,
              right: 25.0,
              child: Container(
                child: WidgetsConstructor().makeText("Tire foto da sua CNH nesta posição", Colors.white, 16.0, 10.0, 10.0, "center"),
                height: 200, width: 200,)

          ),


        ],
      ),

    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }


}

