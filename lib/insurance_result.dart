// lib/features/insurance/insurance_result.dart
// Card animado de resultado da cotação

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashflyseguros/theme.dart';
import 'insurance_service.dart';

class InsuranceResult extends StatefulWidget {
  final InsuranceQuote quote;
  final String userName;
  final VoidCallback onContinue;

  const InsuranceResult({
    super.key,
    required this.quote,
    required this.userName,
    required this.onContinue,
  });

  @override
  State<InsuranceResult> createState() => _InsuranceResultState();
}

class _InsuranceResultState extends State<InsuranceResult>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeSlide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeSlide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeSlide,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGreeting(),
            const SizedBox(height: 16),
            _buildMainPriceCard(),
            const SizedBox(height: 12),
            _buildCashbackBadge(),
            const SizedBox(height: 12),
            _buildComparison(),
            const SizedBox(height: 24),
            _buildCTA(),
            const SizedBox(height: 12),
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  // ── Saudação personalizada ────────────────────────────────
  Widget _buildGreeting() {
    final firstName = widget.userName.split(' ').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(children: [
        const Text('🎉', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$firstName, sua cotação está pronta!',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ]),
    );
  }

  // ── Card principal com preço ──────────────────────────────
  Widget _buildMainPriceCard() {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.shield_rounded, color: Colors.white70, size: 16),
            SizedBox(width: 6),
            Text('Seguro Auto — Estimativa Cashfy',
                style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5)),
          ]),
          const SizedBox(height: 16),
          // Preço anual em destaque
          Text(
            fmt.format(widget.quote.annualPrice),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const Text('/ano', style: TextStyle(color: Colors.white60, fontSize: 14)),
          const SizedBox(height: 12),
          // Divisor sutil
          Container(height: 1, color: Colors.white12),
          const SizedBox(height: 12),
          // Mensal
          Row(children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.white60, size: 16),
            const SizedBox(width: 6),
            Text(
              'ou ${fmt.format(widget.quote.monthlyPrice)}/mês',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Badge de cashback ─────────────────────────────────────
  Widget _buildCashbackBadge() {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cashback.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cashback.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppTheme.cashback.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.savings_rounded, color: AppTheme.cashback, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cashback Cashfy',
                style: TextStyle(color: AppTheme.cashback, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              'Você recebe ${fmt.format(widget.quote.cashback)} de volta para usar em renovações',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        )),
        Text(
          '+${fmt.format(widget.quote.cashback)}',
          style: const TextStyle(
            color: AppTheme.cashback,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ]),
    );
  }

  // ── Comparativo de preço ──────────────────────────────────
  Widget _buildComparison() {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final hasSavings = widget.quote.savings > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comparativo de preço',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12,
                  fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 14),
          // Linha mercado
          _ComparisonRow(
            label: 'Preço médio de mercado',
            value: fmt.format(widget.quote.marketPrice),
            valueColor: AppTheme.textSecondary,
            strikethrough: true,
          ),
          const SizedBox(height: 8),
          // Linha Cashfy
          _ComparisonRow(
            label: 'Preço Cashfy',
            value: fmt.format(widget.quote.annualPrice),
            valueColor: AppTheme.primary,
            bold: true,
          ),
          if (hasSavings) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cashback.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_down_rounded, color: AppTheme.cashback, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Você economiza ${fmt.format(widget.quote.savings)} por ano!',
                    style: const TextStyle(
                      color: AppTheme.cashback,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  // ── CTA principal ─────────────────────────────────────────
  Widget _buildCTA() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.cashback,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👉', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            Text(
              'Contratar com cashback',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() => const Text(
    '* Valores estimados. A cotação final depende de análise completa do perfil e veículo.',
    textAlign: TextAlign.center,
    style: TextStyle(color: AppTheme.textHint, fontSize: 11, height: 1.4),
  );
}

// ── Row de comparativo ────────────────────────────────────────
class _ComparisonRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool strikethrough;
  final bool bold;

  const _ComparisonRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.strikethrough = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Text(label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ),
      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: bold ? 16 : 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          decoration: strikethrough ? TextDecoration.lineThrough : null,
          decorationColor: AppTheme.textHint,
        ),
      ),
    ]);
  }
}