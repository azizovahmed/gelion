import 'dart:typed_data';

import 'food_image_url.dart';
import 'product_image_codec.dart';

/// Firestore: `imagePath` + to‘liq `imageUrl` (https://...).
class ParsedProductImage {
  const ParsedProductImage({
    this.networkUrl = '',
    this.storagePath = '',
    this.imageBytes,
  });

  final String networkUrl;
  final String storagePath;
  final Uint8List? imageBytes;

  bool get hasDisplayableImage =>
      isRenderableNetworkImageUrl(networkUrl) ||
      storagePath.isNotEmpty ||
      (imageBytes != null && imageBytes!.isNotEmpty);
}

ParsedProductImage parseProductImageFields(
  Map<String, dynamic> data, {
  String? documentId,
}) {
  final storagePath = parseFoodImagePath(data, documentId: documentId);
  final networkUrl = parseFoodImageUrl(data);

  final bytesOnly = ProductImageCodec.decodeFromFirestore(data['imageBytes']);
  if (bytesOnly != null && bytesOnly.isNotEmpty) {
    return ParsedProductImage(
      storagePath: storagePath,
      networkUrl: networkUrl,
      imageBytes: bytesOnly,
    );
  }

  if (storagePath.isNotEmpty || networkUrl.isNotEmpty) {
    return ParsedProductImage(
      storagePath: storagePath,
      networkUrl: networkUrl,
    );
  }

  return const ParsedProductImage();
}
