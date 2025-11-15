import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> captureAndShareImage(
    RenderRepaintBoundary boundary, {
    required String fileName,
    required String shareText,
  }) async {
    try {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Share directly without saving to gallery
      await Share.shareXFiles([
        XFile.fromData(pngBytes, name: '$fileName.png', mimeType: 'image/png'),
      ], text: shareText);
    } catch (e) {
      rethrow;
    }
  }

  static String generateShareText({
    required String calculatorName,
    required String mainResult,
    required String mainLabel,
  }) {
    return '''
🎯 I just calculated my $mainLabel using WeqaCalc!

$mainLabel: $mainResult

Check out WeqaCalc for free financial calculators 📊
Download now: https://play.google.com/store/apps/details?id=com.wefin.calculator

#WeqaCalc #FinancialFreedom #WealthBuilding
''';
  }
}
