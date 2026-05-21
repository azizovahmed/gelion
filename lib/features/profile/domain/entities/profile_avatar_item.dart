import 'package:flutter/foundation.dart';

@immutable
class ProfileAvatarItem {
  const ProfileAvatarItem._({
    required this.id,
    this.assetPath,
    this.networkUrl,
  });

  const ProfileAvatarItem.asset(String assetPath, {String? id})
      : this._(
          id: id ?? assetPath,
          assetPath: assetPath,
        );

  const ProfileAvatarItem.network(String id, String url)
      : this._(
          id: id,
          networkUrl: url,
        );

  final String id;
  final String? assetPath;
  final String? networkUrl;

  bool get isAsset => assetPath != null && assetPath!.isNotEmpty;
  bool get isNetwork => networkUrl != null && networkUrl!.isNotEmpty;
}
