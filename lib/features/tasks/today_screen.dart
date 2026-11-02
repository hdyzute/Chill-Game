import 'package:flutter/material.dart';

import '../../shared/placeholder_view.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Hôm nay',
      icon: Icons.check_circle_outline,
      message: 'Danh sách thói quen và việc cần làm hôm nay sẽ ở đây.',
    );
  }
}
