import 'package:ble_project/configs/global_config.dart';
import 'package:logger/logger.dart';

var logger = Logger();

void logV(String message) {
  if(!Global.isRelease) {
    logger.v(message);
  }
}

void logD(String message) {
  if(!Global.isRelease) {
    logger.d(message);
  }
}

void logI(String message) {
  if(!Global.isRelease) {
    logger.i(message);
  }
}

void logW(String message) {
  if(!Global.isRelease) {
    logger.w(message);
  }
}

void logE(String message) {
  if(!Global.isRelease) {
    logger.e(message);
  }
}

void logWtf(String message) {
  if(!Global.isRelease) {
    logger.wtf(message);
  }
}