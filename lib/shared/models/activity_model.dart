class DataPoint {
  final String label; // e.g., 'Jan', 'Feb'
  final double value;

  const DataPoint({
    required this.label,
    required this.value,
  });
}

class SpendingModel {
  final double totalSpending;
  final List<DataPoint> dataPoints;
  final String period; // e.g., 'Weekly', 'Monthly'

  const SpendingModel({
    required this.totalSpending,
    required this.dataPoints,
    required this.period,
  });
}
