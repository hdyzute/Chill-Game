import 'package:flutter/material.dart';

import '../../data/task_enums.dart';
import '../../domain/pet.dart';
import '../tasks/task_style.dart';

/// Hình linh thú. Hiện là hình tạm bằng icon; khi có hình vẽ thật (PLAN.md
/// mục 6) chỉ cần thay ở đây. Trưởng thành mang màu và biểu tượng của nhánh.
class PetArt extends StatelessWidget {
  const PetArt({super.key, required this.stage, this.branch, this.size = 180});

  final PetStage stage;
  final TaskElement? branch;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch ((stage, branch)) {
      (PetStage.egg, _) => (Icons.egg, scheme.tertiary),
      (PetStage.adult, final TaskElement b) => (b.icon, b.color),
      _ => (Icons.pets, scheme.primary),
    };
    return Semantics(
      label: stage == PetStage.adult && branch != null
          ? '${stage.label} hệ ${branch!.label}'
          : stage.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: stage == PetStage.adult
              ? color.withValues(alpha: 0.18)
              : scheme.primaryContainer.withValues(alpha: 0.6),
        ),
        child: Icon(icon, size: size * 0.55, color: color),
      ),
    );
  }
}

/// Hình linh vật, tạm dùng icon của hệ. Bản "ngàn năm" có thêm ngôi sao.
class SpiritItemIcon extends StatelessWidget {
  const SpiritItemIcon(this.item, {super.key, this.size = 20});

  final SpiritItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = item.element.color;
    final icon = CircleAvatar(
      radius: size * 0.8,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(item.element.icon, size: size, color: color),
    );
    if (!item.rare) return icon;
    return Badge(
      backgroundColor: rewardColor,
      label: Icon(Icons.star, size: size * 0.5, color: Colors.white),
      child: icon,
    );
  }
}
