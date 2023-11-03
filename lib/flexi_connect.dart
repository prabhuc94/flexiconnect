library flexi_connect;

import 'dart:async';
import 'package:flexi_connect/console.dart';
import 'package:flexi_connect/flexi_signal_model.dart';
import 'package:flutter/foundation.dart';
import 'package:netcore_signalr/signalr_client.dart';

class SignalR {
  final String connectionUrl;

  static const List<int> DEFAULT_RETRY_DELAYS = [2000, 5000, 10000, 20000];

  SignalR(
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

  final List<InvokeModel> _invokeModel = [];
  final StreamController<List<Object?>?> _listenArgumentController = StreamController.broadcast();
  Stream<List<Object?>?> get argumentStream => _listenArgumentController.stream;
  Stream<HubConnectionState> get stateStream => _connection.stateStream;
  ValueNotifier<HubConnectionState?> connectionState = ValueNotifier(HubConnectionState.Disconnected);
  HubConnectionState? get _state => _connection.state;

  void init() async {
    await _connection.start();
    _listenConnection();
  }

  Future<void>? reconnect() async => await _connection.start();

  void _listenConnection() {
    _connection
      ..onclose(({error}) {
        if (error != null) {
          console.e(error, time: DateTime.now());
          reconnect();
        } else {
          console.i("Connection closed without an error.", time: DateTime.now());
        }
      })
      ..onreconnecting(({error}) {})
      ..onreconnected(({connectionId}) {});
  }

  void _listenInvoke() async {
    if (_invokeModel.isNotEmpty) {
      for (var element in _invokeModel) {
        if (element.methodName != null && (element.methodName?.isNotEmpty ?? false) && element.arguments != null && (element.arguments?.isNotEmpty ?? false)) {
          await _connection.invoke("${element.methodName}", args: element.arguments);
        }
      }

      for (var element in _invokeModel) {
        if (element.listenMethodName != null && (element.listenMethodName?.isNotEmpty ?? false)) {
          _connection.on("${element.methodName}", (arguments) => _listenArgumentController.sink.add(arguments));
        }
      }
    }
  }

  void onClose(void Function({Exception? error}) listen) => _connection.onclose(listen);
  void on(String methodName, Function(List<Object?>?) listen) => _connection.on(methodName, listen);
  void off(String methodName, {Function(List<Object?>?)? method}) => _connection.off(methodName, method: method);
  Stream<Object?> stream(String methodName, List<Object> args) => _connection.stream(methodName, args);
  Future<Object?> invoke(String methodName, {List<Object>? args}) async => await _connection.invoke(methodName, args: args);
  Future<void> send(String methodName, {List<Object>? args}) async => await _connection.send(methodName, args: args);



  void emit(String methodName, String receiverMethodName, String message) async {
    if (_state == HubConnectionState.Connected) {
      await _connection.invoke(methodName, args: [receiverMethodName, message]);
    } else {
      console.e("Connection not in Connected state [${_state?.name}]");
    }
  }

  void setInvokeModels({required List<InvokeModel> model}) {
    if (_state == HubConnectionState.Connected) {
      _listenInvoke();
    } else if (_state == HubConnectionState.Disconnected) {
      reconnect()?.whenComplete(() => _listenInvoke());
    }
  }

  void dispose() {
    _connection.stop();
    connectionState.dispose();
    _invokeModel.clear();
    _listenArgumentController.close();
  }
}
