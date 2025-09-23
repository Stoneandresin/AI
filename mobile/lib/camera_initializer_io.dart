import 'dart:io' show Platform;

bool get shouldInitializeCamera => Platform.isAndroid || Platform.isIOS;
