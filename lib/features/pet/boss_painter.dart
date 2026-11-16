part of 'pet_painter.dart';

/// Tư thế boss trong trận.
enum BossPose { idle, hurt, defeated }

/// Ba boss của Bí cảnh, cùng phong cách chibi với linh thú nhưng dữ hơn:
/// Hắc Hỏa Lang (sói đen bờm lửa), Băng Giao (giao long băng), Thụ Yêu (cây
/// yêu). Vòng 2 trở đi có hào quang.
class BossPainter extends CustomPainter {
  const BossPainter({
    required this.kind,
    this.tier = 1,
    this.pose = BossPose.idle,
    this.bob = 0,
  });

  final BossKind kind;
  final int tier;
  final BossPose pose;

  /// 0 tới 1, nhún nhẹ khi đứng yên.
  final double bob;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0.5, 0.93),
        width: 0.62,
        height: 0.07,
      ),
      _fill(const Color(0x33000000)),
    );
    if (tier > 1) {
      final aura = switch (kind) {
        BossKind.fireWolf => const Color(0xFFFF5722),
        BossKind.iceDragon => const Color(0xFF40C4FF),
        BossKind.treeDemon => const Color(0xFF76FF03),
      };
      canvas.drawCircle(
        const Offset(0.5, 0.55),
        0.46,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  aura.withValues(alpha: 0.45),
                  aura.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(center: const Offset(0.5, 0.55), radius: 0.46),
              ),
      );
    }
    if (pose == BossPose.idle) canvas.translate(0, -0.015 * bob);
    switch (kind) {
      case BossKind.fireWolf:
        _wolf(canvas);
      case BossKind.iceDragon:
        _dragon(canvas);
      case BossKind.treeDemon:
        _treeDemon(canvas);
    }
    canvas.restore();
  }

  void _wolf(Canvas canvas) {
    const body = Color(0xFF3E3644);
    const belly = Color(0xFF6E6474);
    const flame = Color(0xFFFF5722);
    const flameLight = Color(0xFFFFC107);
    // Đuôi lửa bên phải, sau thân.
    final tail = Path()
      ..moveTo(0.72, 0.8)
      ..cubicTo(0.92, 0.82, 1.0, 0.58, 0.9, 0.4)
      ..cubicTo(0.88, 0.56, 0.8, 0.62, 0.74, 0.64)
      ..close();
    _shape(canvas, tail, flame);
    // Bờm lửa quanh đầu.
    final mane = Path()..moveTo(0.2, 0.62);
    const spikes = [
      (0.14, 0.44),
      (0.26, 0.42),
      (0.2, 0.24),
      (0.36, 0.3),
      (0.38, 0.12),
      (0.5, 0.24),
      (0.62, 0.12),
      (0.64, 0.3),
      (0.8, 0.24),
      (0.74, 0.42),
      (0.86, 0.44),
      (0.8, 0.62),
    ];
    for (var i = 0; i < spikes.length; i++) {
      final (x, y) = spikes[i];
      mane.lineTo(x, y);
    }
    mane.close();
    _shape(canvas, mane, flame);
    canvas.drawPath(_oval(0.5, 0.42, 0.22, 0.14), _fill(flameLight));
    // Tai nhọn.
    final ear = Path()
      ..moveTo(0.3, 0.42)
      ..lineTo(0.27, 0.2)
      ..lineTo(0.44, 0.34)
      ..close();
    for (final path in [ear, _mirror(ear)]) {
      _shape(canvas, path, body);
    }
    for (final x in [0.38, 0.62]) {
      _shape(canvas, _oval(x, 0.88, 0.08, 0.045), body);
    }
    _shape(canvas, _oval(0.5, 0.64, 0.3, 0.26), body);
    canvas.drawPath(_oval(0.5, 0.74, 0.17, 0.12), _fill(belly));
    // Mõm.
    canvas.drawPath(_oval(0.5, 0.69, 0.1, 0.065), _fill(belly));
    canvas.drawPath(_oval(0.5, 0.655, 0.03, 0.022), _fill(_ink));
    _angryFace(
      canvas,
      eyeY: 0.57,
      spread: 0.11,
      eye: const Color(0xFFFFD54F),
      pupil: const Color(0xFFD50000),
      mouthY: 0.73,
      line: const Color(0xFFFFCCBC),
    );
  }

  void _dragon(Canvas canvas) {
    const body = Color(0xFF6EC6EE);
    const dark = Color(0xFF2E86C1);
    const belly = Color(0xFFE1F5FE);
    const ice = Color(0xFFE3F8FF);
    // Khúc đuôi cuộn dưới đất, chóp băng bên phải.
    _shape(canvas, _oval(0.5, 0.84, 0.36, 0.09), body);
    final tip = Path()
      ..moveTo(0.82, 0.82)
      ..lineTo(0.98, 0.72)
      ..lineTo(0.86, 0.9)
      ..close();
    _shape(canvas, tip, ice);
    // Gai băng dọc lưng, sau thân.
    for (final (x, y, h) in const [
      (0.28, 0.5, 0.12),
      (0.24, 0.66, 0.1),
      (0.72, 0.5, 0.12),
      (0.76, 0.66, 0.1),
    ]) {
      final dir = x < 0.5 ? -1.0 : 1.0;
      final spike = Path()
        ..moveTo(x, y - 0.05)
        ..lineTo(x + dir * h, y)
        ..lineTo(x, y + 0.05)
        ..close();
      _shape(canvas, spike, ice);
    }
    // Sừng cong.
    final horn = Path()
      ..moveTo(0.38, 0.3)
      ..quadraticBezierTo(0.26, 0.2, 0.3, 0.08)
      ..quadraticBezierTo(0.36, 0.2, 0.45, 0.27)
      ..close();
    for (final path in [horn, _mirror(horn)]) {
      _shape(canvas, path, ice);
    }
    _shape(canvas, _oval(0.5, 0.55, 0.25, 0.3), body);
    // Vảy bụng.
    canvas.drawPath(_oval(0.5, 0.66, 0.14, 0.17), _fill(belly));
    for (final y in [0.58, 0.65, 0.72]) {
      canvas.drawLine(Offset(0.4, y), Offset(0.6, y), _stroke(0.008, dark));
    }
    // Râu.
    for (final side in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(0.5 + side * 0.12, 0.56)
          ..quadraticBezierTo(0.5 + side * 0.32, 0.5, 0.5 + side * 0.36, 0.64),
        _stroke(0.012, dark),
      );
    }
    _angryFace(
      canvas,
      eyeY: 0.45,
      spread: 0.1,
      eye: Colors.white,
      pupil: const Color(0xFF0D47A1),
      mouthY: 0.54,
    );
  }

  void _treeDemon(Canvas canvas) {
    const bark = Color(0xFF7B5236);
    const barkDark = Color(0xFF4E3220);
    const leaf = Color(0xFF4E8F3A);
    const leafDark = Color(0xFF2E5E22);
    // Cành tay hai bên.
    for (final side in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(0.5 + side * 0.2, 0.62)
          ..quadraticBezierTo(0.5 + side * 0.36, 0.6, 0.5 + side * 0.42, 0.46),
        _stroke(0.05, _ink),
      );
      canvas.drawPath(
        Path()
          ..moveTo(0.5 + side * 0.2, 0.62)
          ..quadraticBezierTo(0.5 + side * 0.36, 0.6, 0.5 + side * 0.42, 0.46),
        _stroke(0.03, bark),
      );
      _shape(canvas, _oval(0.5 + side * 0.43, 0.43, 0.05, 0.035), leaf);
    }
    // Rễ thay chân.
    for (final x in [0.36, 0.5, 0.64]) {
      final root = Path()
        ..moveTo(x - 0.05, 0.84)
        ..quadraticBezierTo(x, 0.95, x + 0.06, 0.93)
        ..quadraticBezierTo(x + 0.02, 0.88, x + 0.05, 0.84)
        ..close();
      _shape(canvas, root, barkDark);
    }
    // Thân cây.
    final trunk = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0.27, 0.4, 0.46, 0.48),
      const Radius.circular(0.16),
    );
    canvas.drawRRect(trunk, _fill(bark));
    canvas.save();
    canvas.clipRRect(trunk);
    for (final (x0, y0, x1, y1) in const [
      (0.32, 0.72, 0.36, 0.86),
      (0.66, 0.7, 0.62, 0.86),
      (0.6, 0.44, 0.66, 0.54),
    ]) {
      canvas.drawLine(Offset(x0, y0), Offset(x1, y1), _stroke(0.012, barkDark));
    }
    canvas.restore();
    canvas.drawRRect(trunk, _stroke(0.016));
    // Tán lá trên đầu.
    for (final (x, y, r, c) in const [
      (0.32, 0.36, 0.13, leafDark),
      (0.68, 0.36, 0.13, leafDark),
      (0.4, 0.26, 0.15, leaf),
      (0.6, 0.26, 0.15, leaf),
      (0.5, 0.18, 0.13, leaf),
    ]) {
      _shape(canvas, _oval(x, y, r, r * 0.85), c);
    }
    canvas.drawPath(
      _oval(0.45, 0.17, 0.04, 0.025),
      _fill(const Color(0x55FFFFFF)),
    );
    // Hốc mắt tối, chỉ khi còn trừng mắt.
    if (pose == BossPose.idle) {
      for (final x in [0.41, 0.59]) {
        canvas.drawPath(_oval(x, 0.57, 0.065, 0.055), _fill(barkDark));
      }
    }
    _angryFace(
      canvas,
      eyeY: 0.57,
      spread: 0.09,
      eye: const Color(0xFFD4E157),
      pupil: const Color(0xFF33691E),
      mouthY: 0.72,
      jagged: true,
      line: const Color(0xFFE6EE9C),
    );
  }

  /// Mắt dữ (mày xếch), miệng nanh. Bị đánh thì nhắm tịt, thua thì mắt X.
  void _angryFace(
    Canvas canvas, {
    required double eyeY,
    required double spread,
    required Color eye,
    required Color pupil,
    required double mouthY,
    bool jagged = false,

    /// Màu nét mày, mắt nhắm và mắt X: sáng trên thân tối để còn thấy.
    Color line = _ink,
  }) {
    const cx = 0.5;
    for (final side in [-1.0, 1.0]) {
      final x = cx + side * spread;
      switch (pose) {
        case BossPose.idle:
          final shape = Path()
            ..moveTo(x - 0.045, eyeY - (side < 0 ? 0.02 : 0.0))
            ..lineTo(x + 0.045, eyeY - (side > 0 ? 0.02 : 0.0))
            ..quadraticBezierTo(x + 0.04, eyeY + 0.045, x, eyeY + 0.045)
            ..quadraticBezierTo(
              x - 0.04,
              eyeY + 0.045,
              x - 0.045,
              eyeY - (side < 0 ? 0.02 : 0.0),
            )
            ..close();
          _shape(canvas, shape, eye, outline: 0.012);
          canvas.drawPath(
            _oval(x - side * 0.008, eyeY + 0.018, 0.014, 0.018),
            _fill(pupil),
          );
          // Mày xếch xuống phía trong.
          canvas.drawLine(
            Offset(x + side * 0.055, eyeY - 0.06),
            Offset(x - side * 0.035, eyeY - 0.025),
            _stroke(0.02, line),
          );
        case BossPose.hurt:
          canvas.drawPath(
            Path()
              ..moveTo(x - side * 0.04, eyeY - 0.025)
              ..lineTo(x + side * 0.03, eyeY + 0.005)
              ..lineTo(x - side * 0.04, eyeY + 0.035),
            _stroke(0.018, line),
          );
        case BossPose.defeated:
          canvas.drawLine(
            Offset(x - 0.03, eyeY - 0.025),
            Offset(x + 0.03, eyeY + 0.035),
            _stroke(0.018, line),
          );
          canvas.drawLine(
            Offset(x + 0.03, eyeY - 0.025),
            Offset(x - 0.03, eyeY + 0.035),
            _stroke(0.018, line),
          );
      }
    }
    if (pose == BossPose.defeated) {
      canvas.drawPath(
        Path()
          ..moveTo(cx - 0.05, mouthY + 0.02)
          ..quadraticBezierTo(cx, mouthY - 0.02, cx + 0.05, mouthY + 0.02),
        _stroke(0.016, line),
      );
      return;
    }
    final mouth = Path()..moveTo(cx - 0.08, mouthY - 0.01);
    if (jagged) {
      for (var i = 1; i <= 8; i++) {
        mouth.lineTo(cx - 0.08 + 0.02 * i, mouthY + (i.isOdd ? 0.035 : -0.005));
      }
      mouth.quadraticBezierTo(cx, mouthY + 0.07, cx - 0.08, mouthY - 0.01);
    } else {
      mouth.quadraticBezierTo(cx, mouthY + 0.07, cx + 0.08, mouthY - 0.01);
    }
    mouth.close();
    canvas.drawPath(mouth, _fill(const Color(0xFF3B0A0A)));
    if (!jagged) {
      // Hai răng nanh.
      for (final side in [-1.0, 1.0]) {
        final x = cx + side * 0.045;
        canvas.drawPath(
          Path()
            ..moveTo(x - 0.015, mouthY + 0.002)
            ..lineTo(x + 0.015, mouthY + 0.002)
            ..lineTo(x, mouthY + 0.035)
            ..close(),
          _fill(Colors.white),
        );
      }
    }
    canvas.drawPath(mouth, _stroke(0.012));
  }

  @override
  bool shouldRepaint(BossPainter old) =>
      old.kind != kind ||
      old.tier != tier ||
      old.pose != pose ||
      old.bob != bob;
}
