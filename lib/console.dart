import 'package:logger/logger.dart';

class Console {
  Console._(){
    if (_logger == null || (_logger?.isClosed() ?? false)) {
      _logger = Logger();
    }
  }

  static final Console instance = Console._();

  Logger? _logger;

  void t(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace,}) => _logger?.t(message, time: time, error: error, stackTrace: stackTrace);
  void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace,}) => _logger?.e(message, time: time, error: error, stackTrace: stackTrace);
  void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace,}) => _logger?.d(message, time: time, error: error, stackTrace: stackTrace);
  void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace,}) => _logger?.i(message, time: time, error: error, stackTrace: stackTrace);
  void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace,}) => _logger?.w(message, time: time, error: error, stackTrace: stackTrace);
  void f(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace,}) => _logger?.f(message, time: time, error: error, stackTrace: stackTrace);
  void log(Level level, dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace,}) => _logger?.log(level, message, time: time, error: error, stackTrace: stackTrace);

  void dispose() => _logger?.close();
}

final console = Console.instance;