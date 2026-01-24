import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ppg/models/test_data.dart';
import 'package:flutter_ppg/ppg_chart.dart';

Future<void> main() async {
    var testData = TestData();
    Timer.periodic(
      const Duration(milliseconds: 33),
      (timer) {
        var x = timer.tick / 30;
        testData.addPoint(x, sin(x));
      },
    );

    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    runApp(
        ChangeNotifierProvider(
            create: (context) => testData,
            child: MaterialApp(
            theme: ThemeData.dark(),
            home: PPGChart(windowSize: 10),
            /*                home: TakePictureScreen(
                        // Pass the appropriate camera to the TakePictureScreen widget.
                        camera: firstCamera,
                    ),*/
            ),
        ),
    );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.low,
      fps: 60,
    );

    var timeStart = DateTime.now();
    var sampleCount = 0;
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then(
      (_) => {
        _controller.startImageStream((CameraImage image) {
          print(
            'Image Format: ${image.format.group} planes ${image.planes.length} '
            'width ${image.width} height ${image.height}',
          );

          var plane = image.planes[0];
          var totalBrightness = 0;
          for (var y = 0; y < image.height; ++y) {
            for (var x = 0; x < image.width; ++x) {
              var index = y * plane.bytesPerRow + x;
              totalBrightness += plane.bytes[index];
            }
          }
          var brightness = totalBrightness / (image.width * image.height);
          ++sampleCount;
          if (sampleCount % 10 == 0) {
            var timeEnd = DateTime.now();
            var timeDiff = timeEnd.difference(timeStart);
            print(
              'brightness=$brightness, rate=${sampleCount / timeDiff.inSeconds}',
            );
          }
        }),
      },
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.stopImageStream();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
