import 'package:ble_project/configs/global_config.dart';
import 'package:logger/logger.dart';

var _logger = Logger(printer: LongPrettyPrinter(methodCount: 2, warpLen:1000));

void logV(String message) {
  if(!Global.isRelease) {
    _logger.v(message);
  }
}

void logD(String message) {
  if(!Global.isRelease) {
    _logger.d(message);
  }
}

void logI(String message) {
  if(!Global.isRelease) {
    _logger.i(message);
  }
}

void logW(String message) {
  if(!Global.isRelease) {
    _logger.w(message);
  }
}

void logE(String message) {
  if(!Global.isRelease) {
    _logger.e(message);
  }
}

void logWtf(String message) {
  if(!Global.isRelease) {
    _logger.wtf(message);
  }
}

class LongPrettyPrinter extends PrettyPrinter {
  final int warpLen; //控制换行个数

  @override
  LongPrettyPrinter({
    this.warpLen = 1000,
    stackTraceBeginIndex = 0,
    methodCount = 2,
    errorMethodCount = 8,
    lineLength = 120,
    colors = true,
    printEmojis = true,
    printTime = false,
    noBoxingByDefault = false,
  }) : super(
    stackTraceBeginIndex: stackTraceBeginIndex,
    methodCount: methodCount,
    errorMethodCount: errorMethodCount,
    lineLength: lineLength,
    colors: colors,
    printEmojis: printEmojis,
    printTime: printTime,
    noBoxingByDefault: noBoxingByDefault,
  );

  @override
  String stringifyMessage(message) {
    var msg = super.stringifyMessage(message);
    var i = 0;
    var len = warpLen;
    var newStr = "";
    while (msg.length > i + len) {
      var next = i + len;
      var last = msg.indexOf("\n", i);
      if (last < i + 1 || last > next) {
        newStr += msg.substring(i, next) + "\n";
        i = next;
      } else {
        newStr += msg.substring(i, last);
        i = last;
      }
    }
    if (i + len > msg.length) {
      newStr += msg.substring(i);
    }
    return newStr;
  }
}