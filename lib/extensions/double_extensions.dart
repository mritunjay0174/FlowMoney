extension DoubleExtensions on double {
  String get compact {
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(2);
  }

  String compactWithCurrency(String symbol) => '$symbol${compact}';
}
