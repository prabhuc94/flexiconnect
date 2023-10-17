import 'package:mixin_logger/mixin_logger.dart';

class LogFile {
  LogFile._();

  static final LogFile instance = LogFile._();

  Future<void> init(String logDir, {String fileLeading = "LOG-FILE-", int maxFileCount = 10, int maxFileLength = 1024 * 1024 * 10}) async{
    return await initLogger(logDir, fileLeading: fileLeading, maxFileCount: maxFileCount, maxFileLength: maxFileLength).whenComplete(() => i("LOG-FILE-INITIATED-SUCCSSFULLY"));
  }
}