import 'package:sub_sentry/features/subscriptions/domain/subscription.dart';

class SmartDefaults {
  static const Map<String, SubCategory> nameToCategory = {
    'netflix': SubCategory.entertainment,
    'disney': SubCategory.entertainment,
    'hulu': SubCategory.entertainment,
    'hbo': SubCategory.entertainment,
    'spotify': SubCategory.entertainment,
    'apple music': SubCategory.entertainment,
    'youtube': SubCategory.entertainment,
    'prime video': SubCategory.entertainment,
    'adobe': SubCategory.software,
    'creative cloud': SubCategory.software,
    'figma': SubCategory.software,
    'google': SubCategory.software,
    'microsoft': SubCategory.software,
    'office': SubCategory.software,
    'canva': SubCategory.software,
    'mobile': SubCategory.utilities,
    'vodafone': SubCategory.utilities,
    'ee': SubCategory.utilities,
    'three': SubCategory.utilities,
    'broadband': SubCategory.utilities,
    'virgin media': SubCategory.utilities,
    'sky': SubCategory.utilities,
    'gas': SubCategory.utilities,
    'electric': SubCategory.utilities,
    'water': SubCategory.utilities,
    'internet': SubCategory.utilities,
    'gym': SubCategory.gym,
    'fitness': SubCategory.gym,
    'strava': SubCategory.gym,
    'puregym': SubCategory.gym,
    'virgin active': SubCategory.gym,
    'chase': SubCategory.finance,
    'monzo': SubCategory.finance,
    'amex': SubCategory.finance,
    'revolut': SubCategory.finance,
    'starling': SubCategory.finance,
  };

  static const Map<String, double> nameToPrice = {
    'netflix': 10.99,
    'spotify': 11.99,
    'disney': 7.99,
    'prime video': 8.99,
    'apple music': 10.99,
    'youtube': 12.99,
    'adobe': 19.99,
    'strava': 8.99,
  };

  static SubCategory? getCategory(String name) {
    final lower = name.toLowerCase();
    for (final entry in nameToCategory.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static double? getPrice(String name) {
    final lower = name.toLowerCase();
    for (final entry in nameToPrice.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }
}
