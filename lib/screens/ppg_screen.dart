import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_ppg/models/brightness_detection_model.dart';
import 'package:flutter_ppg/models/graph_data.dart';
import 'package:flutter_ppg/models/ppg_model.dart';
import 'package:flutter_ppg/screens/ppg/brightness_detection_config_widget.dart';
import 'package:flutter_ppg/screens/ppg/camera_preview_widget.dart';

enum _PPGScreenStatus {
    initializing,
    ready,
    buffering,
    sampling,
}

class PPGScreen extends StatefulWidget {
    const PPGScreen({
        super.key,
        required this.cameraDescription,
        required this.brightnessDetectionConfig,
        required this.ppgModelConfig,
        this.windowTimeframeSeconds = 10,
    });

    final CameraDescription cameraDescription;
    final BrightnessDetectionConfig brightnessDetectionConfig;
    final PPGModelConfig ppgModelConfig;
    final double windowTimeframeSeconds;

    @override
    State<PPGScreen> createState() => _PPGScreenState();
}

class _PPGScreenInitializingWidget extends StatelessWidget {
    const _PPGScreenInitializingWidget();

    @override
    Widget build(BuildContext context) {
        return const Center(
            child: CircularProgressIndicator(),
        );
    }
}

class _PPGScreenReadyWidget extends StatelessWidget {
    const _PPGScreenReadyWidget({
        required this.cameraController,
        required this.brightnessDetectionModel,
        required this.onToggleFlashlight,
    });

    final CameraController cameraController;
    final BrightnessDetectionModel brightnessDetectionModel;
    final Function(bool) onToggleFlashlight;

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Column(
                spacing: 10,
                children: [
                    CameraPreviewWidget(
                        cameraController: cameraController,
                        brightnessDetectionModel: brightnessDetectionModel),
                    Text('將手指覆蓋在手機鏡頭上'),
                    BrightnessDetectionConfigWidget(
                        config: brightnessDetectionModel.config,
                        onToggleFlashlight: onToggleFlashlight,
                    ),
                ],
            )
        );
    }
}

class _PPGScreenBufferingWidget extends StatelessWidget {
    const _PPGScreenBufferingWidget({
        required this.cameraController,
        required this.brightnessDetectionModel,
    });

    final CameraController cameraController;
    final BrightnessDetectionModel brightnessDetectionModel;
    @override
    Widget build(BuildContext context) {
        return Center(
            child: Column(
                spacing: 10,
                children: [ 
                    CameraPreviewWidget(
                        cameraController: cameraController,
                        brightnessDetectionModel: brightnessDetectionModel),
                    Text('讀取數據中...'),
                ]
            )
        );
    }
}

class _PPGScreenSamplingWidget extends StatelessWidget {
    const _PPGScreenSamplingWidget({
        required this.ppgModel,
        required this.graphData,
    });

    final PPGModel ppgModel;
    final GraphData graphData;

    @override
    Widget build(BuildContext context) {
        return Center(
            child: Column(
                spacing: 10,
                children: [ 
                    SizedBox(
                        width: 400,
                        height: 200,
                        child: LineChart(
                            LineChartData(
                                minX: graphData.minX,
                                maxX: graphData.maxX,
                                minY: graphData.minY,
                                maxY: graphData.maxY,
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.blue, width: 1),
                                ),
                                lineBarsData: [
                                    LineChartBarData(
                                        spots: graphData.getPoints(),
                                        isCurved: true,
                                        color: Colors.red,
                                        barWidth: 2,
                                        dotData: FlDotData(show: false),
                                    ),
                                ],
                            ),
                        ),
                    ),
                    if (ppgModel.heartRate > 0) ...[
                        Text('Current Heart Rate: ${ppgModel.heartRate} bpm'),
                        Text('Min Heart Rate: ${ppgModel.minHeartRate} bpm'),
                        Text('Max Heart Rate: ${ppgModel.maxHeartRate} bpm'),
                        Text('Average Heart Rate: ${ppgModel.averageHeartRate} bpm'),
                    ]
                ]
            )
        );
    }
}


