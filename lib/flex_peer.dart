import 'dart:async';
import 'package:events_emitter/emitters/stream_event_emitter.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flexi_connect/randomizer.dart';
// import 'package:flexipeer/flexidart.dart';

enum Peer {
  open,
  close,
  error,
  call,
  receive,
  callClose,
  stream,
}

/*
class PeerJs extends StreamEventEmitter {
  PeerJs._() {
    _reConnectTimer();
    _peerService = FlexiPeer(id: randomInt(max: 999999).toString());
    _listen();
  }

  static final PeerJs instance = PeerJs._();

  Timer? _timer; // RECONNECT TIMER
  late FlexiPeer _peerService;
  Map<String, dynamic> _connections = {};

  void reInit() {
    if (_timer == null || !(_timer?.isActive ?? false)) {
      _reConnectTimer();
    }
  }

  void _reConnectTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_peerService.disconnected || !_peerService.open) {
        _peerService.reconnect();
      }
    });
  }

  bool get isDisconnected => _peerService.disconnected;

  bool get isDisposed => _peerService.destroyed;

  bool get isConnected => _peerService.open;

  void _listen() {
    try {
      _peerService
        ..on<String?>('open').listen(_peerOpen)
        ..on<MediaConnection>('call').listen(_peerMediaConnection)
        ..on('error').listen(_peerError)
        ..on('disconnected').listen(_peerDisconnection);
    } catch (e) {
      _peerError(e);
    }
  }

  void _peerOpen(String? event) {
    _emit<String?>(type: Peer.open, data: event);
  }

  void _peerMediaConnection(MediaConnection? event) {
    try {
      _emit<MediaConnection?>(type: Peer.receive, data: event);
    } catch (e) {
      _peerError(e);
    }
  }

  void _peerError(dynamic event) {
    _emit<String?>(type: Peer.error, data: event);
  }

  void _peerDisconnection(dynamic event) {
    _emit<String?>(type: Peer.close, data: event);
  }

  void call({required String peerID, dynamic callerData, required RTCVideoRenderer videoRenderer}) async {
    final mediaStream = await navigator.mediaDevices.getUserMedia({});
    _connections[peerID] = _peerService.call(peerID, mediaStream, options: _CallerOptions(data: callerData));
    if (_connections[peerID] != null) {
      var connection = _connections[peerID];
      if (connection is MediaConnection) {
        _emit<MediaConnection>(type: Peer.call, data: connection);
        _onListenCall(connection);
      }
    }
  }

  void answer({required MediaConnection event}) async {
    try {
      var stream = await _fetchStream;
      event.answer(stream);
      _onListenCall(event, call: false);
    } catch (e) {
      _peerError(e);
    }
  }

  void _onListenCall(MediaConnection event, {bool call = true}) {
    try {
      event
        ..on<MediaStream>('stream').listen((event) {
          if (call) {
            _emit(type: Peer.stream, data: event);
          }
        })
        ..on<dynamic>('error').listen((event) => _emit(type: Peer.error, data: event))
        ..once('close').then((value) => _emit(type: Peer.callClose, data: event));
    } catch (e) {
      _peerError(e);
    }
  }

  void reset() {
    _peerService.dispose();
    _peerService = FlexiPeer(id: randomInt(max: 999999).toString());
    _listen();
  }

  void connect() {
    _peerService.reconnect();
  }

  void _emit<T>({required Peer type, dynamic data}) {
    emit<T>(type.name, data);
  }

  void disconnectCall({required String peerId}) {
    if (_connections.containsKey(peerId)) {
      var connection = _connections[peerId];
      if (connection is MediaConnection) {
        connection
          ..closeRequest()
          ..close();
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    if (_connections.values.isNotEmpty) {
      _connections.values.forEach((element) {
        if (element is MediaConnection) {
          element..closeRequest()..close();
        }
      });
    }
    _peerService.dispose();
    controller.close();
  }

  Future<MediaStream> get _fetchStream  async {
    var sources = await desktopCapturer.getSources(types: [SourceType.Screen]);
    final mediaStream = await navigator.mediaDevices.getDisplayMedia({
      'video': {
        'deviceId': {'exact': sources.firstOrNull?.id},
        'mandatory': {'frameRate': 30.0}
      },
      'audio': false
    });
    return mediaStream;
  }
}

final peerJs = PeerJs.instance;

class _CallerOptions extends CallOption {
  _CallerOptions({dynamic data}) {
    metadata = data;
  }
}*/
