library flexi_connect;

import 'dart:async';
import 'package:flexi_connect/console.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/errors.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalR {
  final String connectionUrl;

  static const List<int> DEFAULT_RETRY_DELAYS = [2000, 5000, 10000, 20000];

  HubConnectionState? get _state => _connection.state;

  HubConnectionState? get conn => _connection.state;
  bool get _isConnected => (_state == HubConnectionState.Connected);
  bool get _isDisconnected => (_state == HubConnectionState.Disconnected);

  SignalR(
      {required this.connectionUrl,
      List<int> retryDelays = DEFAULT_RETRY_DELAYS,
      HttpConnectionOptions? options,
      HttpTransportType? transportType,
      required List<String> listeners,
      required Function(List<Object?>?) onArgument}) {
    _onArguments = onArgument;
    _connection = HubConnectionBuilder()
        .withUrl(connectionUrl, options: options, transportType: transportType)
        .withAutomaticReconnect(retryDelays: retryDelays)
        .build();

    _connection
      ..onclose(({error}) => _catchError(error))
      ..onreconnecting(({error}) => _catchError(error))
      ..onreconnected(({connectionId}) => connectionState.value = (_state ?? HubConnectionState.Disconnected));
    if (listeners.isNotEmpty) {
      for (var element in listeners) {
        _connection.on(element, _handleArgument);
      }
    }
  }

  void start({required List<InvokeMethods> invoker}) async {
    if (invoker.isEmpty) {
      throw AbortError("Invoker is required");
    }

    _invokers = invoker;

    _connect();
  }

  void _handleArgument(List<Object?>? args) {
    _onArguments?.call(args);
  }

  late HubConnection _connection;

  ValueNotifier<HubConnectionState> connectionState =
      ValueNotifier(HubConnectionState.Disconnected);

  Function(dynamic)? onError;

  Function(List<Object?>?)? _onArguments;

  List<InvokeMethods> _invokers = [];

  void _catchError(e) {
    console.e("Close error $e", time: DateTime.now());
    if ((e is HttpError) || (e is GeneralError)) {
      reConnect();
    }
    _updateStatus();
  }

  void _updateStatus() => connectionState.value = _state ?? HubConnectionState.Disconnected;

  void reConnect() async {
    try {
      disconnect();
      Future.delayed(const Duration(seconds: 15), _connect);
    } catch(e) {
      _catchError(e);
    }
  }

  void _connect({List<InvokeMethods>? invoker}) async {
    if ((_invokers.isEmpty) && (invoker?.isEmpty ?? false)) {
      throw AbortError("Invoking values missing!");
    } else {
      _invokers = (invoker ?? []);
    }
    try {
      if (_isDisconnected) {
        await _connection.start();
      }
      _initInvoke();
      _updateStatus();
    } catch(e) {
      _catchError(e);
    }
  }

  void disconnect() async {
    try {
      await _connection.stop();
      _updateStatus();
    } catch(e) {
      _catchError(e);
    }
  }

  void _initInvoke() async {
    try {
      if (_isConnected && _invokers.isNotEmpty) {
        for (var element in _invokers) {
          await _connection.invoke(element.methodName, args: element.args);
        }
      }
    } catch (e) {
      _catchError(e);
    }
  }

  void onClose(void Function({Exception? error}) listen) =>
      _connection.onclose(listen);

  void on(String methodName, Function(List<Object?>?) listen) =>
      _connection.on(methodName, listen);

  void off(String methodName, {Function(List<Object?>?)? method}) =>
      _connection.off(methodName, method: method);

  Stream<Object?> stream(String methodName, List<Object> args) =>
      _connection.stream(methodName, args);

  Future<Object?> invoke(String methodName, {List<Object>? args}) async {
    try {
      if (_isConnected) {
        return await _connection.invoke(methodName, args: args);
      } else {
        onError?.call("Connection not in connected state");
        return null;
      }
    } catch (e) {
      _catchError(e);
    }
    return null;
  }

  Future<void> send(String methodName, {List<Object>? args}) async {
    try {
      if (_isConnected) {
        await _connection.send(methodName, args: args);
      } else {
        onError?.call("Connection not in connected state");
      }
    } catch (e) {
      _catchError(e);
    }
  }

  void emit(
      String methodName, String receiverMethodName, String message) async {
    try {
      if (_isConnected) {
        await _connection.invoke(methodName, args: [receiverMethodName, message]);
      } else {
        onError?.call("Connection not in connected state");
        console.e("Connection not in Connected state [${_state?.name}]");
      }
    } catch (e) {
      _catchError(e);
    }
  }

  void dispose() {
    disconnect();
    _invokers.clear();
  }
}

class InvokeMethods {
  late String methodName;
  late List<Object>? args;

  InvokeMethods(this.methodName, this.args);
}
