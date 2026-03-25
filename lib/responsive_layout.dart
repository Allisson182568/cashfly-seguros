// lib/widgets/responsive_layout.dart
// Layout responsivo: sidebar (desktop) + bottom nav (mobile)

import 'package:cashflyseguros/theme.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget child;
  final int selectedIndex;
  final Function(int) onNavigate;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onNavigate,
  });

  static bool isDesktop(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 768;

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  static const _navItems = [
    _NavItem(icon: Icons.dashboard_rounded,     label: 'Dashboard'),
    _NavItem(icon: Icons.card_giftcard_rounded,  label: 'Cashback'),
    _NavItem(icon: Icons.group_add_rounded,      label: 'Indicações'),
    _NavItem( // 👈 NOVO
      icon: Icons.car_crash_rounded,
      label: 'Cotação',
    ),
    _NavItem(icon: Icons.person_rounded,         label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = ResponsiveLayout.isDesktop(context);
    return desktop ? _buildDesktop() : _buildMobile();
  }

  Widget _buildDesktop() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: widget.selectedIndex,
            items: _navItems,
            onTap: widget.onNavigate,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: widget.child,
      bottomNavigationBar: _BottomNav(
        selectedIndex: widget.selectedIndex,
        items: _navItems,
        onTap: widget.onNavigate,
      ),
    );
  }
}

// ── Sidebar ──────────────────────────────────────────────────
class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final Function(int) onTap;

  const _Sidebar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(right: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _CashfyLogo(),
          ),
          const SizedBox(height: 40),
          // Nav items
          ...items.asMap().entries.map((e) => _SidebarItem(
            item: e.value,
            isSelected: selectedIndex == e.key,
            onTap: () => onTap(e.key),
          )),
          const Spacer(),
          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '© 2024 Cashfy Seguros',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.primary.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final Function(int) onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((e) {
              final selected = selectedIndex == e.key;
              return GestureDetector(
                onTap: () => onTap(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        e.value.icon,
                        color: selected ? AppTheme.primary : AppTheme.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected ? AppTheme.primary : AppTheme.textSecondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────
class _CashfyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cashfy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Seguros',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primary,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}