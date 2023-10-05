library flexi_connect;

import 'dart:async';
import 'package:flexi_connect/flexi_signal_model.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

class FlexiSignal {
  final String connectionUrl;

  static const List<int> DEFAULT_RETRY_DELAYS = [2000, 5000, 10000, 20000];

  FlexiSignal(
      {required this.connectionUrl,
      List<int> retryDelays = DEFAULT_RETRY_DELAYS,
      HttpConnectionOptions? options,
      HttpTransportType? transportType}) {
    _connection = HubConnectionBuilder()
        .withUrl(connectionUrl, options: options, transportType: transportType)
        .withAutomaticReconnect(retryDelays: retryDelays)
        .build();
  }

  late HubConnection _connection;

  List<InvokeModel> _invodeModel = [];
  final StreamController<List<Object?>?> _listenArgumentController = StreamController.broadcast();
  Stream<List<Object?>?> get argumentStream => _listenArgumentController.stream;
  Stream<HubConnectionState> get stateStream => _connection.stateStream;
  ValueNotifier<HubConnectionState?> connectionState = ValueNotifier(HubConnectionState.Disconnected);
  HubConnectionState? get _state => _connection.state;

  void init() async {
    await _connection.start();
    _listenConnection();
  }

  void reconnect() async {
    if (_state == HubConnectionState.Disconnected) {
      await _connection.start();
    }
  }

  void _listenConnection() {
    _connection
      ..onclose(({error}) {})
      ..onreconnecting(({error}) {})
      ..onreconnected(({connectionId}) {});
  }

  void _listenInvoke() async {
    if (_invodeModel.isNotEmpty) {
      for (var element in _invodeModel) {
        if (element.methodName != null && (element.methodName?.isNotEmpty ?? false) && element.arguments != null && (element.arguments?.isNotEmpty ?? false)) {
          await _connection.invoke("${element.methodName}", args: element.arguments);
        }
      }

      for (var element in _invodeModel) {
        if (element.methodName != null && (element.methodName?.isNotEmpty ?? false) && element.arguments != null && (element.arguments?.isNotEmpty ?? false)) {
          _connection.on("${element.methodName}", (arguments) => _listenArgumentController.sink.add(arguments));
        }
      }
    }
  }

  void on(String methodName, Function(List<Object?>?) listen) => _connection.on(methodName, listen);

  void emit(String methodName, String receiverMethodName, String message) async {
    if (_state == HubConnectionState.Disconnected) {
      reconnect();
    }
    if (_state == HubConnectionState.Connected) {
      await _connection.invoke(methodName, args: [receiverMethodName, message]);
    } else {
      emit(methodName, receiverMethodName, message);
    }
  }

  void setInvokeModels({required List<InvokeModel> model}) {
    if (_state == HubConnectionState.Connected) {
      _listenInvoke();
    } else if (_state == HubConnectionState.Disconnected) {
      reconnect();
      _listenInvoke();
    }
  }

  void dispose() {
    _connection.stop();
    connectionState.dispose();
    _invodeModel.clear();
    _listenArgumentController.close();
  }
}
