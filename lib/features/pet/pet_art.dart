import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/task_enums.dart';
import '../../domain/pet.dart';
import '../tasks/task_style.dart';
import 'pet_painter.dart';

/// Tắt chuyển động khi chạy `flutter test`: hoạt ảnh lặp mãi làm
/// `pumpAndSettle` không bao giờ dừng.
final bool _animate = !Platform.environment.containsKey('FLUTTER_TEST');

/// Hình linh thú (vẽ ở pet_painter.dart): nhún nhẹ và chớp mắt, trứng lắc
/// lư. Trưởng thành mang màu và đặc điểm của nhánh; nét mặt theo [mood].
class PetArt extends StatefulWidget {
  const PetArt({
    super.key,
    required this.stage,
    this.branch,
    this.mood = PetMood.calm,
    this.size = 180,
  });

  final PetStage stage;
  final TaskElement? branch;
  final PetMood mood;
  final double size;

  @override
  State<PetArt> createState() => _PetArtState();
}

class _PetArtState extends State<PetArt> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (_animate) {
      _controller = AnimationController(
          vsync: this, duration: const Duration(seconds: 4))
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final branch = widget.branch;
    final background = widget.stage == PetStage.adult && branch != null
        ? branch.color.withValues(alpha: 0.14)
        : scheme.primaryContainer.withValues(alpha: 0.5);
    final controller = _controller;
    final still = controller == null || MediaQuery.disableAnimationsOf(context);

    Widget paint(double bob, bool blink) => CustomPaint(
          size: Size.square(widget.size),
          painter: PetPainter(
            stage: widget.stage,
            branch: branch,
            mood: widget.mood,
            bob: bob,
            blink: blink,
          ),
        );

    return Semantics(
      label: [
        widget.stage == PetStage.adult && branch != null
            ? '${widget.stage.label} hệ ${branch.label}'
            : widget.stage.label,
        if (widget.stage != PetStage.egg) widget.mood.label,
      ].join(', '),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: background),
        child: still
            ? paint(0, false)
            : AnimatedBuilder(
                animation: controller,
                builder: (_, _) {
                  final v = controller.value;
                  // Hai lần nhún mỗi vòng 4 giây, chớp mắt một lần.
                  final bob = (1 - math.cos(v * 4 * math.pi)) / 2;
                  return paint(bob, v > 0.9 && v < 0.94);
                },
              ),
      ),
    );
  }
}

/// Hình linh vật. Bản "ngàn năm" có viền vàng và lấp lánh.
class SpiritItemIcon extends StatelessWidget {
  const SpiritItemIcon(this.item, {super.key, this.size = 20});

  final SpiritItem item;

  /// Cỡ cũ của icon; hình chiếm khung vuông cạnh 1,6 × [size].
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: item.label,
        child: CustomPaint(
          size: Size.square(size * 1.6),
          painter: SpiritItemPainter(item),
        ),
      );
}
