import 'package:flutter/material.dart';

import '../../domain/pet.dart';

/// Hình linh thú. Hiện là hình tạm bằng icon; khi có hình vẽ thật (PLAN.md
/// mục 6) chỉ cần thay ở đây.
class PetArt extends StatelessWidget {
  const PetArt({super.key, required this.stage, this.size = 180});

  final PetStage stage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: stage.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.primaryContainer.withValues(alpha: 0.6),
        ),
        child: Icon(
          switch (stage) {
            PetStage.egg => Icons.egg,
            PetStage.baby => Icons.pets,
          },
          size: size * 0.55,
          color: switch (stage) {
            PetStage.egg => scheme.tertiary,
            PetStage.baby => scheme.primary,
          },
        ),
      ),
    );
  }
}
