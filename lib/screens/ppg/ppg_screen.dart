import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:flutter_ppg/models/brightness_detection_model.dart';
import 'package:flutter_ppg/models/graph_data.dart';
import 'package:flutter_ppg/models/ppg_session.dart';
import 'package:flutter_ppg/screens/ppg/ppg_screen_ready_state_widget.dart';
import 'package:flutter_ppg/screens/ppg/ppg_screen_sampling_state_widget.dart';
import 'package:flutter_ppg/screens/ppg/ppg_screen_summary_state_widget.dart';
import 'package:flutter_ppg/screens/ppg/ppg_settings.dart';
import 'package:flutter_ppg/services/ppg_session_manager.dart';
import 'package:flutter_ppg/utils/fft.dart';

enum _PPGScreenState {
    initializing,
    ready,
    sampling,
    updatingHeartRate,
    finalizingHeartRate,
    error,
    done
}

class PPGScreenConfig {
    const PPGScreenConfig({
        this.windowTimeframeSeconds = 10,
        this.skippingFrames = 10,
        this.cameraFps = 30,
        this.updateIntervalSeconds = 1,
        int minUpdateWindowSeconds = 8,
        int maxUpdateWindowSeconds = 10,
    }) : minUpdateFrames = minUpdateWindowSeconds * cameraFps,
         maxUpdateFrames = maxUpdateWindowSeconds * cameraFps;

    final double windowTimeframeSeconds;
    final int cameraFps;
    final int skippingFrames;
    final int minUpdateFrames;
    final int maxUpdateFrames;
    final double updateIntervalSeconds;
}

class PPGScreenWidget extends StatefulWidget {
    const PPGScreenWidget({
        super.key,
        required this.cameraDescription,
        this.brightnessDetectionConfig = const BrightnessDetectionConfig(),
        this.ppgScreenConfig = const PPGScreenConfig(),
    });

    final CameraDescription? cameraDescription;
    final BrightnessDetectionConfig brightnessDetectionConfig;
    final PPGScreenConfig ppgScreenConfig;

    @override
    State<PPGScreenWidget> createState() => _PPGScreenWidgetState();
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

class HearteRateCalculateContext {
    final List<double> _data;
    final double _fps;

    HearteRateCalculateContext(this._data, this._fps);

    List<double> get data => _data;
    double get fps => _fps;
}

class _PPGScreenWidgetState extends State<PPGScreenWidget> {
    late CameraController _cameraController;
    late PPGSessionContext _sessionContext;
    late PPGSession? _finalSession;
    late GraphData _graphData;
    late BrightnessDetectionModel _brightnessDetectionModel;
    late PPGScreenSettings _ppgScreenSettings;  

    _PPGScreenState _state = _PPGScreenState.initializing;
    String _error = "";

    void _reset() {
        _sessionContext.reset(DateTime.now());
        _graphData.reset();
    }

    static double _calculateHeartRateFFT(HearteRateCalculateContext context) {
        return FFT.calculateHeartRate(context.data, context.fps);
    }

    Future<double> _prepareCalcaulteHeartRateFFT({int? maxFrames}) {
        var (data, duration) = _sessionContext.getEntries(maxFrames);
        double fps = (data.length - 1) / duration;
        var context = HearteRateCalculateContext(data, fps);

        return compute(_calculateHeartRateFFT, context);
    }

    void _processResult(double timeSeconds, BrightnessDetectionResult result) {
        PPGSessionEntry? entry =
            _sessionContext.addEntry(timeSeconds, result.brightness);
        if (entry != null) {
            _graphData.addPoint(timeSeconds, entry.value);
        }
    }

