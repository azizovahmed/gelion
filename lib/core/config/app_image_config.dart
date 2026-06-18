/// REST API ishlatilsa to‘liq URL uchun bazaviy domen.
/// Firebase Storage ishlatilsa bo‘sh qoldiring — URL Storage dan keladi.
abstract final class AppImageConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String uploadsPath = '/uploads/';
}

/// Chala rasm nomini (masalan `pizza.jpg`) to‘liq URL ga aylantiradi.
String coerceRelativeImageToFull(
  String raw, {
  String baseUrl = AppImageConfig.apiBaseUrl,
  String uploadsPath = AppImageConfig.uploadsPath,
}) {
  var value = raw.trim();
  if (value.isEmpty) return '';

  if (value.startsWith('//')) value = 'https:$value';

  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }

  if (value.startsWith('foods/') ||
      value.startsWith('banners/') ||
      value.startsWith('categories/') ||
      value.startsWith('gs://')) {
    return value;
  }

  final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  if (base.isEmpty) return '';

  if (value.startsWith('/')) {
    return '$base$value';
  }

  final prefix = uploadsPath.startsWith('/') ? uploadsPath : '/$uploadsPath';
  final normalizedPrefix = prefix.endsWith('/') ? prefix : '$prefix/';
  return '$base$normalizedPrefix$value';
}

bool isPartialFilenameOnly(String value) {
  final v = value.trim();
  if (v.isEmpty || v.contains('://')) return false;
  if (v.startsWith('foods/') || v.startsWith('banners/')) return false;
  return !v.contains('/') && v.contains('.');
}
