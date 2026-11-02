import 'package:flutter/material.dart';

import '../../shared/placeholder_view.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Cài đặt',
      icon: Icons.settings_outlined,
      message: 'Giờ bắt đầu ngày, nhắc nhở và chế độ bế quan sẽ ở đây.',
    );
  }
}
