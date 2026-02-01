import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter_ppg/models/brightness_detection_model.dart';
import 'package:flutter_ppg/models/graph_data.dart';
import 'package:flutter_ppg/models/peak_detection_model.dart';
import 'package:flutter_ppg/models/ppg_session.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings_widget.dart';
import 'package:flutter_ppg/screens/ppg/camera_preview_widget.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings.dart';
import 'package:flutter_ppg/utils/fft.dart';

enum _PPGScreenStatus {
    initializing,
    ready,
//    buffering,
    sampling,
    error,
    analyzing,
    done
}

class PPGScreen extends StatefulWidget {
    const PPGScreen({
        super.key,
        required this.cameraDescription,
        required this.brightnessDetectionConfig,
        required this.peakDetectionConfig,
        this.windowTimeframeSeconds = 10,
        this.cameraFps = 30,
    });

    final CameraDescription? cameraDescription;
    final BrightnessDetectionConfig brightnessDetectionConfig;
    final PeakDetectionConfig peakDetectionConfig;
    final double windowTimeframeSeconds;
    final int cameraFps;

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
        required this.ppgScreenSettings,
    });

    final CameraController cameraController;
    final BrightnessDetectionModel brightnessDetectionModel;
    final PPGScreenSettings ppgScreenSettings;

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
                    PPGScreenSettingsWidget(
                        config: ppgScreenSettings,
                    ),
                ],
            )
        );
    }
}

class _PPGScreenAnalyzingWidget extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Center(
            child: Text('分析中...'));
    }
}

class _PPGScreenDoneWidget extends StatelessWidget {
    const _PPGScreenDoneWidget({
        required this.heartRate,
    });

    final double heartRate;
    @override
    Widget build(BuildContext context) {
        return Center(
            child: Text('心跳：$heartRate'));
    }
}

class _PPGScreenSamplingWidget extends StatelessWidget {
    const _PPGScreenSamplingWidget({
        required this.peakDetectionModel,
        required this.graphData,
        required this.startTime,
        required this.ppgScreenSettings,
    });

    final PeakDetectionModel peakDetectionModel;
    final GraphData graphData;
    final DateTime startTime;
    final PPGScreenSettings ppgScreenSettings;

    @override
    Widget build(BuildContext context) {
        var timeDiff = DateTime.now().difference(startTime);
        double timeSeconds = timeDiff.inMilliseconds / 1000;
        double progress = timeSeconds / ppgScreenSettings.length;

        List<FlSpot> points = graphData.getPoints();

        return Center(
            child: Column(
                spacing: 10,
                children: [ 
                    SizedBox(
                        width: 400,
                        height: 200,
                        child: LineChart(
                            LineChartData(
                                minX: points.isEmpty ? 0 : graphData.minX,
                                maxX: points.isEmpty ? 1 : graphData.maxX,
                                minY: points.isEmpty ? 0 : graphData.minY,
                                maxY: points.isEmpty ? 1 : graphData.maxY,
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(color: Colors.blue, width: 1),
                                ),
                                lineBarsData: points.isEmpty ? [] : [
                                    LineChartBarData(
                                        spots: points,
                                        isCurved: false,
                                        color: Colors.red,
                                        barWidth: 2,
                                        dotData: FlDotData(show: false),
                                    ),
                                ],
                            ),
                        ),
                    ),
                    Container(
                        width: 300,
                        height: 300,
                        child: Stack(
                            fit: StackFit.expand,
                            children: [
                                CircularProgressIndicator(
                                    value: progress,
                                ),
                                Text("AAA")
                            ],
                        ),
                    ),
                    if (peakDetectionModel.heartRate > 0) ...[
                        Text('Current Heart Rate: ${peakDetectionModel.heartRate} bpm'),
                        Text('Min Heart Rate: ${peakDetectionModel.minHeartRate} bpm'),
                        Text('Max Heart Rate: ${peakDetectionModel.maxHeartRate} bpm'),
                        Text('Average Heart Rate: ${peakDetectionModel.averageHeartRate} bpm'),
                    ]
                ]
            )
        );
    }
}

