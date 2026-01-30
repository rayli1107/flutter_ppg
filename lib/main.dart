import 'dart:async';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:flutter_ppg/home_screen.dart';
import 'package:flutter_ppg/models/brightness_detection_model.dart';

import 'package:flutter_ppg/models/ppg_model.dart';
import 'package:flutter_ppg/screens/ppg/ppg_screen.dart';


enum _TabType {
    Home,
    HeartRate,
    Exercise,
    Account
}

Future<void> main() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();
    CameraDescription? cameraDescription = null;
    try {
        cameraDescription = (await availableCameras()).first;
    } catch (e) {
        print(e);
    }

    runApp(
        MaterialApp(
            theme: ThemeData.dark(),
            home: MainAppScreen(
                cameraDescription: cameraDescription!,
                brightnessDetectionConfig: BrightnessDetectionConfig(),
                ppgModelConfig: PPGModelConfig(),
            )
        ),
    );
}

class MainAppScreen extends StatefulWidget {
    const MainAppScreen({
        super.key,
        required this.cameraDescription,
        required this.brightnessDetectionConfig,
        required this.ppgModelConfig,
    });

    final CameraDescription? cameraDescription;
    final BrightnessDetectionConfig brightnessDetectionConfig;
    final PPGModelConfig ppgModelConfig;

    @override
    State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {

    int _tabIndex = _TabType.Home.index;

    void _onDestinationSelected(int tabIndex) {
        setState(() {_tabIndex = tabIndex; });
    }

    NavigationBar _buildNavgationBar() {
        List<Widget> destinations = [];
        _TabType.values.forEach((tab) {
            switch (tab) {
                case _TabType.Home:
                    destinations.add(
                        NavigationDestination(
                            icon: Icon(Icons.home),
                            label: "首頁",
                        )
                    );
                    break;

                case _TabType.HeartRate:
                    destinations.add(
                        NavigationDestination(
                            icon: Icon(Icons.favorite),
                            label: "心跳",
                        )
                    );
                    break;

                case _TabType.Exercise:
                    destinations.add(
                        NavigationDestination(
                            icon: Icon(Icons.self_improvement),
                            label: "呼吸",
                        )
                    );
                    break;

                case _TabType.Account:
                    destinations.add(
                        NavigationDestination(
                            icon: Icon(Icons.person),
                            label: "個人",
                        )
                    );
                    break;
            }
        });

        return NavigationBar(
            onDestinationSelected: _onDestinationSelected,
            indicatorColor: Colors.amber,
            selectedIndex: _tabIndex,
            destinations: destinations);
    }


    @override
    Widget build(BuildContext context) {
        return SafeArea(
            child: Scaffold(
                bottomNavigationBar: _buildNavgationBar(),
                body: switch (_TabType.values[_tabIndex]) {
                    _TabType.Home => HomeScreen(),
                    _TabType.HeartRate => PPGScreen(
                        cameraDescription: widget.cameraDescription,
                        brightnessDetectionConfig: widget.brightnessDetectionConfig,
                        ppgModelConfig: widget.ppgModelConfig,
                        windowTimeframeSeconds: 10),
                    _TabType.Exercise => PPGScreen(
                        cameraDescription: widget.cameraDescription,
                        brightnessDetectionConfig: widget.brightnessDetectionConfig,
                        ppgModelConfig: widget.ppgModelConfig,
                        windowTimeframeSeconds: 10),
                    _TabType.Account => PPGScreen(
                        cameraDescription: widget.cameraDescription,
                        brightnessDetectionConfig: widget.brightnessDetectionConfig,
                        ppgModelConfig: widget.ppgModelConfig,
                        windowTimeframeSeconds: 10)
                }
            )
        );
    }
}