import 'dart:async';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:flutter_ppg/home_screen.dart';
import 'package:flutter_ppg/models/brightness_detection_model.dart';
import 'package:flutter_ppg/screens/ppg/ppg_screen.dart';


enum MainAppScreenTabType {
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
            theme: ThemeData.light(),
            home: MainAppScreen(
                cameraDescription: cameraDescription,
                brightnessDetectionConfig: BrightnessDetectionConfig())
        ),
    );
}

class MainAppScreen extends StatefulWidget {

    const MainAppScreen({
        super.key,
        required this.cameraDescription,
        required this.brightnessDetectionConfig
    });

    static const List<MainAppScreenTabType> tabs = [
        MainAppScreenTabType.Home,
        MainAppScreenTabType.HeartRate,
        MainAppScreenTabType.Account
    ];

    final CameraDescription? cameraDescription;
    final BrightnessDetectionConfig brightnessDetectionConfig;

    @override
    State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {

    int _tabIndex = 0;

    void _onDestinationSelected(int tabIndex) {
        setState(() {_tabIndex = tabIndex; });
    }

    NavigationBar _buildNavgationBar() {
        List<Widget> destinations = [];
        for (int i = 0; i < MainAppScreen.tabs.length; ++i) {
            switch (MainAppScreen.tabs[i]) {
                case MainAppScreenTabType.Home:
                    destinations.add(NavigationDestination(
                        icon: Icon(Icons.home),
                        label: "首頁"));

                case MainAppScreenTabType.HeartRate:
                    destinations.add(NavigationDestination(
                        icon: Icon(Icons.favorite),
                        label: "心跳"));

                case MainAppScreenTabType.Exercise:
                    destinations.add(NavigationDestination(
                        icon: Icon(Icons.self_improvement),
                        label: "呼吸"));

                case MainAppScreenTabType.Account:
                    destinations.add(NavigationDestination(
                        icon: Icon(Icons.person),
                        label: "個人"));
            }
        }
        
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
                body: switch (MainAppScreen.tabs[_tabIndex]) {
                    MainAppScreenTabType.Home => HomeScreen(),
                    MainAppScreenTabType.HeartRate => PPGScreen(
                        cameraDescription: widget.cameraDescription),
                    MainAppScreenTabType.Exercise => PPGScreen(
                        cameraDescription: widget.cameraDescription),
                    MainAppScreenTabType.Account => PPGScreen(
                        cameraDescription: widget.cameraDescription)
                }
            )
        );
    }
}