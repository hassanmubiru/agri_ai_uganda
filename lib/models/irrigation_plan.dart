class IrrigationPlan {
  final String cropType;
  final String soilType;
  final double farmSize; // in acres
  final String frequency; // e.g., "Every 2 days"
  final String amount; // e.g., "500 Liters"
  final List<String> tips;

  IrrigationPlan({
    required this.cropType,
    required this.soilType,
    required this.farmSize,
    required this.frequency,
    required this.amount,
    required this.tips,
  });
}
