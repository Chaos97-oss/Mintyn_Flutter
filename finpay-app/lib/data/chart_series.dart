/// Mock monthly series (Jan–Jun) for different time ranges — drives chart shape per filter.
abstract final class ChartSeries {
  static const weekly = <double>[420, 510, 380, 640, 720, 690];
  static const monthly = <double>[1200, 1800, 2200, 3657, 2800, 3657];
  static const today = <double>[40, 55, 30, 90, 120, 85];
  static const yearly = <double>[8200, 9100, 10400, 13200, 11800, 14600];

  /// Home: Weekly | Monthly | Today
  static List<double> forHomeFilter(int index) {
    switch (index) {
      case 0:
        return weekly;
      case 1:
        return monthly;
      case 2:
        return today;
      default:
        return monthly;
    }
  }

  /// Activity: Weekly | Monthly | Today | Year
  static List<double> forActivityFilter(int index) {
    switch (index) {
      case 0:
        return weekly;
      case 1:
        return monthly;
      case 2:
        return today;
      case 3:
        return yearly;
      default:
        return monthly;
    }
  }

  /// Card transaction sheet: Weekly | Monthly | Yearly | Today
  static List<double> forCardRange(int index) {
    switch (index) {
      case 0:
        return weekly.map((e) => e * 0.08).toList();
      case 1:
        return monthly.map((e) => e * 0.09).toList();
      case 2:
        return yearly.map((e) => e * 0.006).toList();
      case 3:
        return today.map((e) => e * 0.15).toList();
      default:
        return weekly.map((e) => e * 0.08).toList();
    }
  }
}
