import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme.dart';
import 'shell/day_watcher.dart';
import 'shell/home_shell.dart';
import 'shell/reminder_sync.dart';

class LinhThuApp extends StatelessWidget {
  const LinhThuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linh Thú Kỷ Luật',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Chữ của widget có sẵn (bảng chọn giờ, nút Hủy/OK...) bằng tiếng Việt.
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const DayWatcher(child: ReminderSync(child: HomeShell())),
    );
  }
}
