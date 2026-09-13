/// Common ISO 4217 currency codes for tenant setup.
abstract final class Currencies {
  Currencies._();

  static const List<String> all = [
    'USD',
    'EUR',
    'GBP',
    'CHF',
    'MKD',
    'RSD',
    'BAM',
    'ALL',
    'BGN',
    'HRK',
    'RON',
    'TRY',
    'PLN',
    'CZK',
    'HUF',
    'SEK',
    'NOK',
    'DKK',
    'CAD',
    'AUD',
    'NZD',
    'JPY',
    'CNY',
    'INR',
    'BRL',
    'MXN',
    'ZAR',
    'AED',
    'SAR',
  ];

  static final Set<String> _ids = all.toSet();

  static bool contains(String code) => _ids.contains(code.toUpperCase());
}
