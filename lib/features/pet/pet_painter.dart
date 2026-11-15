/// Hình linh thú và linh vật vẽ bằng code (vector, phong cách chibi), nên nét
/// ở mọi cỡ và chuyển động được. Mọi tọa độ tính trên khung 1 × 1.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/task_enums.dart';
import '../../domain/pet.dart';

const _ink = Color(0xFF5A3420);
const _shell = Color(0xFFFFF8EA);
const _shellShade = Color(0xFFF0DEC4);
const _fireSpot = Color(0xFFE5533D);
const _waterSpot = Color(0xFF2F7FD8);
const _woodSpot = Color(0xFF3E9B4F);
const _tearBlue = Color(0xFF8FD3FF);
const _mouthRed = Color(0xFF9C3030);
const _gold = Color(0xFFE0A100);

Paint _fill(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.fill;

Paint _stroke(double width, [Color color = _ink]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Path _oval(double cx, double cy, double rx, double ry) => Path()
  ..addOval(
    Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
  );

/// Tô [path] rồi viền nét mực.
void _shape(Canvas canvas, Path path, Color color, {double outline = 0.016}) {
  canvas.drawPath(path, _fill(color));
  if (outline > 0) canvas.drawPath(path, _stroke(outline));
}

/// Lật [path] qua trục dọc giữa khung.
Path _mirror(Path path) => path.transform(
  (Matrix4.identity()
        ..translateByDouble(1, 0, 0, 1)
        ..scaleByDouble(-1, 1, 1, 1))
      .storage,
);

/// Bảng màu theo nhánh tiến hóa; null là ấu thú.
typedef _Palette = ({Color body, Color belly, Color accent, Color light});

_Palette _palette(TaskElement? branch) => switch (branch) {
  TaskElement.fire => (
    body: const Color(0xFFFF8A65),
    belly: const Color(0xFFFFE0B2),
    accent: const Color(0xFFFF5722),
    light: const Color(0xFFFFD54F),
  ),
  TaskElement.water => (
    body: const Color(0xFF64B5F6),
    belly: const Color(0xFFE3F2FD),
    accent: const Color(0xFF1E88E5),
    light: const Color(0xFFB3E5FC),
  ),
  TaskElement.wood => (
    body: const Color(0xFF81C784),
    belly: const Color(0xFFF1F8E9),
    accent: const Color(0xFF388E3C),
    light: const Color(0xFFC5E1A5),
  ),
  null => (
    body: const Color(0xFFFFD9B0),
    belly: const Color(0xFFFFF3E0),
    accent: const Color(0xFFF08A24),
    light: const Color(0xFFFFE0B2),
  ),
};

/// Linh thú ở giai đoạn [stage]. [bob] từ 0 (chạm đất) tới 1 (nhún cao
/// nhất); [blink] là lúc chớp mắt.
class PetPainter extends CustomPainter {
  const PetPainter({
    required this.stage,
    this.branch,
    this.mood = PetMood.calm,
    this.bob = 0,
    this.blink = false,
  });

  final PetStage stage;
  final TaskElement? branch;
  final PetMood mood;
  final double bob;
  final bool blink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    if (stage == PetStage.egg) {
      _paintEgg(canvas);
    } else {
      // Vui thì nhún cao, mệt thì gần như đứng yên.
      final lift =
          bob *
          switch (mood) {
            PetMood.happy => 1.4,
            PetMood.tired => 0.3,
            PetMood.sad => 0.6,
            PetMood.calm => 1.0,
          };
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0.5, 0.9),
          width: 0.46 - 0.05 * lift,
          height: 0.06,
        ),
        _fill(const Color(0x22000000)),
      );
      canvas.translate(0, -0.03 * lift);
      if (stage == PetStage.baby) {
        _paintBaby(canvas);
      } else {
        _paintAdult(canvas, branch ?? TaskElement.fire);
      }
    }
    canvas.restore();
  }

  void _paintEgg(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0.5, 0.88),
        width: 0.4,
        height: 0.06,
      ),
      _fill(const Color(0x22000000)),
    );
    // Lắc lư quanh đáy trứng.
    final angle = (bob - 0.5) * 0.14;
    canvas.translate(0.5, 0.87);
    canvas.rotate(angle);
    canvas.translate(-0.5, -0.87);
    paintEgg(canvas, const Offset(0.5, 0.55), 0.64);
  }

  void _paintBaby(Canvas canvas) {
    final p = _palette(null);
    // Tai hai bên, sau thân.
    for (final x in [0.29, 0.71]) {
      _shape(canvas, _oval(x, 0.47, 0.075, 0.075), p.body);
      canvas.drawPath(
        _oval(x, 0.47, 0.04, 0.04),
        _fill(const Color(0xFFFFB7A8)),
      );
    }
    _feet(canvas, p.body);
    _shape(canvas, _oval(0.5, 0.62, 0.28, 0.25), p.body);
    canvas.drawPath(_oval(0.5, 0.71, 0.16, 0.11), _fill(p.belly));
    // Mảnh vỏ trứng còn đội trên đầu.
    final cap = Path()..moveTo(0.30, 0.46);
    const zig = [
      (0.35, 0.41),
      (0.40, 0.46),
      (0.45, 0.40),
      (0.50, 0.46),
      (0.55, 0.40),
      (0.60, 0.46),
      (0.65, 0.41),
      (0.70, 0.46),
    ];
    for (final (x, y) in zig) {
      cap.lineTo(x, y);
    }
    cap.cubicTo(0.70, 0.25, 0.30, 0.25, 0.30, 0.46);
    cap.close();
    canvas.drawPath(cap, _fill(_shell));
    canvas.save();
    canvas.clipPath(cap);
    canvas.drawPath(_oval(0.42, 0.35, 0.035, 0.035), _fill(_fireSpot));
    canvas.drawPath(_oval(0.57, 0.33, 0.028, 0.028), _fill(_waterSpot));
    canvas.drawPath(_oval(0.63, 0.42, 0.022, 0.022), _fill(_woodSpot));
    canvas.restore();
    canvas.drawPath(cap, _stroke(0.016));
    _face(canvas, eyeY: 0.6, spread: 0.085);
  }

  void _paintAdult(Canvas canvas, TaskElement branch) {
    final p = _palette(branch);
    _tail(canvas, branch, p);
    final ear = _ear(branch);
    for (final path in [ear, _mirror(ear)]) {
      _shape(canvas, path, branch == TaskElement.wood ? p.accent : p.body);
    }
    _feet(canvas, p.body);
    _shape(canvas, _oval(0.5, 0.62, 0.3, 0.27), p.body);
    canvas.drawPath(_oval(0.5, 0.72, 0.18, 0.13), _fill(p.belly));
    _crest(canvas, branch, p);
    _face(canvas, eyeY: 0.58, spread: 0.095);
  }

  void _feet(Canvas canvas, Color color) {
    for (final x in [0.4, 0.6]) {
      _shape(canvas, _oval(x, 0.85, 0.075, 0.045), color);
    }
  }

  /// Tai trái; tai phải là bản lật.
  Path _ear(TaskElement branch) => switch (branch) {
    // Hỏa: tai nhọn.
    TaskElement.fire =>
      Path()
        ..moveTo(0.29, 0.5)
        ..quadraticBezierTo(0.22, 0.32, 0.27, 0.24)
        ..quadraticBezierTo(0.38, 0.3, 0.45, 0.39)
        ..close(),
    // Thủy: vây cá chìa ra hai bên.
    TaskElement.water =>
      Path()
        ..moveTo(0.27, 0.52)
        ..quadraticBezierTo(0.1, 0.46, 0.12, 0.32)
        ..quadraticBezierTo(0.25, 0.36, 0.33, 0.44)
        ..close(),
    // Mộc: tai hình lá.
    TaskElement.wood =>
      Path()
        ..moveTo(0.33, 0.45)
        ..quadraticBezierTo(0.17, 0.46, 0.13, 0.29)
        ..quadraticBezierTo(0.3, 0.29, 0.36, 0.41)
        ..close(),
  };

  void _tail(Canvas canvas, TaskElement branch, _Palette p) {
    switch (branch) {
      case TaskElement.fire:
        final flame = Path()
          ..moveTo(0.7, 0.78)
          ..cubicTo(0.88, 0.8, 0.98, 0.6, 0.86, 0.4)
          ..cubicTo(0.86, 0.54, 0.78, 0.6, 0.72, 0.62)
          ..close();
        _shape(canvas, flame, p.accent);
        final inner = Path()
          ..moveTo(0.74, 0.74)
          ..cubicTo(0.86, 0.74, 0.91, 0.62, 0.87, 0.52)
          ..cubicTo(0.84, 0.62, 0.79, 0.66, 0.75, 0.67)
          ..close();
        canvas.drawPath(inner, _fill(p.light));
      case TaskElement.water:
        final fin = Path()
          ..moveTo(0.72, 0.72)
          ..quadraticBezierTo(0.84, 0.66, 0.95, 0.5)
          ..quadraticBezierTo(0.9, 0.68, 0.96, 0.86)
          ..quadraticBezierTo(0.84, 0.78, 0.72, 0.77)
          ..close();
        _shape(canvas, fin, p.accent);
      case TaskElement.wood:
        final leaf = Path()
          ..moveTo(0.72, 0.74)
          ..quadraticBezierTo(0.8, 0.48, 0.96, 0.44)
          ..quadraticBezierTo(0.94, 0.68, 0.72, 0.78)
          ..close();
        _shape(canvas, leaf, p.accent);
        canvas.drawLine(
          const Offset(0.74, 0.75),
          const Offset(0.92, 0.5),
          _stroke(0.01, p.light),
        );
    }
  }

  /// Đặc điểm trên đỉnh đầu theo hệ.
  void _crest(Canvas canvas, TaskElement branch, _Palette p) {
    switch (branch) {
      case TaskElement.fire:
        final flame = Path()
          ..moveTo(0.41, 0.38)
          ..cubicTo(0.38, 0.28, 0.45, 0.24, 0.46, 0.15)
          ..cubicTo(0.5, 0.23, 0.53, 0.22, 0.55, 0.13)
          ..cubicTo(0.62, 0.23, 0.64, 0.31, 0.59, 0.38)
          ..close();
        _shape(canvas, flame, p.accent);
        final inner = Path()
          ..moveTo(0.46, 0.37)
          ..cubicTo(0.45, 0.31, 0.49, 0.29, 0.5, 0.24)
          ..cubicTo(0.53, 0.29, 0.57, 0.32, 0.54, 0.37)
          ..close();
        canvas.drawPath(inner, _fill(p.light));
      case TaskElement.water:
        final drop = Path()
          ..moveTo(0.5, 0.14)
          ..quadraticBezierTo(0.61, 0.28, 0.57, 0.34)
          ..quadraticBezierTo(0.5, 0.4, 0.43, 0.34)
          ..quadraticBezierTo(0.39, 0.28, 0.5, 0.14)
          ..close();
        _shape(canvas, drop, p.light);
        canvas.drawPath(_oval(0.475, 0.3, 0.012, 0.022), _fill(Colors.white));
      case TaskElement.wood:
        canvas.drawLine(
          const Offset(0.5, 0.37),
          const Offset(0.5, 0.25),
          _stroke(0.016),
        );
        final left = Path()
          ..moveTo(0.5, 0.27)
          ..quadraticBezierTo(0.4, 0.16, 0.32, 0.22)
          ..quadraticBezierTo(0.4, 0.31, 0.5, 0.27)
          ..close();
        final right = Path()
          ..moveTo(0.5, 0.25)
          ..quadraticBezierTo(0.6, 0.1, 0.71, 0.16)
          ..quadraticBezierTo(0.63, 0.29, 0.5, 0.25)
          ..close();
        _shape(canvas, left, p.light);
        _shape(canvas, right, p.light);
    }
  }

  void _face(Canvas canvas, {required double eyeY, required double spread}) {
    const cx = 0.5;
    final mouthY = eyeY + 0.075;
    final blush = switch (mood) {
      PetMood.happy => const Color(0x88FF7A8A),
      PetMood.tired => const Color(0x33FF7A8A),
      _ => const Color(0x55FF7A8A),
    };
    for (final x in [cx - spread - 0.08, cx + spread + 0.08]) {
      canvas.drawPath(_oval(x, eyeY + 0.065, 0.045, 0.025), _fill(blush));
    }
    for (final side in [-1.0, 1.0]) {
      final x = cx + side * spread;
      switch (mood) {
        case PetMood.happy:
          canvas.drawPath(
            Path()
              ..moveTo(x - 0.035, eyeY + 0.012)
              ..quadraticBezierTo(x, eyeY - 0.04, x + 0.035, eyeY + 0.012),
            _stroke(0.018),
          );
        case PetMood.calm || PetMood.sad when blink:
          canvas.drawLine(
            Offset(x - 0.032, eyeY),
            Offset(x + 0.032, eyeY),
            _stroke(0.016),
          );
        case PetMood.calm || PetMood.sad:
          canvas.drawPath(_oval(x, eyeY, 0.03, 0.038), _fill(_ink));
          final down = mood == PetMood.sad ? 0.012 : -0.012;
          canvas.drawPath(
            _oval(x - 0.01, eyeY + down, 0.011, 0.011),
            _fill(Colors.white),
          );
          if (mood == PetMood.sad) {
            // Lông mày xếch lên ở phía trong.
            canvas.drawLine(
              Offset(x + side * 0.04, eyeY - 0.055),
              Offset(x - side * 0.03, eyeY - 0.075),
              _stroke(0.012),
            );
          }
        case PetMood.tired:
          final eye = Path()
            ..addArc(
              Rect.fromCenter(
                center: Offset(x, eyeY - 0.005),
                width: 0.06,
                height: 0.07,
              ),
              0,
              math.pi,
            )
            ..close();
          canvas.drawPath(eye, _fill(_ink));
          canvas.drawLine(
            Offset(x - 0.036, eyeY - 0.005),
            Offset(x + 0.036, eyeY - 0.005),
            _stroke(0.014),
          );
      }
    }
    switch (mood) {
      case PetMood.happy:
        final mouth = Path()
          ..moveTo(cx - 0.05, mouthY - 0.01)
          ..quadraticBezierTo(cx, mouthY + 0.08, cx + 0.05, mouthY - 0.01)
          ..close();
        canvas.drawPath(mouth, _fill(_mouthRed));
        canvas.save();
        canvas.clipPath(mouth);
        canvas.drawPath(
          _oval(cx, mouthY + 0.04, 0.03, 0.02),
          _fill(const Color(0xFFFF8A80)),
        );
        canvas.restore();
        canvas.drawPath(mouth, _stroke(0.012));
      case PetMood.calm:
        canvas.drawPath(
          Path()
            ..moveTo(cx - 0.03, mouthY)
            ..quadraticBezierTo(cx, mouthY + 0.03, cx + 0.03, mouthY),
          _stroke(0.014),
        );
      case PetMood.sad:
        canvas.drawPath(
          Path()
            ..moveTo(cx - 0.035, mouthY + 0.02)
            ..quadraticBezierTo(cx, mouthY - 0.015, cx + 0.035, mouthY + 0.02),
          _stroke(0.014),
        );
        _drop(canvas, cx - spread - 0.02, eyeY + 0.1, 0.055, _tearBlue);
      case PetMood.tired:
        canvas.drawPath(
          Path()
            ..moveTo(cx - 0.04, mouthY + 0.01)
            ..quadraticBezierTo(cx - 0.02, mouthY - 0.008, cx, mouthY + 0.01)
            ..quadraticBezierTo(
              cx + 0.02,
              mouthY + 0.028,
              cx + 0.04,
              mouthY + 0.01,
            ),
          _stroke(0.013),
        );
        // Giọt mồ hôi bên thái dương.
        _drop(canvas, cx + spread + 0.13, eyeY - 0.08, 0.07, _tearBlue);
    }
  }

  /// Giọt nước cao [h], đỉnh nhọn ở trên, tâm đáy tại ([x], [y]).
  static void _drop(Canvas canvas, double x, double y, double h, Color color) {
    final r = h * 0.4;
    final path = Path()
      ..moveTo(x, y - h)
      ..quadraticBezierTo(x + r * 1.3, y - r * 0.6, x + r, y)
      ..arcToPoint(Offset(x - r, y), radius: Radius.circular(r))
      ..quadraticBezierTo(x - r * 1.3, y - r * 0.6, x, y - h)
      ..close();
    canvas.drawPath(path, _fill(color));
    canvas.drawPath(path, _stroke(0.008));
  }

  @override
  bool shouldRepaint(PetPainter old) =>
      old.stage != stage ||
      old.branch != branch ||
      old.mood != mood ||
      old.bob != bob ||
      old.blink != blink;
}

