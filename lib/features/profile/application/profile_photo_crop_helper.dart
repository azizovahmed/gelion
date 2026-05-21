import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Crop ekrani UI (platformaga mos).
List<PlatformUiSettings> buildProfileCropUiSettings(
  BuildContext context,
  AppLocalizations l10n,
) {
  if (kIsWeb) {
    final w = MediaQuery.sizeOf(context).width;
    return [
      WebUiSettings(
        context: context,
        presentStyle: WebPresentStyle.dialog,
        size: CropperSize(
          width: (w - 48).clamp(280, 640).toInt(),
          height: 520,
        ),
        modal: true,
        barrierColor: Colors.black54,
      ),
    ];
  }

  return [
    AndroidUiSettings(
      toolbarTitle: l10n.profilePhotoCropDone,
      toolbarWidgetColor: Colors.white,
      toolbarColor: const Color(0xFFFF8C00),
      activeControlsWidgetColor: const Color(0xFFFFB300),
      backgroundColor: Colors.black,
      dimmedLayerColor: Colors.black87,
      cropFrameColor: Colors.white,
      cropGridColor: Colors.white70,
      lockAspectRatio: true,
      hideBottomControls: false,
      cropStyle: CropStyle.circle,
      initAspectRatio: CropAspectRatioPreset.square,
    ),
    IOSUiSettings(
      title: l10n.profilePhotoTitle,
      doneButtonTitle: l10n.profilePhotoCropDone,
      cancelButtonTitle: l10n.profileCancel,
      aspectRatioLockEnabled: true,
      resetAspectRatioEnabled: false,
      cropStyle: CropStyle.circle,
    ),
  ];
}

/// Crop tugmasi bosilganda fayl yo‘lini bytes ga aylantiradi. Bekor qilinsa `null`.
Future<Uint8List?> cropProfileImageToBytes({
  required BuildContext context,
  required String sourcePath,
  required AppLocalizations l10n,
}) async {
  final trimmed = sourcePath.trim();
  if (trimmed.isEmpty) return null;

  CroppedFile? cropped;
  try {
    cropped = await ImageCropper().cropImage(
      sourcePath: trimmed,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 88,
      uiSettings: buildProfileCropUiSettings(context, l10n),
    );
  } catch (_) {
    return null;
  }

  if (cropped == null) return null;

  return readCroppedImageBytes(cropped.path);
}

Future<Uint8List?> readCroppedImageBytes(String? path) async {
  final p = path?.trim() ?? '';
  if (p.isEmpty) return null;

  try {
    final bytes = await XFile(p).readAsBytes();
    if (bytes.isEmpty) return null;
    return Uint8List.fromList(bytes);
  } catch (_) {
    return null;
  }
}
