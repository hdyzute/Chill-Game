import 'package:flutter/material.dart';

import '../../shared/placeholder_view.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderView(
      title: 'Lịch sử',
      icon: Icons.calendar_month_outlined,
      message: 'Lịch tháng và streak của bạn sẽ ở đây.',
    );
  }
}