/// Quả trứng linh thú (giống icon app): vỏ kem, đốm ba hệ, vết nứt. Tâm
/// [center], cao [h], trên khung 1 × 1.
void paintEgg(Canvas canvas, Offset center, double h) {
  final cx = center.dx, cy = center.dy;
  final rx = h * 0.39, ry = h / 2;
  final egg = Path();
  const steps = 96;
  for (var i = 0; i <= steps; i++) {
    final t = 2 * math.pi * i / steps;
    final x = cx + rx * math.sin(t) * (1 - 0.16 * math.cos(t));
    final y = cy - ry * math.cos(t);
    i == 0 ? egg.moveTo(x, y) : egg.lineTo(x, y);
  }
  egg.close();
  final bounds = egg.getBounds();
  canvas.drawPath(
    egg,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.45, -0.5),
        radius: 1.1,
        colors: [Colors.white, _shell, _shellShade],
        stops: [0, 0.4, 1],
      ).createShader(bounds),
  );
  canvas.save();
  canvas.clipPath(egg);
  for (final (dx, dy, r, color) in const [
    (-0.17, 0.2, 0.11, _fireSpot),
    (0.15, 0.3, 0.085, _waterSpot),
    (0.05, -0.33, 0.07, _woodSpot),
    (0.21, -0.17, 0.045, _waterSpot),
    (0.22, 0.05, 0.05, _fireSpot),
    (-0.02, 0.4, 0.04, _woodSpot),
  ]) {
    canvas.drawCircle(Offset(cx + dx * h, cy + dy * h), r * h, _fill(color));
  }
  final crack = Path();
  final w = h * 0.9, y0 = cy - h * 0.06;
  for (var i = 0; i <= 8; i++) {
    final x = cx - w / 2 + w * i / 8;
    final y = y0 + (i.isOdd ? h * 0.055 : -h * 0.035);
    i == 0 ? crack.moveTo(x, y) : crack.lineTo(x, y);
  }
  canvas.drawPath(crack, _stroke(h * 0.028));
  canvas.restore();
  canvas.drawPath(egg, _stroke(h * 0.022));
}

