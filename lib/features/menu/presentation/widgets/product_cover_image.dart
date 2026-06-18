import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/firebase/firebase_media_api.dart';
import '../../../../core/widgets/safe_network_image.dart';
import '../../domain/food_image_url.dart';
import '../../domain/home_product.dart';
import '../../domain/product_image_pipeline.dart';

/// Backend `imageUrl` (to‘liq HTTPS) yoki Firestore `imagePath` → Storage URL.
class ProductCoverImage extends StatefulWidget {
  const ProductCoverImage({
    super.key,
    required this.product,
    this.memoryOverride,
    this.fit = BoxFit.cover,
    this.height,
    this.borderRadius = 16,
    this.topCornersOnly = false,
  });

  final HomeProduct product;
  final Uint8List? memoryOverride;
  final BoxFit fit;
  final double? height;
  final double borderRadius;
  final bool topCornersOnly;

  @override
  State<ProductCoverImage> createState() => _ProductCoverImageState();
}

class _ProductCoverImageState extends State<ProductCoverImage> {
  static const _maxResolveAttempts = 2;
  static const _maxLoadRetries = 1;

  String? _resolvedUrl;
  bool _loading = false;
  int _resolveAttempts = 0;
  int _loadRetries = 0;
  String _cacheKey = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(ProductCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final key =
        '${widget.product.id}|${widget.product.imagePath}|${widget.product.imageUrl}|${widget.product.image}';
    if (key != _cacheKey) {
      _resolveAttempts = 0;
      _loadRetries = 0;
      _bootstrap();
    }
  }

  void _bootstrap() {
    _cacheKey =
        '${widget.product.id}|${widget.product.imagePath}|${widget.product.imageUrl}|${widget.product.image}';

    final fromApi = FirebaseMediaApi.normalizeDownloadUrl(
      resolveDisplayImageUrl(widget.product.imageUrl),
    );
    if (isRenderableNetworkImageUrl(fromApi)) {
      setState(() {
        _resolvedUrl = fromApi;
        _loading = false;
      });
      return;
    }
    _resolveFromStorage();
  }

  Future<void> _resolveFromStorage() async {
    if (_resolveAttempts >= _maxResolveAttempts) {
      if (mounted) {
        setState(() {
          _loading = false;
          _resolvedUrl = null;
        });
      }
      return;
    }
    _resolveAttempts++;

    final p = widget.product;
    if (widget.memoryOverride != null && widget.memoryOverride!.isNotEmpty) {
      setState(() {
        _resolvedUrl = null;
        _loading = false;
      });
      return;
    }
    if (p.imageBytes != null && p.imageBytes!.isNotEmpty) {
      setState(() {
        _resolvedUrl = null;
        _loading = false;
      });
      return;
    }
    if (p.imagePath.isEmpty && p.image.isEmpty && p.id.isEmpty) {
      setState(() {
        _resolvedUrl = null;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    final result = await ProductImagePipeline.resolveForProduct(p);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _resolvedUrl = result.canRender ? result.downloadUrl : null;
    });

    ProductImagePipeline.logRenderStatus(
      productId: p.id,
      status: result.canRender ? 'success' : 'placeholder',
      url: _resolvedUrl,
      error: result.error,
    );
  }

  void _onImageLoadFailed() {
    if (_loadRetries >= _maxLoadRetries) return;
    _loadRetries++;
    _resolveAttempts = 0;
    _resolveFromStorage();
  }

  BorderRadius get _radius => widget.topCornersOnly
      ? BorderRadius.vertical(top: Radius.circular(widget.borderRadius))
      : BorderRadius.circular(widget.borderRadius);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final localPreview = widget.memoryOverride;
    final url = _resolvedUrl;

    return ClipRRect(
      borderRadius: _radius,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite && constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final h = widget.height ??
              (constraints.maxHeight.isFinite && constraints.maxHeight > 0
                  ? constraints.maxHeight
                  : 140.0);

          Widget child;

          if (url != null && isRenderableNetworkImageUrl(url)) {
            final dpr = MediaQuery.devicePixelRatioOf(context);
            final memCacheWidth = (width * dpr).round().clamp(128, 1400);
            child = SafeNetworkImage(
              imageUrl: url,
              cacheKey: '${widget.product.id}|${widget.product.imagePath}|$url',
              fit: widget.fit,
              width: width,
              height: h,
              memCacheWidth: memCacheWidth,
              onLoadFailed: _onImageLoadFailed,
              loadingColor: dark ? const Color(0xFFFFB74D) : const Color(0xFFFF8C00),
              errorLabel: 'Rasm yuklanmadi',
            );
          } else if (localPreview != null && localPreview.isNotEmpty) {
            child = Image.memory(
              localPreview,
              width: width,
              height: h,
              fit: widget.fit,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            );
          } else if (_loading) {
            child = ColoredBox(
              color: dark ? const Color(0xFF2A2430) : const Color(0xFFFFF2E2),
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: dark ? const Color(0xFFFFB74D) : const Color(0xFFFF8C00),
                  ),
                ),
              ),
            );
          } else {
            final bytes = widget.product.imageBytes;
            if (bytes != null && bytes.isNotEmpty) {
              child = Image.memory(
                bytes,
                width: width,
                height: h,
                fit: widget.fit,
                gaplessPlayback: true,
              );
            } else {
              child = SafeNetworkImage(
                imageUrl: '',
                width: width,
                height: h,
                errorLabel: 'Rasm topilmadi',
              );
            }
          }

          return SizedBox(width: width, height: h, child: child);
        },
      ),
    );
  }
}
