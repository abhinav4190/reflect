import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/main.dart';
import 'package:reflect/screens/profile_screen.dart';
import 'package:reflect/theme/app_theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeShell> {
  int _index = 0;
  final _titles = const ['Home', 'Reflections', 'Life Hub', 'Insights'];

  final _tabs = const [
    _Tabs(title: 'Home'),
    _Tabs(title: 'Reflections'),
    _Tabs(title: 'Life Hub'),
    _Tabs(title: 'Insights'),
  ];

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: AppColors.paper,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _openProfile,
              icon: Icon(Icons.person_outline, color: AppColors.ink),
            ),
          ),
        ],
      ),

      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: AppColors.paper),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: const _NavIcon.material(Icons.home_outlined),
                  activeIcon: const _NavIcon.material(Icons.home),
                  isActive: _index == 0,
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon: const _NavIcon.asset(
                    'assets/icons/reflection_outlined.png',
                  ),
                  activeIcon: const _NavIcon.asset(
                    'assets/icons/reflection.png',
                  ),
                  isActive: _index == 1,
                  onTap: () => setState(() => _index = 1),
                ),
                 _NavItem(
                  icon: const _NavIcon.material(Icons.hub_outlined),
                  activeIcon: const _NavIcon.material(Icons.hub),
                  isActive: _index == 2,
                  onTap: () => setState(() => _index = 2),
                  iconSize: 20,
                ),
                _NavItem(
                  icon: const _NavIcon.material(Icons.insights_outlined),
                  activeIcon: const _NavIcon.material(Icons.insights),
                  isActive: _index == 3,
                  onTap: () => setState(() => _index = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavIcon icon;
  final _NavIcon activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final double iconSize;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: (isActive ? activeIcon : icon).build(
          size: iconSize,
          color: isActive ? AppColors.ink : AppColors.muted,
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final String title;
  const _Tabs({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title',
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
      ),
    );
  }
}

class _NavIcon {
  final IconData? materialIcon;
  final String? assetPath;

  const _NavIcon.material(IconData icon)
    : materialIcon = icon,
      assetPath = null;

  const _NavIcon.asset(String path) : materialIcon = null, assetPath = path;

  Widget build({required Color color, required double size}) {
    if (materialIcon != null) {
      return Icon(materialIcon, size: size, color: color);
    }
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(assetPath!, width: size, height: size),
    );
  }
}