    void _onCameraImage(CameraImage image) {
        var result =
            _brightnessDetectionModel.processFrame(image);

        switch (_state) {
            case _PPGScreenState.ready:
                if (result != null && result.isCovered) {
                    _reset();
                    _processResult(0, result);
                    setState(() {_state = _PPGScreenState.sampling;});
                }
                else {
                    setState(() {});
                }
                break;

            case _PPGScreenState.sampling:
                if (result != null && result.isCovered) {
                    DateTime timeNow = DateTime.now();
                    var timeDiff = timeNow.difference(_sessionContext.startTime);
                    double timeSeconds = timeDiff.inMilliseconds / 1000;
                    _processResult(timeSeconds, result);

                    if (timeSeconds >= _ppgScreenSettings.length) {
                        setState(() {_state = _PPGScreenState.finalizingHeartRate;});

                        _prepareCalcaulteHeartRateFFT().then((heartRate) {
                            _finalSession = PPGSession(
                                timestamp: _sessionContext.startTime,
                                data: _sessionContext.entries.map((e) => e.value).toList(),
                                averageHeartRate: heartRate,
                                maxHeartRate: _sessionContext.maxHeartRate,
                                minHeartRate: _sessionContext.minHeartRate);

                            PPGSessionManager.instance.addSession(_finalSession!).then(
                                (_) { setState(() {_state = _PPGScreenState.done;}); });
                        });
                    } else {
                        timeDiff = timeNow.difference(_sessionContext.lastHeartRateUpdateTime);
                        timeSeconds = timeDiff.inMilliseconds / 1000;
                        if (timeSeconds > widget.ppgScreenConfig.updateIntervalSeconds &&
                            _sessionContext.entries.length >= widget.ppgScreenConfig.minUpdateFrames) {
                            _sessionContext.lastHeartRateUpdateTime = timeNow;
                            setState(() { _state = _PPGScreenState.updatingHeartRate; });
                            _prepareCalcaulteHeartRateFFT(
                                maxFrames: widget.ppgScreenConfig.maxUpdateFrames).then((heartRate) {
                                if (_state == _PPGScreenState.updatingHeartRate) {
                                    _sessionContext.currentHeartRate = heartRate;
                                    setState(() {_state = _PPGScreenState.sampling;});
                                }
                            });
                        } else {
                            setState(() {});
                        }
                    }
                } else {
                    setState(() {_state = _PPGScreenState.ready;});
                }
                break;

            case _PPGScreenState.updatingHeartRate:
                if (result != null && result.isCovered) {
                    DateTime timeNow = DateTime.now();
                    var timeDiff = timeNow.difference(_sessionContext.startTime);
                    double timeSeconds = timeDiff.inMilliseconds / 1000;
                    _processResult(timeSeconds, result);
                    setState(() {});
                } else {
                    setState(() {_state = _PPGScreenState.ready;});
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
                _state = _PPGScreenState.error;
            });
            return;
        }

        _state = _PPGScreenState.ready;

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
            fps: widget.ppgScreenConfig.cameraFps);

        _sessionContext = PPGSessionContext(
            startTime: DateTime.now(),
            skippingFrames: widget.ppgScreenConfig.skippingFrames);
        _graphData = GraphData(windowSize: widget.ppgScreenConfig.windowTimeframeSeconds);
        _brightnessDetectionModel = BrightnessDetectionModel(
            widget.brightnessDetectionConfig);

        _cameraController.initialize().then((_) {
            setState(() {_state = _PPGScreenState.ready;});
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

    Widget _buildSamplingStateWidget() {
        return PPGScreenSamplingStateWidget(
            graphData: _graphData,
            startTime: _sessionContext.startTime,
            ppgScreenSettings: _ppgScreenSettings,
            currentHeartRate: _sessionContext.currentHeartRate);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: const Text('心跳偵測')),
            body: switch (_state) {
                _PPGScreenState.initializing => _PPGScreenInitializingWidget(),
                _PPGScreenState.ready => PPGScreenReadyStateWidget(
                    cameraController: _cameraController,
                    brightnessDetectionModel: _brightnessDetectionModel,
                    ppgScreenSettings: _ppgScreenSettings,
                ),
                _PPGScreenState.sampling => _buildSamplingStateWidget(),
                _PPGScreenState.updatingHeartRate => _buildSamplingStateWidget(),
                _PPGScreenState.finalizingHeartRate => _buildSamplingStateWidget(),
                _PPGScreenState.error => _PPGScreenErrorWidget(error: _error),
                _PPGScreenState.done => PPGScreenSummaryStateWidget(
                    session: _finalSession!),
            });
    }
}
