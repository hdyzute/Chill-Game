import 'package:flutter/material.dart';

import '../../shared/placeholder_view.dart';

class PetScreen extends StatelessWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Linh thú',
      icon: Icons.egg_outlined,
      message: 'Linh thú của bạn đang ngủ trong trứng...',
    );
  }
}
