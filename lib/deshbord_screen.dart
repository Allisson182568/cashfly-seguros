// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:cashflyseguros/referral.dart';
import 'package:cashflyseguros/referral_service.dart';
import 'package:cashflyseguros/responsive_layout.dart';
import 'package:cashflyseguros/user+profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:cashflyseguros/theme.dart';
import 'package:cashflyseguros/auth_service.dart';

import 'cashback_service.dart';
import 'cashback_transaction.dart';
import 'insurance_page.dart';


class DashboardScreen extends StatefulWidget {
  final int tabIndex;
  const DashboardScreen({super.key, this.tabIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _selectedTab;
  UserProfile? _profile;
  List<CashbackTransaction> _transactions = [];
  List<Referral> _referrals = [];
  bool _loading = true;

  final _cashbackService = CashbackService();
  final _referralService = ReferralService();

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.tabIndex;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _referralService.getProfile(),
        _cashbackService.getTransactions(),
        _referralService.getReferrals(),
      ]);
      if (mounted) {
        setState(() {
          _profile = results[0] as UserProfile?;
          _transactions = results[1] as List<CashbackTransaction>;
          _referrals = results[2] as List<Referral>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      selectedIndex: _selectedTab,
      onNavigate: (i) => setState(() => _selectedTab = i),
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _buildTab(),
    );
  }

  Widget _buildTab() {
    return switch (_selectedTab) {
      0 => _HomeTab(profile: _profile, transactions: _transactions, referrals: _referrals, onLogout: _logout),
      1 => _CashbackTab(profile: _profile, transactions: _transactions),
      2 => _ReferralTab(profile: _profile, referrals: _referrals),
      3 => const InsurancePage(),
      4 => _ProfileTab(profile: _profile, onLogout: _logout),
      _ => const SizedBox(),
    };
  }
}

// ── HOME TAB ──────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final UserProfile? profile;
  final List<CashbackTransaction> transactions;
  final List<Referral> referrals;
  final VoidCallback onLogout;

  const _HomeTab({this.profile, required this.transactions, required this.referrals, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final completed = referrals.where((r) => r.isCompleted).length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Olá, ${profile?.name.split(' ').first ?? 'usuário'} 👋',
                          style: Theme.of(context).textTheme.headlineMedium),
                      Text('Bem-vindo de volta', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
                  onPressed: onLogout,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Cashback card
            _CashbackBalanceCard(balance: profile?.cashbackBalance ?? 0.0),
            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(child: _StatCard(
                  label: 'Indicações', value: '${referrals.length}',
                  icon: Icons.group_rounded, color: AppTheme.primary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Convertidas', value: '$completed',
                  icon: Icons.check_circle_rounded, color: AppTheme.cashback,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Transações', value: '${transactions.length}',
                  icon: Icons.receipt_rounded, color: AppTheme.warning,
                )),
              ],
            ),
            const SizedBox(height: 28),

            // Recent transactions
            Text('Últimas transações', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              _EmptyState(
                icon: Icons.receipt_long_rounded,
                message: 'Nenhuma transação ainda.\nAdquira um seguro para começar a acumular cashback!',
              )
            else
              ...transactions.take(5).map((t) => _TransactionTile(transaction: t)),
          ],
        ),
      ),
    );
  }
}

// ── CASHBACK TAB ──────────────────────────────────────────────
class _CashbackTab extends StatelessWidget {
  final UserProfile? profile;
  final List<CashbackTransaction> transactions;

  const _CashbackTab({this.profile, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cashback', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 6),
            Text('Acompanhe seu saldo e histórico', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            _CashbackBalanceCard(balance: profile?.cashbackBalance ?? 0.0, showInfo: true),
            const SizedBox(height: 12),
            _InfoBanner(),
            const SizedBox(height: 28),
            Text('Histórico completo', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              _EmptyState(
                icon: Icons.savings_rounded,
                message: 'Nenhum cashback ainda.\nIndique amigos ou adquira seguros!',
              )
            else
              ...transactions.map((t) => _TransactionTile(transaction: t)),
          ],
        ),
      ),
    );
  }
}

