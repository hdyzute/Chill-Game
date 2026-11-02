import 'package:flutter/material.dart';

/// Màu chủ đạo: cam "linh khí". Đổi seed ở đây để đổi toàn bộ bảng màu.
class AppTheme {
  static const _seed = Color(0xFFF08A24);

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );
}
