import 'package:flutter/foundation.dart';

bool get isDesktopLayoutPlatform =>
    defaultTargetPlatform == TargetPlatform.windows ||
    defaultTargetPlatform == TargetPlatform.macOS;
