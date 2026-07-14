import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/models/reflection_model.dart';
import 'package:reflect/services/supabase_service.dart';
import 'package:reflect/theme/app_theme.dart';

class ReflectionsTab extends StatefulWidget {
  const ReflectionsTab({super.key});

  @override
  State<ReflectionsTab> createState() => _ReflectionsTabState();
}

class _ReflectionsTabState extends State<ReflectionsTab> {
  final _service = SupabaseService();
  late Future<List<ReflectionModel>> _future;
  @override
  void initState() {
    super.initState();
    _future = _service.getAllRefelctions();
  }

  Future<void> _refresh() async {
    final data = await _service.getAllRefelctions();
    if (!mounted) return;
    setState(() {
      _future = Future.value(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _ReflectionLoading();
        }
        if (snapshot.hasError) {
          return _ReflectionError(
            onRetry: () =>
                setState(() => _future = _service.getAllRefelctions()),
          );
        }
        final reflections = snapshot.data!;

        if (reflections.isEmpty) {
          return _ReflectionEmpty(onRefresh: _refresh);
        }

        final grouped = _groupByDay(reflections);

        return RefreshIndicator(
          color: AppColors.ink,
          onRefresh: _refresh,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final group = grouped[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.label,
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 20,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...group.reflections.map(
                      (r) => _ReflectionCard(reflection: r),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<_DayGroup> _groupByDay(List<ReflectionModel> reflections) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    final Map<String, List<ReflectionModel>> buckets = {};
    final List<String> order = [];

    for (final r in reflections) {
      final d = r.recordedAt.toLocal();
      final day = DateTime(d.year, d.month, d.day);

      String label;
      if (day == today) {
        label = 'Today';
      } else if (day == yesterday) {
        label = 'Yesterday';
      } else {
        label = '${_weekday(day.weekday)}, ${day.day} ${_month(day.month)}';
      }

      if (!buckets.containsKey(label)) {
        buckets[label] = [];
        order.add(label);
      }
      buckets[label]!.add(r);
    }
    return order
        .map((label) => _DayGroup(label: label, reflections: buckets[label]!))
        .toList();
  }

  String _weekday(int w) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
  String _month(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    "Jun",
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
}

class _DayGroup {
  final String label;
  final List<ReflectionModel> reflections;

  _DayGroup({required this.label, required this.reflections});
}

class _ReflectionCard extends StatelessWidget {
  final ReflectionModel reflection;
  const _ReflectionCard({super.key, required this.reflection});

  String _time(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${local.minute.toString().padLeft(2, '0')} $period';
  }

  double get _totalSpent {
    var total = 0.0;
    for (final entry in reflection.spending) {
      total += ((entry['amount'] ?? 0) as num).toDouble();
    }
    return total;
  }

  int get _totalMinutes {
    var total = 0;
    for (final entery in reflection.timeAllocation) {
      total += ((entery['minutes'] ?? 0) as num).toInt();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final tags = <String>[];
    if (reflection.mood != null && reflection.mood!.isNotEmpty)
      tags.add(reflection.mood!);
    if (_totalMinutes > 0) tags.add('${_totalMinutes}m focused');
    if (_totalSpent > 0) tags.add('₹${_totalSpent.toStringAsFixed(0)}');
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _time(reflection.recordedAt),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            reflection.rawText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
          if (tags.isNotEmpty) ...[
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags.map((t) => _Tag(label: t)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.ink),
      ),
    );
  }
}

class _ReflectionEmpty extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _ReflectionEmpty({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: AppColors.paper,
      color: AppColors.ink,
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 700,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nothing here yet',
                    style: GoogleFonts.instrumentSerif(
                      fontSize: 22,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your reflections will show up here\nonce you start logging',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.muted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionLoading extends StatelessWidget {
  const _ReflectionLoading({super.key});

  Widget _box({double? width, required double height, double radius = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      children: [
        _box(width: 220, height: 34, radius: 8),
        const SizedBox(height: 10),
        _box(width: 180, height: 14, radius: 6),

        const SizedBox(height: 22),

        _box(height: 150),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _box(height: 90)),
            const SizedBox(width: 12),
            Expanded(child: _box(height: 90)),
            const SizedBox(width: 12),
            Expanded(child: _box(height: 90)),
          ],
        ),

        const SizedBox(height: 28),

        _box(width: 170, height: 24, radius: 8),

        const SizedBox(height: 16),

        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _box(height: 70),
          ),
        ),
      ],
    );
  }
}

class _ReflectionError extends StatelessWidget {
  final VoidCallback onRetry;
  const _ReflectionError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Couldn't load reflections",
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.ink),
          ),
          SizedBox(height: 10),
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
