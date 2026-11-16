import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/score_service.dart';
import '../../domain/battle.dart';
import '../../domain/drops.dart';
import '../../domain/history.dart';
import '../../domain/pet.dart';
import '../tasks/task_style.dart';
import 'pet_art.dart';
import 'pet_painter.dart';

/// Màn trận boss: chiếu lại [replay] từng đòn một. Linh thú lao lên đánh,
/// boss rung và nhăn mặt, số sát thương bay lên; bỏ lỡ việc thì boss đánh
/// trả. Hết trận thì báo kết quả, thắng thì mở rương nhận thưởng.
class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key, required this.replay});

  final BattleReplay replay;

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen>
    with TickerProviderStateMixin {
  static const _intro = Duration(milliseconds: 700);
  static const _hit = Duration(milliseconds: 1100);
  static const _counter = Duration(milliseconds: 1300);

  /// Nhịp của đòn đang chiếu, từ 0 tới 1.
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: _intro,
  );

  /// Boss nhún nhẹ khi đứng yên.
  AnimationController? _idle;

  /// Số đòn đã chiếu xong.
  int _shown = 0;

  /// Đòn đang chiếu, null khi không có.
  int? _current;
  bool _countering = false;
  bool _done = false;

  /// Lần chiếu hiện tại; đổi khi bỏ qua hay xem lại để dừng lần cũ.
  int _run = 0;

  BossReward? _reward;

  BattleReplay get _replay => widget.replay;

  /// Số đòn thật sự đánh: boss gục thì các việc tốt sau không cần chiếu.
  late final int _hitCount = () {
    var hp = _replay.hpBefore;
    for (var i = 0; i < _replay.hits.length; i++) {
      if (hp <= 0) return i;
      hp -= _replay.hits[i].damage;
    }
    return _replay.hits.length;
  }();

  @override
  void initState() {
    super.initState();
    if (ambientAnimations) {
      _idle = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2400),
      )..repeat();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileRepositoryProvider).setLastBattleDay(_replay.day);
    });
    _play();
  }

  @override
  void dispose() {
    _run++;
    _beat.dispose();
    _idle?.dispose();
    super.dispose();
  }

  Future<bool> _step(Duration duration, int run) async {
    _beat.duration = duration;
    try {
      await _beat.forward(from: 0).orCancel;
    } on TickerCanceled {
      return false;
    }
    return mounted && run == _run;
  }

  Future<void> _play() async {
    final run = ++_run;
    setState(() {
      _shown = 0;
      _current = null;
      _countering = false;
      _done = false;
    });
    if (!await _step(_intro, run)) return;
    for (var i = 0; i < _hitCount; i++) {
      setState(() => _current = i);
      if (!await _step(_hit, run)) return;
      setState(() {
        _shown = i + 1;
        _current = null;
      });
    }
    if (_replay.counterattack && !_replay.defeated) {
      setState(() => _countering = true);
      if (!await _step(_counter, run)) return;
    }
    setState(() {
      _countering = false;
      _done = true;
    });
  }

  void _skip() {
    _run++;
    _beat.stop();
    setState(() {
      _shown = _hitCount;
      _current = null;
      _countering = false;
      _done = true;
    });
  }

  /// HP đang hiện: trừ dần theo từng đòn, đòn đang chiếu trừ lúc trúng.
  int get _hp {
    var hp = _replay.hpBefore;
    for (var i = 0; i < _shown; i++) {
      hp -= _replay.hits[i].damage;
    }
    final current = _current;
    if (current != null && _beat.value >= _impactAt) {
      hp -= _replay.hits[current].damage;
    }
    return math.max(0, hp);
  }

  static const _impactAt = 0.32;

  Future<void> _claim() async {
    final BossReward reward;
    try {
      reward = await ref.read(scoreServiceProvider).claimBoss();
    } on StateError {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (mounted) setState(() => _reward = reward);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pet = ref.watch(petProvider).value;
    final status = ref.watch(petStatusProvider);
    final petName = pet?.name ?? 'Linh thú';
    return Scaffold(
      appBar: AppBar(
        title: Text('Trận ${dayLabel(_replay.day)}'),
        actions: [
          if (!_done) TextButton(onPressed: _skip, child: const Text('Bỏ qua')),
          const SizedBox(width: 8),
        ],
      ),
      // Lấy lề và chiều cao của phần thân (dưới thanh tiêu đề), không phải
      // của cả màn hình. Màn ngang: sàn đấu gần vuông nên phải thu hẹp cho
      // vừa chiều cao, không thì boss và linh thú bị cắt mất phía dưới.
      body: LayoutBuilder(
        builder: (context, box) {
          final insets = MediaQuery.paddingOf(context);
          final stageWidth =
              (box.maxHeight - insets.vertical - 16) * _Stage.ratio;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32) + insets,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(stageWidth, 200),
                  ),
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_beat, ?_idle]),
                    builder: (context, _) => _Stage(
                      replay: _replay,
                      hp: _hp,
                      hit: _current == null ? null : _replay.hits[_current!],
                      countering: _countering,
                      t: _beat.value,
                      idle: _idle?.value ?? 0,
                      done: _done,
                      stage: status?.stage ?? PetStage.baby,
                      branch: pet?.branch,
                      mood: _countering || (_done && _replay.counterattack)
                          ? PetMood.tired
                          : PetMood.happy,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_replay.eventful)
                Text(
                  'Hôm qua chưa có đòn nào.',
                  style: theme.textTheme.bodyLarge,
                ),
              for (var i = 0; i < _shown; i++) _HitTile(hit: _replay.hits[i]),
              if (_done && _replay.counterattack && !_replay.defeated)
                _CounterTile(
                  boss: _replay.kind.label,
                  petName: petName,
                  missed: _replay.missedTitles,
                ),
              if (_done) ...[
                const SizedBox(height: 16),
                _Result(
                  replay: _replay,
                  reward: _reward,
                  onClaim: _claim,
                  onReplay: _play,
                  onClose: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Sàn đấu: boss bên phải, linh thú bên trái, thanh HP ở trên.
class _Stage extends StatelessWidget {
  const _Stage({
    required this.replay,
    required this.hp,
    required this.hit,
    required this.countering,
    required this.t,
    required this.idle,
    required this.done,
    required this.stage,
    required this.branch,
    required this.mood,
  });

  final BattleReplay replay;
  final int hp;
  final BattleHit? hit;
  final bool countering;

  /// Nhịp đòn đang chiếu, 0 tới 1.
  final double t;
  final double idle;
  final bool done;
  final PetStage stage;
  final TaskElement? branch;
  final PetMood mood;

  static const _impactAt = _BattleScreenState._impactAt;

  /// Tỉ lệ rộng / cao của sàn đấu.
  static const ratio = 1.05;

  @override
  Widget build(BuildContext context) {
    final kind = replay.kind;
    final colors = switch (kind.element) {
      TaskElement.fire => const [Color(0xFF2B1412), Color(0xFF7A2E1E)],
      TaskElement.water => const [Color(0xFF0B2236), Color(0xFF1F5F8B)],
      TaskElement.wood => const [Color(0xFF142414), Color(0xFF3D6B35)],
    };
    final defeated = hp == 0;
    final hit = this.hit;
    // Linh thú lao lên rồi lùi về; boss rung khi trúng đòn.
    final lunge = hit == null ? 0.0 : _there(t, 0.3, 0.6);
    final struck = hit != null && t >= _impactAt && t < 0.75;
    final shake = struck
        ? math.sin((t - _impactAt) * 50) * 10 * (1 - (t - _impactAt) / 0.43)
        : 0.0;
    // Boss đánh trả: boss lao xuống, linh thú rung.
    final charge = countering ? _there(t, 0.3, 0.6) : 0.0;
    final petHurt = countering && t >= 0.3 && t < 0.8;
    final petShake = petHurt ? math.sin(t * 60) * 8 : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: ratio,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth, h = box.maxHeight;
            final bossSize = w * 0.48;
            final petSize = w * 0.38;
            final bossCenter = Offset(
              w - 16 - bossSize / 2,
              h * 0.2 + bossSize / 2,
            );
            final petCenter = Offset(16 + petSize / 2, h - 12 - petSize / 2);
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: colors,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Mặt đất: dải cong dưới đáy.
                  Positioned(
                    left: -w * 0.1,
                    right: -w * 0.1,
                    bottom: 0,
                    height: h * 0.34,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.elliptical(w * 0.6, h * 0.12),
                        ),
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 14,
                    child: _HpBar(replay: replay, hp: hp),
                  ),
                  // Boss.
                  Positioned(
                    left:
                        bossCenter.dx -
                        bossSize / 2 +
                        shake -
                        charge * w * 0.28,
                    top: bossCenter.dy - bossSize / 2 + charge * h * 0.18,
                    child: Transform.rotate(
                      angle: defeated && done ? 0.25 : 0,
                      child: Opacity(
                        opacity: defeated && done ? 0.55 : 1,
                        child: CustomPaint(
                          size: Size.square(bossSize),
                          painter: BossPainter(
                            kind: kind,
                            tier: replay.tier,
                            pose: defeated
                                ? BossPose.defeated
                                : struck
                                ? BossPose.hurt
                                : BossPose.idle,
                            bob: (1 - math.cos(idle * 2 * math.pi)) / 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Linh thú.
                  Positioned(
                    left:
                        petCenter.dx -
                        petSize / 2 +
                        lunge * w * 0.22 +
                        petShake,
                    top: petCenter.dy - petSize / 2 - lunge * h * 0.2,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        petHurt
                            ? const Color(0x66FF1744)
                            : const Color(0x00000000),
                        BlendMode.srcATop,
                      ),
                      child: PetArt(
                        stage: stage,
                        branch: branch,
                        mood: mood,
                        size: petSize,
                        background: false,
                      ),
                    ),
                  ),
                  if (hit != null && t >= _impactAt - 0.02) ...[
                    Positioned(
                      left: bossCenter.dx - bossSize * 0.45,
                      top: bossCenter.dy - bossSize * 0.45,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: Size.square(bossSize * 0.9),
                          painter: _ImpactPainter(
                            color: hit.element?.color ?? Colors.white,
                            progress: ((t - _impactAt) / 0.45).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                    _Floating(
                      center: Offset(
                        bossCenter.dx,
                        bossCenter.dy - bossSize * 0.2,
                      ),
                      progress: ((t - _impactAt) / (1 - _impactAt)).clamp(
                        0.0,
                        1.0,
                      ),
                      child: _DamageText(hit: hit),
                    ),
                  ],
                  if (countering && t >= 0.3)
                    _Floating(
                      center: Offset(
                        petCenter.dx,
                        petCenter.dy - petSize * 0.45,
                      ),
                      progress: ((t - 0.3) / 0.7).clamp(0.0, 1.0),
                      child: const _Shout(
                        text: 'Bị đánh trả!',
                        color: Color(0xFFFF8A80),
                      ),
                    ),
                  if (done && defeated)
                    Positioned.fill(
                      child: Center(
                        child: _Shout(
                          text: 'Chiến thắng!',
                          color: const Color(0xFFFFD54F),
                          size: w * 0.11,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 0 → 1 trong [0, peak], 1 → 0 trong [peak, back], rồi 0.
  static double _there(double t, double peak, double back) {
    if (t <= peak) return Curves.easeIn.transform(t / peak);
    if (t <= back) {
      return 1 - Curves.easeOut.transform((t - peak) / (back - peak));
    }
    return 0;
  }
}

class _HpBar extends StatelessWidget {
  const _HpBar({required this.replay, required this.hp});

  final BattleReplay replay;
  final int hp;

  @override
  Widget build(BuildContext context) {
    const white = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    final name = replay.tier > 1
        ? '${replay.kind.label} · Vòng ${replay.tier}'
        : replay.kind.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, style: white)),
            Text(
              'HP $hp/${replay.maxHp}',
              key: const Key('battle-hp'),
              style: white,
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: hp / replay.maxHp,
            minHeight: 12,
            color: const Color(0xFFFF5252),
            backgroundColor: Colors.white.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

/// Chữ bay lên rồi mờ dần quanh [center].
class _Floating extends StatelessWidget {
  const _Floating({
    required this.center,
    required this.progress,
    required this.child,
  });

  final Offset center;
  final double progress;
  final Widget child;

  @override
  Widget build(BuildContext context) => Positioned(
    left: center.dx - 120,
    top: center.dy - 30 - progress * 50,
    width: 240,
    child: IgnorePointer(
      child: Opacity(
        opacity: progress < 0.7
            ? 1
            : (1 - (progress - 0.7) / 0.3).clamp(0.0, 1.0),
        child: Transform.scale(
          scale:
              0.7 +
              0.3 * Curves.easeOutBack.transform(math.min(1, progress * 4)),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

class _DamageText extends StatelessWidget {
  const _DamageText({required this.hit});

  final BattleHit hit;

  @override
  Widget build(BuildContext context) {
    final big = hit.weakness || hit.critical;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hit.critical)
          const _Shout(text: 'Bạo kích!', color: Color(0xFFFFD54F), size: 18),
        if (hit.weakness)
          const _Shout(text: 'Khắc chế!', color: Color(0xFFFFAB40), size: 18),
        _Shout(
          text: '−${hit.damage}',
          color: Colors.white,
          size: big ? 40 : 32,
        ),
      ],
    );
  }
}

/// Chữ đậm có viền tối, đọc được trên mọi nền.
class _Shout extends StatelessWidget {
  const _Shout({required this.text, required this.color, this.size = 26});

  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: size, fontWeight: FontWeight.w900);
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size / 6
              ..color = const Color(0xFF3B1A0A),
          ),
        ),
        Text(text, style: style.copyWith(color: color)),
      ],
    );
  }
}

/// Vụ nổ khi trúng đòn: vòng tròn loang ra và tia sáng màu hệ.
class _ImpactPainter extends CustomPainter {
  const _ImpactPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final fade = 1 - progress;
    canvas.drawCircle(
      c,
      r * (0.3 + 0.7 * progress),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12 * fade
        ..color = color.withValues(alpha: fade),
    );
    canvas.drawCircle(
      c,
      r * 0.35 * fade,
      Paint()..color = Colors.white.withValues(alpha: fade),
    );
    final ray = Paint()
      ..strokeWidth = r * 0.06 * fade
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: fade);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 + 0.3;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + d * r * (0.35 + 0.4 * progress),
        c + d * r * (0.55 + 0.45 * progress),
        ray,
      );
    }
  }

  @override
  bool shouldRepaint(_ImpactPainter old) =>
      old.progress != progress || old.color != color;
}

class _HitTile extends StatelessWidget {
  const _HitTile({required this.hit});

  final BattleHit hit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final element = hit.element;
    final color = element?.color ?? theme.colorScheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(element?.icon ?? Icons.check, size: 18, color: color),
      ),
      title: Text(hit.title),
      subtitle: hit.weakness || hit.critical
          ? Text(
              [
                if (hit.weakness) 'khắc chế, gấp rưỡi',
                if (hit.critical) 'bạo kích',
              ].join(' · '),
            )
          : null,
      trailing: Text(
        '−${hit.damage}',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _CounterTile extends StatelessWidget {
  const _CounterTile({
    required this.boss,
    required this.petName,
    required this.missed,
  });

  final String boss;
  final String petName;
  final List<String> missed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      key: const Key('battle-counter'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.error.withValues(alpha: 0.15),
        child: Icon(Icons.flash_on, size: 18, color: theme.colorScheme.error),
      ),
      title: Text('$boss đánh trả, $petName bị mệt'),
      subtitle: Text('Bỏ lỡ: ${missed.join(', ')}'),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.replay,
    required this.reward,
    required this.onClaim,
    required this.onReplay,
    required this.onClose,
  });

  final BattleReplay replay;
  final BossReward? reward;
  final VoidCallback onClaim;
  final VoidCallback onReplay;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reward = this.reward;
    final kind = replay.kind;
    final children = <Widget>[];
    if (replay.defeated) {
      children.add(
        Text('Đã đánh bại ${kind.label}!', style: theme.textTheme.titleLarge),
      );
      if (reward == null) {
        children.addAll([
          const SizedBox(height: 4),
          const Text('Rương báu đang chờ bạn mở.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onClaim,
            icon: const Icon(Icons.redeem),
            label: const Text('Mở rương'),
          ),
        ]);
      } else {
        children.addAll([
          const SizedBox(height: 12),
          Row(
            children: [
              SpiritItemIcon(reward.item, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nhận ${reward.coins} xu và '
                  '${dropLabel(reward.item, reward.itemCount)}',
                  key: const Key('battle-reward'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onClose, child: const Text('Xong')),
        ]);
      }
    } else {
      children.addAll([
        Text(
          replay.damage > 0
              ? 'Gây ${replay.damage} sát thương. ${kind.label} còn '
                    '${replay.hpAfter}/${replay.maxHp} HP.'
              : '${kind.label} còn ${replay.hpAfter}/${replay.maxHp} HP.',
          key: const Key('battle-summary'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          replay.counterattack
              ? 'Làm một việc tốt hôm nay để linh thú hồi sức và đánh tiếp.'
              : 'Hôm nay mỗi việc tốt là một đòn, đánh vào lúc sang ngày. '
                    'Việc tốt hệ ${kind.weakness.label} gây gấp rưỡi.',
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: onClose, child: const Text('Xong')),
      ]);
    }
    if (replay.eventful && reward == null) {
      children.add(
        Center(
          child: TextButton.icon(
            onPressed: onReplay,
            icon: const Icon(Icons.replay),
            label: const Text('Xem lại'),
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
