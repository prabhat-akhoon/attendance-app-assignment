import 'package:flutter/material.dart';

/// Purely decorative oval guide to help the user frame their face in the
/// camera preview. Has no bearing on the actual face detection/matching
/// logic, which runs on the captured photo, not this overlay.
class FaceGuideOverlay extends StatelessWidget {
  const FaceGuideOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _OvalGuidePainter(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _OvalGuidePainter extends CustomPainter {
  final Color color;

  _OvalGuidePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.62,
      height: size.height * 0.42,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _OvalGuidePainter oldDelegate) =>
      oldDelegate.color != color;
}
