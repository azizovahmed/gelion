import 'package:flutter/material.dart';

import '../../../../core/firebase/firebase_media_api.dart';
import '../../../../core/widgets/safe_network_image.dart';
import '../../domain/banner_image_pipeline.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/food_image_url.dart';

/// Firestore `imageUrl` (HTTPS) yoki `imagePath` → Storage download URL.
class BannerCoverImage extends StatefulWidget {
  const BannerCoverImage({
    super.key,
    required this.banner,
    this.fit = BoxFit.cover,
  });

  final PromoBanner banner;
  final BoxFit fit;

  @override
  State<BannerCoverImage> createState() => _BannerCoverImageState();
}

class _BannerCoverImageState extends State<BannerCoverImage> {
  String? _resolvedUrl;
  bool _loading = false;
  bool _loadFailed = false;
  bool _storageResolveAttempted = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(BannerCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banner.id != widget.banner.id ||
        oldWidget.banner.imagePath != widget.banner.imagePath ||
        oldWidget.banner.imageUrl != widget.banner.imageUrl) {
      _storageResolveAttempted = false;
      _loadFailed = false;
      _bootstrap();
    }
  }

  void _bootstrap() {
    final fromApi = FirebaseMediaApi.normalizeDownloadUrl(
      resolveDisplayImageUrl(widget.banner.imageUrl),
    );
    if (isRenderableNetworkImageUrl(fromApi)) {
      setState(() {
        _resolvedUrl = fromApi;
        _loading = false;
        _loadFailed = false;
      });
      return;
    }
    if (!_storageResolveAttempted) {
      _resolveFromStorage();
    }
  }

  Future<void> _resolveFromStorage() async {
    if (_storageResolveAttempted) return;
    _storageResolveAttempted = true;

    final banner = widget.banner;
    if (banner.imagePath.isEmpty && banner.id.isEmpty) {
      setState(() {
        _resolvedUrl = null;
        _loading = false;
        _loadFailed = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _loadFailed = false;
    });

    final result = await BannerImagePipeline.resolveForBanner(banner);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _resolvedUrl = result.canRender ? result.downloadUrl : null;
      _loadFailed = !result.canRender;
    });

    BannerImagePipeline.logRenderStatus(
      bannerId: banner.id,
      status: result.canRender ? 'widget_image_url' : 'widget_no_url',
      url: _resolvedUrl,
      error: result.error,
    );
  }

  void _onLoadFailed() {
    if (!mounted || _loadFailed) return;
    setState(() => _loadFailed = true);
  }

  Widget _placeholder() {
    return const ColoredBox(
      color: Color(0xFFFFF3E0),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Color(0xFFFF8C00),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;

    if (url != null && isRenderableNetworkImageUrl(url)) {
      return SizedBox.expand(
        child: SafeNetworkImage(
          imageUrl: url,
          cacheKey: '${widget.banner.id}|${widget.banner.imagePath}|$url',
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          onLoadFailed: _onLoadFailed,
          loadingColor: const Color(0xFFFF8C00),
          errorLabel: '',
        ),
      );
    }

    if (_loading) {
      return const SizedBox.expand(
        child: ColoredBox(
          color: Color(0xFFFFF3E0),
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8C00)),
            ),
          ),
        ),
      );
    }

    return SizedBox.expand(child: _placeholder());
  }
}
