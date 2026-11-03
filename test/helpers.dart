import 'dart:math';

/// Luôn trả 0.5, lớn hơn tỉ lệ bạo kích 3%, nên test không bị ngẫu nhiên.
class NoCritRandom implements Random {
  @override
  double nextDouble() => 0.5;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  int nextInt(int max) => throw UnimplementedError();
}