class _PPGScreenState extends State<PPGScreen> {
    late CameraController _cameraController;
    late PPGModel _ppgModel;
    late GraphData _graphData;
    late BrightnessDetectionModel _brightnessDetectionModel;

    _PPGScreenStatus _status = _PPGScreenStatus.initializing;
    late DateTime _startTime;
    
    void _reset() {
        _ppgModel.reset();
        _graphData.reset();
    }

    void _toggleFlashlight(bool toggle) {
        widget.brightnessDetectionConfig.toggleFlashlight = toggle;
        _cameraController.setFlashMode(
            toggle ? FlashMode.torch : FlashMode.off);
        setState(() {});
    }

    void _onCameraImage(CameraImage image) {
        var result =
            _brightnessDetectionModel.processFrame(image);

        switch (_status) {
            case _PPGScreenStatus.ready:
                if (result != null && result.isCovered) {
                    _startTime = DateTime.now();
                    _ppgModel.processValue(0, result.brightness);
                    setState(() {_status = _PPGScreenStatus.buffering;});
                }
                else {
                    setState(() {});
                }
                break;

            case _PPGScreenStatus.buffering:
                if (result != null && result.isCovered) {
                    var timeDiff = DateTime.now().difference(_startTime);
                    double timeSeconds = timeDiff.inMilliseconds / 1000;
                    var entry = _ppgModel.processValue(timeSeconds, result.brightness);
                    if (entry != null && _ppgModel.heartRate > 0) {
                        _graphData.addPoint(timeSeconds, entry.deviation);
                        setState(() {_status = _PPGScreenStatus.sampling;});
                    }
                } else {
                    setState(() {_status = _PPGScreenStatus.ready;});
                    _reset();
                }
                break;

            case _PPGScreenStatus.sampling:
                if (result != null && result.isCovered) {
                    var timeDiff = DateTime.now().difference(_startTime);
                    double timeSeconds = timeDiff.inMilliseconds / 1000;
                    var entry = _ppgModel.processValue(timeSeconds, result.brightness);
                    if (entry != null) {
                        if (_graphData.addPoint(timeSeconds, entry.deviation)) {
                            setState(() {});
                        }
                    }
                } else {
                    setState(() {_status = _PPGScreenStatus.ready;});
                    _reset();
                }
                break;

            default:
                break;
        }
    }

    @override
    void initState() {
        super.initState();
        _status = _PPGScreenStatus.ready;

        _cameraController = CameraController(
            widget.cameraDescription,
            ResolutionPreset.low,
            fps: 30);

        _ppgModel = PPGModel(config: widget.ppgModelConfig);
        _graphData = GraphData(windowSize: widget.windowTimeframeSeconds);
        _brightnessDetectionModel = BrightnessDetectionModel(
            widget.brightnessDetectionConfig);

        _cameraController.initialize().then((_) {
            setState(() {_status = _PPGScreenStatus.ready;});
            _reset();
            _cameraController.startImageStream(_onCameraImage);
        });
    }

    @override
    void dispose() {
        _cameraController.setFlashMode(FlashMode.off);
        _cameraController.stopImageStream();
        _cameraController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Camera')),
            body: switch (_status) {
                _PPGScreenStatus.initializing => _PPGScreenInitializingWidget(),
                _PPGScreenStatus.ready => _PPGScreenReadyWidget(
                    cameraController: _cameraController,
                    brightnessDetectionModel: _brightnessDetectionModel,
                    onToggleFlashlight: _toggleFlashlight,
                ),
                _PPGScreenStatus.buffering => _PPGScreenBufferingWidget(
                    cameraController: _cameraController,
                    brightnessDetectionModel: _brightnessDetectionModel),
                _PPGScreenStatus.sampling => _PPGScreenSamplingWidget(
                    ppgModel: _ppgModel,
                    graphData: _graphData)
            });
    }
}
