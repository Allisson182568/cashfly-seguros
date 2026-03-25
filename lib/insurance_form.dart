// lib/features/insurance/insurance_form.dart
// Formulário de cotação de seguro auto

import 'package:cashflyseguros/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'insurance_service.dart';

class InsuranceForm extends StatefulWidget {
  /// Chamado quando o formulário é submetido com dados válidos
  final void Function(InsuranceFormData data) onSubmit;
  final bool loading;

  const InsuranceForm({
    super.key,
    required this.onSubmit,
    required this.loading,
  });

  @override
  State<InsuranceForm> createState() => _InsuranceFormState();
}

class _InsuranceFormState extends State<InsuranceForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _cepCtrl  = TextEditingController();

  VehicleModel _vehicle   = VehicleModel.onix2025;
  VehicleUse   _use       = VehicleUse.personal;
  bool         _hasGarage = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _cepCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(InsuranceFormData(
      name:      _nameCtrl.text.trim(),
      age:       int.parse(_ageCtrl.text.trim()),
      cep:       _cepCtrl.text.trim(),
      vehicle:   _vehicle,
      use:       _use,
      hasGarage: _hasGarage,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Seus dados'),
          const SizedBox(height: 12),
          _buildName(),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _buildAge()),
            const SizedBox(width: 12),
            Expanded(child: _buildCep()),
          ]),
          const SizedBox(height: 24),

          _sectionLabel('Sobre o veículo'),
          const SizedBox(height: 12),
          _buildVehicleDropdown(),
          const SizedBox(height: 14),
          _buildUseSelector(),
          const SizedBox(height: 14),
          _buildGarageSelector(),
          const SizedBox(height: 28),

          // Submit
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: widget.loading
                  ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_rounded, size: 20),
                  SizedBox(width: 10),
                  Text('Simular agora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Campos ────────────────────────────────────────────────

  Widget _buildName() => TextFormField(
    controller: _nameCtrl,
    textCapitalization: TextCapitalization.words,
    decoration: const InputDecoration(
      labelText: 'Nome completo',
      prefixIcon: Icon(Icons.person_outline, color: AppTheme.textHint, size: 20),
    ),
    validator: (v) => v != null && v.trim().length >= 2 ? null : 'Informe seu nome',
  );

  Widget _buildAge() => TextFormField(
    controller: _ageCtrl,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
    decoration: const InputDecoration(
      labelText: 'Idade',
      prefixIcon: Icon(Icons.cake_outlined, color: AppTheme.textHint, size: 20),
    ),
    validator: (v) {
      final age = int.tryParse(v ?? '');
      if (age == null || age < 18 || age > 99) return 'Idade inválida';
      return null;
    },
  );

  Widget _buildCep() => TextFormField(
    controller: _cepCtrl,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
    decoration: const InputDecoration(
      labelText: 'CEP',
      prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.textHint, size: 20),
    ),
    validator: (v) => v != null && v.length == 8 ? null : 'CEP com 8 dígitos',
  );

  Widget _buildVehicleDropdown() => DropdownButtonFormField<VehicleModel>(
    value: _vehicle,
    dropdownColor: AppTheme.surfaceLight,
    decoration: const InputDecoration(
      labelText: 'Modelo do veículo',
      prefixIcon: Icon(Icons.directions_car_outlined, color: AppTheme.textHint, size: 20),
    ),
    items: VehicleModel.values.map((v) => DropdownMenuItem(
      value: v,
      child: Text(v.label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
    )).toList(),
    onChanged: (v) => setState(() => _vehicle = v!),
  );

  Widget _buildUseSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Uso do veículo', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 8),
      Row(children: [
        _SelectChip(
          label: '🏠  Pessoal',
          selected: _use == VehicleUse.personal,
          onTap: () => setState(() => _use = VehicleUse.personal),
        ),
        const SizedBox(width: 10),
        _SelectChip(
          label: '🚗  Uber / App',
          selected: _use == VehicleUse.rideshare,
          onTap: () => setState(() => _use = VehicleUse.rideshare),
        ),
      ]),
    ],
  );

  Widget _buildGarageSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Possui garagem?', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 8),
      Row(children: [
        _SelectChip(
          label: '✅  Sim',
          selected: _hasGarage,
          onTap: () => setState(() => _hasGarage = true),
        ),
        const SizedBox(width: 10),
        _SelectChip(
          label: '❌  Não',
          selected: !_hasGarage,
          onTap: () => setState(() => _hasGarage = false),
        ),
      ]),
    ],
  );

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
  );
}

// ── Chip selecionável ─────────────────────────────────────────
class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.cardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}