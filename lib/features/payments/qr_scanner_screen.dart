import 'package:flutter/material.dart';

import '../../core/l10n/madad_localizations.dart';
import '../../core/theme/madad_theme.dart';
import '../../core/widgets/madad_ui.dart';

/// Visual-only representation of the Jaib QR scanner entry point.
/// Camera permissions, preview, barcode detection and image import are not wired.
class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = MadadLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.text('qrScanner'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          MadadNotice(
            icon: Icons.camera_alt_outlined,
            message: l10n.choose(
              ar: 'هذه معاينة للماسح فقط. لا يتم طلب إذن الكاميرا أو قراءة رمز.',
              en: 'This is a scanner preview only. Camera permission is not requested and no code is read.',
            ),
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: .82,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF080A0F),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: MadadColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          size: 44, color: MadadColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(l10n.text('cameraUnavailable'),
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(44),
                      child: CustomPaint(painter: _ScanFramePainter()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.image_outlined),
            label: Text(l10n.text('importImage')),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MadadColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    const corner = 24.0;
    final left = size.width * .08;
    final right = size.width * .92;
    final top = size.height * .22;
    final bottom = size.height * .78;

    canvas.drawLine(Offset(left, top + corner), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + corner, top), paint);
    canvas.drawLine(Offset(right - corner, top), Offset(right, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + corner), paint);
    canvas.drawLine(Offset(left, bottom - corner), Offset(left, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + corner, bottom), paint);
    canvas.drawLine(
        Offset(right - corner, bottom), Offset(right, bottom), paint);
    canvas.drawLine(
        Offset(right, bottom - corner), Offset(right, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
