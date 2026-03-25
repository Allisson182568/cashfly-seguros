// lib/features/insurance/insurance_service.dart
// Serviço de simulação de seguro auto (lógica mockada realista)

// ── Modelos de entrada ────────────────────────────────────────

enum VehicleUse { personal, rideshare }
enum VehicleModel {
  onix2025,
  hb202025,
  mobi2022,
}

extension VehicleModelLabel on VehicleModel {
  String get label => switch (this) {
    VehicleModel.onix2025  => 'Chevrolet Onix 2025',
    VehicleModel.hb202025  => 'Hyundai HB20 2025',
    VehicleModel.mobi2022  => 'Fiat Mobi 2022',
  };

  /// Preço base anual por modelo (tabela interna mockada)
  double get basePrice => switch (this) {
    VehicleModel.onix2025  => 2800.0,
    VehicleModel.hb202025  => 2650.0,
    VehicleModel.mobi2022  => 2200.0,
  };

  /// Preço médio de mercado (para exibir comparativo)
  double get marketPrice => switch (this) {
    VehicleModel.onix2025  => 3300.0,
    VehicleModel.hb202025  => 3050.0,
    VehicleModel.mobi2022  => 2600.0,
  };
}

// ── Dados do formulário ───────────────────────────────────────

class InsuranceFormData {
  final String name;
  final int age;
  final String cep;
  final VehicleModel vehicle;
  final VehicleUse use;
  final bool hasGarage;

  const InsuranceFormData({
    required this.name,
    required this.age,
    required this.cep,
    required this.vehicle,
    required this.use,
    required this.hasGarage,
  });
}

// ── Resultado da simulação ────────────────────────────────────

class InsuranceQuote {
  final double annualPrice;
  final double monthlyPrice;
  final double cashback;
  final double marketPrice;
  final double savings;

  const InsuranceQuote({
    required this.annualPrice,
    required this.monthlyPrice,
    required this.cashback,
    required this.marketPrice,
    required this.savings,
  });
}

// ── Service ───────────────────────────────────────────────────

class InsuranceService {
  InsuranceService._();

  /// Simula o valor do seguro com base nos dados do formulário.
  /// Regras de negócio:
  ///   - Idade < 25 → +25%
  ///   - Idade 25-35 → +10%
  ///   - Uso Uber → +30%
  ///   - Sem garagem → +15%
  ///   - Cashback fixo em 7% do valor anual (máx R$ 280)
  static Future<InsuranceQuote> simulate(InsuranceFormData data) async {
    // Simula latência de cálculo para UX com loading
    await Future.delayed(const Duration(milliseconds: 1200));

    double price = data.vehicle.basePrice;

    // Fator idade
    if (data.age < 25) {
      price *= 1.25;
    } else if (data.age <= 35) {
      price *= 1.10;
    } else if (data.age >= 60) {
      price *= 1.08; // leve aumento para idosos
    }

    // Uso rideshare
    if (data.use == VehicleUse.rideshare) price *= 1.30;

    // Sem garagem
    if (!data.hasGarage) price *= 1.15;

    // Arredonda para múltiplo de 10
    final annual = (price / 10).round() * 10.0;
    final monthly = (annual / 12 / 5).round() * 5.0; // arredonda para múltiplo de 5

    // Cashback: 7% do anual, máximo R$ 280
    final cashback = (annual * 0.07).clamp(0.0, 280.0);
    final cashbackRounded = (cashback / 10).round() * 10.0;

    final market = data.vehicle.marketPrice;
    final savings = (market - annual).clamp(0.0, double.infinity);

    return InsuranceQuote(
      annualPrice: annual,
      monthlyPrice: monthly,
      cashback: cashbackRounded,
      marketPrice: market,
      savings: savings,
    );
  }
}