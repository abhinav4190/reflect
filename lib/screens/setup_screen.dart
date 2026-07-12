import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/main.dart';
import 'package:reflect/screens/home_screen.dart';
import 'package:reflect/theme/app_theme.dart';

enum _SetupStep {
  name,
  wakingHours,
  frequency,
  tasks,
  routines,
  shortTermGoals,
  longTermGoals,
  storage,
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _pageController = PageController();
  int _stepIndex = 0;
  final _steps = _SetupStep.values;

  final _nameController = TextEditingController();
  final _tasksController = TextEditingController();
  final _routinesController = TextEditingController();
  final _shortTermController = TextEditingController();
  final _longTermController = TextEditingController();

  TimeOfDay _wakeStart = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _wakeEnd = const TimeOfDay(hour: 23, minute: 0);
  String _frequency = 'hourly';

  void _goNext() {
    if (_stepIndex < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _submitSetup();
    }
  }

  void _goBack() {
    if (_stepIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _confirmSkipAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _SkipAllDialog(),
      barrierColor: AppColors.ink.withOpacity(0.4),
    );

    if (confirmed == true) {
      _submitSetup();
    }
  }

  Future<void> _submitSetup() async {
    final client = supabase;
    final userId = client.auth.currentUser!.id;

    await client
        .from('users')
        .update({
          'full_name': _nameController.text.trim(),
          'waking_hours_start':
              '${_wakeStart.hour.toString().padLeft(2, '0')}:${_wakeStart.minute.toString().padLeft(2, '0')}:00',
          'waking_hours_end':
              '${_wakeEnd.hour.toString().padLeft(2, '0')}:${_wakeEnd.minute.toString().padLeft(2, '0')}:00',
          'reflection_frequency': _frequency,
          'storage_mode': 'local',
          'setup_completed': true,
        })
        .eq('id', userId);

    final entities = <Map<String, dynamic>>[];
    void addIfNotEmpty(String text, String type) {
      if (text.trim().isNotEmpty) {
        entities.add({
          'user_id': userId,
          'entity_type': type,
          'title': text.trim(),
        });
      }
    }

    addIfNotEmpty(_tasksController.text, 'one_time_task');
    addIfNotEmpty(_routinesController.text, 'routine');
    addIfNotEmpty(_shortTermController.text, 'short_term_goal');
    addIfNotEmpty(_longTermController.text, 'long_term_goal');

    if (entities.isNotEmpty) {
      await client.from('life_entities').insert(entities);
    }

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _tasksController.dispose();
    _routinesController.dispose();
    _shortTermController.dispose();
    _longTermController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>  FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    if (_stepIndex > 0)
                      GestureDetector(
                        onTap: _goBack,
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: AppColors.ink,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      '${_stepIndex + 1} / ${_steps.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _confirmSkipAll,
                      child: Text(
                        'Skip all',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.muted,
                          // decoration: TextDecoration.underline,
                          decorationColor: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _stepIndex = i),
                  children: [
                    _NameStep(controller: _nameController, onContinue: _goNext),
                    _WakingHoursStep(
                      start: _wakeStart,
                      end: _wakeEnd,
                      onStartChanged: (t) => setState(() => _wakeStart = t),
                      onEndChanged: (t) => setState(() => _wakeEnd = t),
                      onContinue: _goNext,
                    ),
                    _FrequencyStep(
                      selected: _frequency,
                      onSelected: (v) => setState(() => _frequency = v),
                      onContinue: _goNext,
                    ),
                    _TextQuestionStep(
                      heading: "What's on your plate?",
                      subtext: 'Priority tasks or chores that repeat regularly.',
                      hint: 'e.g. Finish freelance project, buy groceries',
                      controller: _tasksController,
                      onContinue: _goNext,
                    ),
                    _TextQuestionStep(
                      heading: 'Any routines to track?',
                      subtext: 'Gym visits, skincare, reading, drinking water daily.',
                      hint: 'e.g. Skincare every night, gym 3x a week',
                      controller: _routinesController,
                      onContinue: _goNext,
                    ),
                    _TextQuestionStep(
                      heading: 'What are you aiming for soon?',
                      subtext: 'Your focus for the next few weeks or months.',
                      hint: 'e.g. Exam prep, fitness milestone',
                      controller: _shortTermController,
                      onContinue: _goNext,
                    ),
                    _TextQuestionStep(
                      heading: 'What kind of life are you building?',
                      subtext: 'The bigger picture, no goal is too big.',
                      hint: 'e.g. Build a business, financial independence',
                      controller: _longTermController,
                      onContinue: _goNext,
                    ),
                    _StorageStep(onContinue: _goNext),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.paper,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onContinue;
  const _NameStep({
    super.key,
    required this.controller,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'What\'s you name?',
            style: GoogleFonts.instrumentSerif(
              fontSize: 34,
              color: AppColors.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'So Reflect knows what to call you.',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              cursorColor: AppColors.ink,
              controller: controller,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.muted,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(label: 'Continue', onTap: onContinue),
        ],
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeTile({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time.format(context),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WakingHoursStep extends StatelessWidget {
  final TimeOfDay start;
  final TimeOfDay end;
  final ValueChanged<TimeOfDay> onStartChanged;
  final ValueChanged<TimeOfDay> onEndChanged;
  final VoidCallback onContinue;
  const _WakingHoursStep({
    super.key,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onContinue,
  });

  Future<void> _pick(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'When are you usually awake?',
            style: GoogleFonts.instrumentSerif(
              fontSize: 34,
              color: AppColors.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll only send reminders in this window.",
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _TimeTile(
                  label: 'From',
                  time: start,
                  onTap: () => _pick(context, start, onStartChanged),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeTile(
                  label: 'Until',
                  time: end,
                  onTap: () => _pick(context, end, onEndChanged),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _PrimaryButton(label: 'Continue', onTap: onContinue),
        ],
      ),
    );
  }
}

class _FrequencyStep extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onContinue;
  const _FrequencyStep({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onContinue,
  });

  static const _options = {
    'hourly': "Every hour",
    "every_2h": "Every 2 hours",
    "every_4h": "Every 4 hours",
    "daily": "Once a day",
  };
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'How often should we check in?',
            style: GoogleFonts.instrumentSerif(
              fontSize: 34,
              color: AppColors.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          ..._options.entries.map((entry) {
            final isSelected = selected == entry.key;
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Material(
                color: isSelected ? AppColors.ink : AppColors.fill,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelected(entry.key),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      entry.value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.paper : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          _PrimaryButton(label: 'Continue', onTap: onContinue),
        ],
      ),
    );
  }
}

class _TextQuestionStep extends StatelessWidget {
  final String heading;
  final String subtext;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onContinue;

  const _TextQuestionStep({
    super.key,
    required this.heading,
    required this.subtext,
    required this.hint,
    required this.controller,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            heading,
            style: GoogleFonts.instrumentSerif(
              fontSize: 30,
              color: AppColors.ink,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtext,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: controller,
              maxLines: 4,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.ink),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(label: 'Continue', onTap: onContinue),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onContinue,
              child: Text(
                'Skip this',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StorageStep extends StatelessWidget {
  final VoidCallback onContinue;
  const _StorageStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Where should photos live?',
            style: GoogleFonts.instrumentSerif(
              fontSize: 30,
              color: AppColors.ink,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'On this device',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.paper,
                    ),
                  ),
                ),
                Icon(Icons.check_circle, color: AppColors.paper, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Google Drive (coming soon)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(label: 'Finish', onTap: onContinue),
        ],
      ),
    );
  }
}

class _SkipAllDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skip setup?',
              style: GoogleFonts.instrumentSerif(
                fontSize: 26,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your dashbaord will start empty. You can always add goals, tasks and routines later from your profile.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: AppColors.fill,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        child: Text(
                          'Keep going',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        child: Text(
                          'Skip setup',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.paper,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