/// Linh vật: Hỏa Linh Quả (quả lửa), Thủy Tinh Lộ (giọt sương), Mộc Linh
/// Chi (nấm linh chi). Bản "ngàn năm" có viền vàng và lấp lánh.
class SpiritItemPainter extends CustomPainter {
  const SpiritItemPainter(this.item);

  final SpiritItem item;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    const line = 0.035;
    final element = item.element;
    final tint = switch (element) {
      TaskElement.fire => _fireSpot,
      TaskElement.water => _waterSpot,
      TaskElement.wood => _woodSpot,
    };
    canvas.drawCircle(
      const Offset(0.5, 0.5),
      0.5,
      _fill((item.rare ? _gold : tint).withValues(alpha: 0.16)),
    );
    if (item.rare) {
      canvas.drawCircle(const Offset(0.5, 0.5), 0.47, _stroke(0.045, _gold));
    }
    switch (element) {
      case TaskElement.fire:
        // Quả có cuống và lá, ngọn lửa in trên thân.
        canvas.drawLine(
          const Offset(0.5, 0.36),
          const Offset(0.53, 0.2),
          _stroke(0.04, const Color(0xFF795548)),
        );
        final leaf = Path()
          ..moveTo(0.52, 0.26)
          ..quadraticBezierTo(0.62, 0.14, 0.76, 0.2)
          ..quadraticBezierTo(0.66, 0.32, 0.52, 0.26)
          ..close();
        _shape(canvas, leaf, const Color(0xFF66BB6A), outline: line);
        final fruit = Path()
          ..moveTo(0.5, 0.36)
          ..cubicTo(0.62, 0.26, 0.8, 0.34, 0.78, 0.55)
          ..cubicTo(0.76, 0.74, 0.6, 0.82, 0.5, 0.8)
          ..cubicTo(0.4, 0.82, 0.24, 0.74, 0.22, 0.55)
          ..cubicTo(0.2, 0.34, 0.38, 0.26, 0.5, 0.36)
          ..close();
        _shape(canvas, fruit, const Color(0xFFE53935), outline: line);
        final flame = Path()
          ..moveTo(0.5, 0.42)
          ..cubicTo(0.6, 0.52, 0.64, 0.6, 0.6, 0.67)
          ..cubicTo(0.56, 0.73, 0.44, 0.73, 0.4, 0.67)
          ..cubicTo(0.36, 0.6, 0.42, 0.54, 0.46, 0.5)
          ..cubicTo(0.47, 0.55, 0.49, 0.57, 0.5, 0.42)
          ..close();
        canvas.drawPath(flame, _fill(const Color(0xFFFFB300)));
        canvas.drawPath(
          _oval(0.5, 0.65, 0.04, 0.045),
          _fill(const Color(0xFFFFF176)),
        );
        canvas.drawPath(
          _oval(0.32, 0.5, 0.035, 0.06),
          _fill(const Color(0x88FFFFFF)),
        );
      case TaskElement.water:
        final drop = Path()
          ..moveTo(0.5, 0.14)
          ..quadraticBezierTo(0.78, 0.48, 0.7, 0.68)
          ..quadraticBezierTo(0.5, 0.9, 0.3, 0.68)
          ..quadraticBezierTo(0.22, 0.48, 0.5, 0.14)
          ..close();
        _shape(canvas, drop, const Color(0xFF42A5F5), outline: line);
        canvas.drawPath(
          _oval(0.41, 0.58, 0.045, 0.08),
          _fill(const Color(0xAAFFFFFF)),
        );
      case TaskElement.wood:
        final stem = RRect.fromRectAndRadius(
          const Rect.fromLTWH(0.44, 0.48, 0.12, 0.3),
          const Radius.circular(0.05),
        );
        canvas.drawRRect(stem, _fill(const Color(0xFFD7B98E)));
        canvas.drawRRect(stem, _stroke(line));
        final cap = Path()
          ..moveTo(0.2, 0.54)
          ..quadraticBezierTo(0.5, 0.12, 0.8, 0.54)
          ..quadraticBezierTo(0.5, 0.64, 0.2, 0.54)
          ..close();
        _shape(canvas, cap, const Color(0xFF66BB6A), outline: line);
        canvas.drawPath(
          Path()
            ..moveTo(0.3, 0.47)
            ..quadraticBezierTo(0.5, 0.3, 0.7, 0.47),
          _stroke(0.025, const Color(0xFFC5E1A5)),
        );
        for (final (x, y, r) in const [(0.4, 0.4, 0.035), (0.58, 0.36, 0.03)]) {
          canvas.drawPath(
            _oval(x, y, r, r * 0.8),
            _fill(const Color(0xFFF1F8E9)),
          );
        }
    }
    if (item.rare) _sparkle(canvas, const Offset(0.8, 0.2), 0.13);
    canvas.restore();
  }

  static void _sparkle(Canvas canvas, Offset c, double r) {
    final k = r * 0.25;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + k, c.dy - k)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + k, c.dy + k)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - k, c.dy + k)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - k, c.dy - k)
      ..close();
    canvas.drawPath(path, _fill(const Color(0xFFFFD54F)));
    canvas.drawPath(path, _stroke(0.02, _gold));
  }

  @override
  bool shouldRepaint(SpiritItemPainter old) => old.item != item;
}