// ── REFERRAL TAB ──────────────────────────────────────────────
class _ReferralTab extends StatelessWidget {
  final UserProfile? profile;
  final List<Referral> referrals;

  const _ReferralTab({this.profile, required this.referrals});

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado!'),
        backgroundColor: AppTheme.cashback,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyLink(BuildContext context, String code) {
    final link = 'https://cashfy.app/register?ref=$code';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copiado!'),
        backgroundColor: AppTheme.cashback,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = profile?.referralCode ?? '---';
    final pending = referrals.where((r) => !r.isCompleted).length;
    final completed = referrals.where((r) => r.isCompleted).length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Indicações', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 6),
            Text('Indique amigos e ganhe cashback', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),

            // Referral code card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Seu código de indicação',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          )),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: Colors.white),
                        onPressed: () => _copyCode(context, code),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.link_rounded, size: 18),
                      label: const Text('Copiar link de indicação'),
                      onPressed: () => _copyLink(context, code),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(child: _StatCard(
                  label: 'Pendentes', value: '$pending',
                  icon: Icons.hourglass_empty_rounded, color: AppTheme.warning,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  label: 'Convertidas', value: '$completed',
                  icon: Icons.check_circle_rounded, color: AppTheme.cashback,
                )),
              ],
            ),
            const SizedBox(height: 28),

            Text('Minhas indicações', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),

            if (referrals.isEmpty)
              _EmptyState(
                icon: Icons.group_add_rounded,
                message: 'Nenhuma indicação ainda.\nCompartilhe seu código e comece a ganhar!',
              )
            else
              ...referrals.map((r) => _ReferralTile(referral: r)),
          ],
        ),
      ),
    );
  }
}

// ── PROFILE TAB ───────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final UserProfile? profile;
  final VoidCallback onLogout;

  const _ProfileTab({this.profile, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  (profile?.name.isNotEmpty == true ? profile!.name[0] : 'U').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(profile?.name ?? '', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(profile?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cashback.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cashback.withOpacity(0.3)),
              ),
              child: Text(
                'Membro desde ${DateFormat('MMM yyyy', 'pt_BR').format(profile?.createdAt ?? DateTime.now())}',
                style: const TextStyle(color: AppTheme.cashback, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40),
            // Logout
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(color: AppTheme.error.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sair da conta'),
                onPressed: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────

class _CashbackBalanceCard extends StatelessWidget {
  final double balance;
  final bool showInfo;
  const _CashbackBalanceCard({required this.balance, this.showInfo = false});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cashbackGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_rounded, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Saldo de Cashback', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            fmt.format(balance),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
          ),
          if (showInfo) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cashback disponível para abatimento em seguros. Não pode ser sacado.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final CashbackTransaction transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isEarn = transaction.isEarn;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isEarn ? AppTheme.cashback : AppTheme.error).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEarn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isEarn ? AppTheme.cashback : AppTheme.error,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy', 'pt_BR').format(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${isEarn ? '+' : '-'}${fmt.format(transaction.amount)}',
            style: TextStyle(
              color: isEarn ? AppTheme.cashback : AppTheme.error,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralTile extends StatelessWidget {
  final Referral referral;
  const _ReferralTile({required this.referral});

  @override
  Widget build(BuildContext context) {
    final isCompleted = referral.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isCompleted ? AppTheme.cashback : AppTheme.warning).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
              color: isCompleted ? AppTheme.cashback : AppTheme.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Indicação #${referral.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy', 'pt_BR').format(referral.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isCompleted ? AppTheme.cashback : AppTheme.warning).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isCompleted ? 'Convertida' : 'Pendente',
              style: TextStyle(
                color: isCompleted ? AppTheme.cashback : AppTheme.warning,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textHint, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Como funciona o cashback?',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Ao adquirir ou indicar seguros, você acumula cashback. O saldo pode ser usado para abatimento em futuras contratações.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}