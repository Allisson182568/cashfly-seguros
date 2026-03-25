// lib/features/insurance/insurance_page.dart
// Tela pública de cotação de seguro — acessível sem login

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashflyseguros/theme.dart';
import 'insurance_form.dart';
import 'insurance_result.dart';
import 'insurance_service.dart';

class InsurancePage extends StatefulWidget {
  const InsurancePage({super.key});

  @override
  State<InsurancePage> createState() => _InsurancePageState();
}

class _InsurancePageState extends State<InsurancePage> {
  bool _loading = false;
  InsuranceQuote? _quote;
  InsuranceFormData? _formData;

  // Scroll para mostrar resultado após simular
  final _scrollCtrl = ScrollController();

  Future<void> _onFormSubmit(InsuranceFormData data) async {
    setState(() { _loading = true; _quote = null; });

    try {
      final quote = await InsuranceService.simulate(data);
      setState(() {
        _quote    = quote;
        _formData = data;
        _loading  = false;
      });

      // Scroll suave para o resultado
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onContinue() {
    // Persiste o nome no query param para pré-preencher cadastro
    final name = Uri.encodeComponent(_formData?.name ?? '');
    context.go('/register?from=cotacao&name=$name');
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: _isDesktop ? 0 : 20,
              vertical: 32,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: _isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: _isDesktop ? 48 : 24,
        vertical: 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Row(children: [
        // Logo
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(9)),
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Cashfy',
                style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            const Text(' Seguros',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 16)),
          ]),
        ),
        const Spacer(),
        // Login link
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Já tenho conta',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ),
      ]),
    );
  }

  // ── Hero section ───────────────────────────────────────────
  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cashback.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cashback.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: AppTheme.cashback, size: 14),
              SizedBox(width: 6),
              Text('Simulação gratuita e sem compromisso',
                  style: TextStyle(color: AppTheme.cashback, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Simule seu\nseguro auto',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(height: 1.15),
        ),
        const SizedBox(height: 10),
        const Text(
          'Veja o preço em segundos e ainda ganhe cashback ao contratar com a Cashfy.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 24),
        // Trust badges
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _TrustBadge(icon: Icons.verified_rounded, label: 'SUSEP aprovada'),
            _TrustBadge(icon: Icons.lock_rounded, label: '100% seguro'),
            _TrustBadge(icon: Icons.timer_rounded, label: 'Resultado em 2 min'),
          ],
        ),
      ],
    );
  }

  // ── Form card ──────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preencha para simular',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Leva menos de 1 minuto',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          InsuranceForm(
            onSubmit: _onFormSubmit,
            loading: _loading,
          ),
        ],
      ),
    );
  }

  // ── Layouts ────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: hero + resultado
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                if (_quote != null) ...[
                  const SizedBox(height: 40),
                  Text('Sua cotação', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  InsuranceResult(
                    quote: _quote!,
                    userName: _formData!.name,
                    onContinue: _onContinue,
                  ),
                ],
              ],
            ),
          ),
        ),
        // Right: formulário (sticky)
        SizedBox(
          width: 420,
          child: _buildFormCard(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHero(),
        const SizedBox(height: 32),
        _buildFormCard(),
        if (_quote != null) ...[
          const SizedBox(height: 32),
          Text('Sua cotação', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          InsuranceResult(
            quote: _quote!,
            userName: _formData!.name,
            onContinue: _onContinue,
          ),
        ],
      ],
    );
  }

  // ── Footer ─────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Column(children: [
        const Text('Cashfy Seguros',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('"Seu seguro com cashback"',
            style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          children: [
            _FooterLink(label: 'Termos de uso', onTap: () {}),
            _FooterLink(label: 'Privacidade', onTap: () {}),
            _FooterLink(label: 'Fale conosco', onTap: () {}),
          ],
        ),
      ]),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primary, size: 14),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label,
          style: const TextStyle(color: AppTheme.textHint, fontSize: 12,
              decoration: TextDecoration.underline, decorationColor: AppTheme.textHint)),
    );
  }
}