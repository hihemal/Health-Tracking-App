
class HealthStats {
  static double average(List<double> values) {
    if (values.isEmpty) return 0;

    return values.reduce((a, b) => a + b) / values.length;
  }

  static double minimum(List<double> values) {
    if (values.isEmpty) return 0;

    return values.reduce((a, b) => a < b ? a : b);
  }

  static double maximum(List<double> values) {
    if (values.isEmpty) return 0;

    return values.reduce((a, b) => a > b ? a : b);
  }
}