class _PPGScreenErrorWidget extends StatelessWidget {
    const _PPGScreenErrorWidget({required this.error});

    final String error;

    @override
    Widget build(BuildContext context) {
        return Text(
            error,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red));
    }
}


class _PPGScreenState extends State<PPGScreen> {
    late CameraController _cameraController;
    late PPGSession _session;
    late PeakDetectionModel _peakDetectionModel;
    late GraphData _graphData;
    late BrightnessDetectionModel _brightnessDetectionModel;
    late PPGScreenSettings _ppgScreenSettings;  

    _PPGScreenStatus _status = _PPGScreenStatus.initializing;
    late DateTime _startTime;
    String _error = "";

    void _reset() {
        _peakDetectionModel.reset();
        _graphData.reset();
    }

    static void _calculateHeartRateFFT(PPGSession session) {
        List<double> data = session.entries.map((e) => e.value).toList();
        print("data: ${data.map((e) => e.toString()).join(", ")}");
        session.heartRate = FFT.calculateHeartRate(data, session.fps.toDouble());
    }

    void _onCameraImage(CameraImage image) {
        var result =
            _brightnessDetectionModel.processFrame(image);

        switch (_status) {
            case _PPGScreenStatus.ready:
                if (result != null && result.isCovered) {
                    _startTime = DateTime.now();
                    _peakDetectionModel.processValue(0, result.brightness);
                    setState(() {_status = _PPGScreenStatus.sampling;});
                }
                else {
                    setState(() {});
                }
                break;

            case _PPGScreenStatus.sampling:
                if (result != null && result.isCovered) {
                    var timeDiff = DateTime.now().difference(_startTime);
                    double timeSeconds = timeDiff.inMilliseconds / 1000;
                    var entry = _peakDetectionModel.processValue(
                        timeSeconds, result.brightness);
                    if (entry != null && _peakDetectionModel.heartRate > 0) {
                        _graphData.addPoint(timeSeconds, entry.deviation);
                    }

                    if (timeSeconds >= _ppgScreenSettings.length) {
                        setState(() {_status = _PPGScreenStatus.analyzing;});

                        compute(_calculateHeartRateFFT, _session).then((_) {
                            setState(() {_status = _PPGScreenStatus.done;});
                        });
                    }
                    else {
                        setState(() {});
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

        if (widget.cameraDescription == null) {
            setState(() {
                _error = "無法找到相機";
                _status = _PPGScreenStatus.error;
            });
            return;
        }

        _status = _PPGScreenStatus.ready;

        _ppgScreenSettings = PPGScreenSettings(
            onLengthUpdate: (_) {
                setState(() {});
            },
            onToggleFlashlight: (bool enable) {
                _cameraController.setFlashMode(
                    enable ? FlashMode.torch : FlashMode.off);
                setState(() {});
            }
        );

        _cameraController = CameraController(
            widget.cameraDescription!,
            ResolutionPreset.low,
            fps: widget.cameraFps);

        _session = PPGSession(startTime: DateTime.now(), fps: widget.cameraFps);
        _peakDetectionModel = PeakDetectionModel(
            config: widget.peakDetectionConfig, session: _session);
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
        _cameraController.setFlashMode(FlashMode.off).then((_) {
            return _cameraController.stopImageStream();
        }).then((_) {
            _cameraController.dispose();
        });

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
                    ppgScreenSettings: _ppgScreenSettings,
                ),
/*                _PPGScreenStatus.buffering => _PPGScreenBufferingWidget(
                    cameraController: _cameraController,
                    brightnessDetectionModel: _brightnessDetectionModel),*/
                _PPGScreenStatus.sampling => _PPGScreenSamplingWidget(
                    peakDetectionModel: _peakDetectionModel,
                    graphData: _graphData,
                    startTime: _startTime,
                    ppgScreenSettings: _ppgScreenSettings),
                _PPGScreenStatus.error => _PPGScreenErrorWidget(error: _error),
                _PPGScreenStatus.analyzing => _PPGScreenAnalyzingWidget(),
                _PPGScreenStatus.done => _PPGScreenDoneWidget(
                    heartRate: _session.heartRate),
            });
    }
}
