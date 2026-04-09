import 'package:flutter/foundation.dart';

@immutable
class CurrencyEntry {
  final String code;
  final String symbol;
  final List<String> countries;

  const CurrencyEntry({
    required this.code,
    required this.symbol,
    required this.countries,
  });

  /// Returns true if [query] matches the code, symbol, or any country name.
  bool matches(String query) {
    final q = query.toLowerCase();
    if (code.toLowerCase().contains(q)) return true;
    if (symbol.toLowerCase().contains(q)) return true;
    return countries.any((c) => c.toLowerCase().contains(q));
  }

  /// Short label shown in the selected-currency tile and list rows.
  String get displayLabel => '$code  $symbol';
}

const List<CurrencyEntry> kCurrencies = [
  CurrencyEntry(code: 'AED', symbol: 'د.إ', countries: ['United Arab Emirates']),
  CurrencyEntry(code: 'AUD', symbol: '\$',  countries: ['Australia']),
  CurrencyEntry(code: 'BDT', symbol: '৳',  countries: ['Bangladesh']),
  CurrencyEntry(code: 'BOB', symbol: 'Bs.', countries: ['Bolivia']),
  CurrencyEntry(code: 'BRL', symbol: 'R\$', countries: ['Brazil']),
  CurrencyEntry(code: 'CAD', symbol: '\$',  countries: ['Canada']),
  CurrencyEntry(code: 'CHF', symbol: 'Fr.', countries: ['Liechtenstein', 'Switzerland']),
  CurrencyEntry(code: 'CLP', symbol: '\$',  countries: ['Chile']),
  CurrencyEntry(code: 'COP', symbol: '\$',  countries: ['Colombia']),
  CurrencyEntry(code: 'CRC', symbol: '₡',  countries: ['Costa Rica']),
  CurrencyEntry(code: 'CZK', symbol: 'Kč', countries: ['Czechia']),
  CurrencyEntry(code: 'DKK', symbol: 'kr', countries: ['Denmark']),
  CurrencyEntry(code: 'DZD', symbol: 'دج', countries: ['Algeria']),
  CurrencyEntry(code: 'EGP', symbol: '£',  countries: ['Egypt']),
  CurrencyEntry(code: 'EUR', symbol: '€',  countries: [
    'Austria', 'Belgium', 'Benin', 'Bulgaria', 'Burkina Faso',
    'Central African Republic', 'Croatia', 'Cyprus', 'Estonia',
    'Finland', 'France', 'Gabon', 'Germany', 'Greece', 'Guinea-Bissau',
    'Iceland', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg',
    'Mali', 'Malta', 'Monaco', 'Netherlands', 'Niger', 'Portugal',
    'San Marino', 'Slovakia', 'Slovenia', 'Spain', 'Togo', 'Vatican City',
  ]),
  CurrencyEntry(code: 'GBP', symbol: '£',  countries: ['Gibraltar', 'United Kingdom']),
  CurrencyEntry(code: 'GEL', symbol: '₾',  countries: ['Georgia']),
  CurrencyEntry(code: 'GHS', symbol: '₵',  countries: ['Ghana']),
  CurrencyEntry(code: 'HKD', symbol: '\$', countries: ['Hong Kong']),
  CurrencyEntry(code: 'HUF', symbol: 'Ft', countries: ['Hungary']),
  CurrencyEntry(code: 'IDR', symbol: 'Rp', countries: ['Indonesia']),
  CurrencyEntry(code: 'ILS', symbol: '₪',  countries: ['Israel']),
  CurrencyEntry(code: 'INR', symbol: '₹',  countries: ['India']),
  CurrencyEntry(code: 'IQD', symbol: 'ع.د', countries: ['Iraq']),
  CurrencyEntry(code: 'JOD', symbol: 'JD', countries: ['Jordan']),
  CurrencyEntry(code: 'JPY', symbol: '¥',  countries: ['Japan']),
  CurrencyEntry(code: 'KES', symbol: 'KSh', countries: ['Kenya']),
  CurrencyEntry(code: 'KRW', symbol: '₩',  countries: ['South Korea']),
  CurrencyEntry(code: 'KZT', symbol: '₸',  countries: ['Kazakhstan']),
  CurrencyEntry(code: 'LKR', symbol: 'Rs', countries: ['Sri Lanka']),
  CurrencyEntry(code: 'MAD', symbol: 'د.م.', countries: ['Morocco']),
  CurrencyEntry(code: 'MMK', symbol: 'K',  countries: ['Myanmar (Burma)']),
  CurrencyEntry(code: 'MNT', symbol: '₮',  countries: ['Mongolia']),
  CurrencyEntry(code: 'MOP', symbol: 'P',  countries: ['Macao']),
  CurrencyEntry(code: 'MXN', symbol: '\$', countries: ['Mexico']),
  CurrencyEntry(code: 'MYR', symbol: 'RM', countries: ['Malaysia']),
  CurrencyEntry(code: 'NGN', symbol: '₦',  countries: ['Nigeria']),
  CurrencyEntry(code: 'NOK', symbol: 'kr', countries: ['Norway']),
  CurrencyEntry(code: 'NZD', symbol: '\$', countries: ['New Zealand']),
  CurrencyEntry(code: 'PEN', symbol: 'S/', countries: ['Peru']),
  CurrencyEntry(code: 'PHP', symbol: '₱',  countries: ['Philippines']),
  CurrencyEntry(code: 'PKR', symbol: '₨',  countries: ['Pakistan']),
  CurrencyEntry(code: 'PLN', symbol: 'zł', countries: ['Poland']),
  CurrencyEntry(code: 'PYG', symbol: '₲',  countries: ['Paraguay']),
  CurrencyEntry(code: 'QAR', symbol: 'ر.ق', countries: ['Qatar']),
  CurrencyEntry(code: 'RON', symbol: 'lei', countries: ['Romania']),
  CurrencyEntry(code: 'RSD', symbol: 'din', countries: ['Serbia']),
  CurrencyEntry(code: 'RUB', symbol: '₽',  countries: ['Russia']),
  CurrencyEntry(code: 'SAR', symbol: 'ر.س', countries: ['Saudi Arabia']),
  CurrencyEntry(code: 'SEK', symbol: 'kr', countries: ['Sweden']),
  CurrencyEntry(code: 'SGD', symbol: '\$', countries: ['Singapore']),
  CurrencyEntry(code: 'THB', symbol: '฿',  countries: ['Thailand']),
  CurrencyEntry(code: 'TRY', symbol: '₺',  countries: ['Türkiye']),
  CurrencyEntry(code: 'TWD', symbol: 'NT\$', countries: ['Taiwan']),
  CurrencyEntry(code: 'TZS', symbol: 'TSh', countries: ['Tanzania']),
  CurrencyEntry(code: 'UAH', symbol: '₴',  countries: ['Ukraine']),
  CurrencyEntry(code: 'USD', symbol: '\$',  countries: [
    'Albania', 'Angola', 'Antigua & Barbuda', 'Argentina', 'Armenia',
    'Aruba', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Belarus', 'Belize',
    'Bermuda', 'Bosnia & Herzegovina', 'Botswana', 'British Virgin Islands',
    'Cambodia', 'Cape Verde', 'Cayman Islands', 'Chad', 'Comoros',
    'Congo - Brazzaville', 'Congo - Kinshasa', 'Djibouti', 'Dominica',
    'Dominican Republic', 'Ecuador', 'El Salvador', 'Eritrea', 'Fiji',
    'Gambia', 'Grenada', 'Guatemala', 'Guinea', 'Haiti', 'Honduras',
    'Jamaica', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Lebanon', 'Liberia',
    'Libya', 'Maldives', 'Mauritius', 'Micronesia', 'Moldova',
    'Mozambique', 'Namibia', 'Nepal', 'Nicaragua', 'North Macedonia',
    'Oman', 'Panama', 'Papua New Guinea', 'Rwanda', 'Samoa',
    'Seychelles', 'Sierra Leone', 'Solomon Islands', 'Somalia',
    'St Kitts & Nevis', 'St Lucia', 'Suriname', 'Tajikistan', 'Tonga',
    'Trinidad & Tobago', 'Tunisia', 'Turkmenistan', 'Turks & Caicos Islands',
    'Uganda', 'United States', 'Uruguay', 'Uzbekistan', 'Vanuatu',
    'Venezuela', 'Yemen', 'Zambia', 'Zimbabwe',
  ]),
  CurrencyEntry(code: 'VND', symbol: '₫',  countries: ['Vietnam']),
  CurrencyEntry(code: 'XAF', symbol: 'Fr', countries: ['Cameroon']),
  CurrencyEntry(code: 'XOF', symbol: 'Fr', countries: ['Côte d\'Ivoire', 'Senegal']),
  CurrencyEntry(code: 'ZAR', symbol: 'R',  countries: ['South Africa']),
];
