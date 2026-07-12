import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/models/life_entity_model.dart';
import 'package:reflect/models/reflection_model.dart';
import 'package:reflect/models/user_model.dart';
import 'package:reflect/services/supabase_service.dart';
import 'package:reflect/theme/app_theme.dart';

class HomeTab extends StatefulWidget {
  final void Function(int tabIndex) onNavigate;
  const HomeTab({super.key, required this.onNavigate});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _service = SupabaseService();
  late Future<_HomeData> _future;
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_HomeData> _load() async {
    final results = await Future.wait([
      _service.getCurrentUser(),
      _service.getTodayReflections(),
      _service.getLifeEntity(),
    ]);

    return _HomeData(
      entities: results[2] as List<LifeEntity>,
      reflections: results[1] as List<ReflectionModel>,
      user: results[0] as UserModel,
    );
  }

  Future<void> _refresh() async {
    final data = await _load();
    if (!mounted) return;
    setState(() => _future = Future.value(data));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HomeData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _HomeLoading();
        }
        if (snapshot.hasError) {
          return _HomeError(onRetry: () => setState(() => _future = _load()));
        }

        final data = snapshot.data!;

        return RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.paper,
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              _StatusBanner(data: data),
              const SizedBox(height: 24,),
              _MetricGrid(data: data, onNavigate: widget.onNavigate),
              const SizedBox(height: 28,),
              _TimelinePreview(data: data, onNavigate: widget.onNavigate)
            ],
          ),
        );
      },
    );
  }
}

class _HomeData {
  final UserModel user;
  final List<ReflectionModel> reflections;
  final List<LifeEntity> entities;

  _HomeData({
    required this.user,
    required this.reflections,
    required this.entities,
  });

  int get reflectionTarget {
    final start = _parseTime(user.wakingHoursStart);
    final end = _parseTime(user.wakingHoursEnd);

    final wakingHours = (end - start).clamp(1, 24);

    switch (user.reflectionFrequency) {
      case 'hourly':
        return wakingHours.round();
      case 'every_2h':
        return (wakingHours / 2).ceil();
      case 'every_4h':
        return (wakingHours / 4).ceil();
      default:
        return 1;
    }
  }

  double _parseTime(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) + int.parse(parts[1]) / 60;
  }

  int get totalMinutesFocused {
    var total = 0;
    for (final r in reflections) {
      for (final entry in r.timeAllocation) {
        total += ((entry['minutes'] ?? 0) as num).toInt();
      }
    }
    return total;
  }

  double get totalSpent {
    var total = 0.0;
    for (final r in reflections) {
      for (final entry in r.spending) {
        total += ((entry['amount'] ?? 0) as num).toDouble();
      }
    }
    return total;
  }

  int get totalWaterMl {
    var total = 0;
    for (final r in reflections) {
      total += r.waterML;
    }
    return total;
  }

  String? get topFoucsTitle {
    final incomplete = entities.where((e) => !e.isCompleted).toList();
    if (incomplete.isEmpty) return null;
    return incomplete.first.title;
  }
}

class _StatusBanner extends StatelessWidget {
  final _HomeData data;
  const _StatusBanner({super.key, required this.data});

  String get _timeGreeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final name = (data.user.fullName?.isNotEmpty ?? false)
        ? data.user.fullName
        : null;
    final greeting = name != null ? '$_timeGreeting, $name' : _timeGreeting;

    final focusLine = data.topFoucsTitle != null
        ? "Today's focus is towards ${data.topFoucsTitle}."
        : "Nothing on your plate right now";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.instrumentSerif(
            fontSize: 32,
            color: AppColors.ink,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          focusLine,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final _HomeData data;
  final void Function(int) onNavigate;
  _MetricGrid({super.key, required this.data, required this.onNavigate});

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String _formatMoney(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatWater(int ml) => '${(ml / 1000).toStringAsFixed(1)}L';

  @override
  Widget build(BuildContext context) {
    final progress = data.reflectionTarget == 0
        ? 0.0
        : (data.reflections.length / data.reflectionTarget).clamp(0.0, 1.0);

    return Column(children: [
        
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int count;
  final int target;
  final double progress;
  final VoidCallback onTap;

  const _HeroCard({
    super.key,
    required this.count,
    required this.target,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableCard(
      color: AppColors.ink,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reflections today',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.paper.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$count',
                style: GoogleFonts.instrumentSerif(
                  fontSize: 40,
                  color: AppColors.paper,
                  height: 1,
                ),
              ),
              Text(
                ' / target',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.paper.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.paper.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(AppColors.paper),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String labell;
  final String value;
  final VoidCallback onTap;
  const _MetricCard({
    super.key,
    required this.labell,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _PressableCard(
      color: AppColors.fill,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labell,
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;
  const _PressableCard({
    super.key,
    required this.child,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PressableCard> createState() => __PressableCardState();
}

class __PressableCardState extends State<_PressableCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TimelinePreview extends StatelessWidget {
  final _HomeData data;
  final void Function(int) onNavigate;
  const _TimelinePreview({required this.data, required this.onNavigate});

  String _realativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final recent = data.reflections.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent reflections',
              style: GoogleFonts.instrumentSerif(
                fontSize: 20,
                color: AppColors.ink,
              ),
            ),
            GestureDetector(
              onTap: () => onNavigate(1),
              child: Text(
                'See all',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (recent.isEmpty)
          Text(
            'No reflections logged yet today.',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
          )
        else
          ...recent.map(
            (r) => Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.fill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        r.rawText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _realativeTime(r.recordedAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeLoading extends StatefulWidget {
  const _HomeLoading({super.key});

  @override
  State<_HomeLoading> createState() => __HomeLoadingState();
}

class __HomeLoadingState extends State<_HomeLoading> {
  late final Stream<int> _dots;

  @override
  void initState() {
    super.initState();
    _dots = Stream.periodic(
      const Duration(milliseconds: 450),
      (i) => (i % 3) + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _dots,
      builder: (context, snap) {
        final dots = snap.data ?? 1;
        return Center(
          child: Text(
            'Loading${'.' * dots}',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
          ),
        );
      },
    );
  }
}

class _HomeError extends StatelessWidget {
  final VoidCallback onRetry;

  const _HomeError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Could't load your dashboard",
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Try again',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
