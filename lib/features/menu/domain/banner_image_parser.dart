import 'food_image_url.dart';

/// Firestore: `imagePath` + to‘liq `imageUrl` (https://...).
class ParsedBannerImage {
  const ParsedBannerImage({
    this.networkUrl = '',
    this.storagePath = '',
  });

  final String networkUrl;
  final String storagePath;

  bool get hasDisplayableImage =>
      isRenderableNetworkImageUrl(networkUrl) || storagePath.isNotEmpty;
}

ParsedBannerImage parseBannerImageFields(
  Map<String, dynamic> data, {
  String? documentId,
}) {
  final storagePath = parseBannerImagePath(data, documentId: documentId);
  final networkUrl = parseFoodImageUrl(data);

  if (storagePath.isNotEmpty || networkUrl.isNotEmpty) {
    return ParsedBannerImage(
      storagePath: storagePath,
      networkUrl: networkUrl,
    );
  }

  return const ParsedBannerImage();
}
