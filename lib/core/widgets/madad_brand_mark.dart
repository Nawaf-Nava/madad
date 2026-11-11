import 'package:flutter/material.dart';

import '../theme/madad_theme.dart';

class MadadBrandMark extends StatelessWidget {
  const MadadBrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(size * .24),
        child: SizedBox.square(
          dimension: size,
          child: Image.asset(
            'assets/brand/madad_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => DecoratedBox(
              decoration: const BoxDecoration(color: MadadColors.orange),
              child: Center(
                child: Text(
                  'م',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * .58,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class MadadLogoLockup extends StatelessWidget {
  const MadadLogoLockup({super.key, this.markSize = 76});

  final double markSize;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size.square(markSize),
            painter: _MadadSymbolPainter(),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مَدَد',
                style: TextStyle(
                  color: MadadColors.orange,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Text(
                'MADAD',
                style: TextStyle(
                  color: MadadColors.orange,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      );
}

class _MadadSymbolPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()
      ..color = MadadColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final symbol = Path()
      ..moveTo(18, 18)
      ..lineTo(69, 18)
      ..quadraticBezierTo(83, 18, 83, 32)
      ..lineTo(83, 55)
      ..cubicTo(83, 73, 69, 84, 51, 84)
      ..cubicTo(32, 84, 18, 72, 18, 54)
      ..lineTo(18, 40);
    canvas.drawPath(symbol, paint);
    canvas.drawCircle(
        const Offset(33, 39), 7, Paint()..color = MadadColors.orange);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
