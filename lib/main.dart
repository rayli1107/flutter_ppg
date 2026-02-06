import 'dart:async';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_ppg/home_screen.dart';
import 'package:flutter_ppg/models/brightness_detection_model.dart';
import 'package:flutter_ppg/screens/account/account.dart';
import 'package:flutter_ppg/screens/ppg/ppg_screen.dart';
import 'package:flutter_ppg/services/ppg_session_manager.dart';
import 'package:flutter_ppg/tab_types.dart';

Future<void> main() async {
    // Ensure that plugin services are initialized so that `availableCameras()`
    // can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    PPGSessionManager.registerAdapters();

    // Initialize SessionManager for PPG session storage
    await PPGSessionManager.instance.initialize();

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

    static int getIndexByType(MainAppScreenTabType type) {
        return MainAppScreen.tabs.indexOf(type);
    }

    @override
    State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {

    int _tabIndex = 0;

    void _onRoute(MainAppScreenTabType type) {
        int index = MainAppScreen.getIndexByType(type);
        if (index < 0) {
            return;
        }

        _onDestinationSelected(index);
    }

    void _onDestinationSelected(int tabIndex) {
        if (_tabIndex == tabIndex) {
            return;
        }
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
                    MainAppScreenTabType.Home => HomeScreen(
                        onRoute: _onRoute),
                    MainAppScreenTabType.HeartRate => PPGScreenWidget(
                        cameraDescription: widget.cameraDescription),
                    MainAppScreenTabType.Exercise => PPGScreenWidget(
                        cameraDescription: widget.cameraDescription),
                    MainAppScreenTabType.Account => const AccountScreen()
                }
            )
        );
    }
}