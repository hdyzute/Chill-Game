import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'shell/home_shell.dart';

class LinhThuApp extends StatelessWidget {
  const LinhThuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linh Thú Kỷ Luật',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeShell(),
    );
  }
}
