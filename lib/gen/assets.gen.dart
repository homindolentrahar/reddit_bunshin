/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsImagesGen {
  const $AssetsImagesGen();

  $AssetsImagesAwardGen get award => const $AssetsImagesAwardGen();

  /// File path: assets/images/google.png
  AssetGenImage get google => const AssetGenImage('assets/images/google.png');

  /// File path: assets/images/loginEmote.png
  AssetGenImage get loginEmote =>
      const AssetGenImage('assets/images/loginEmote.png');

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/images/logo.png');

  /// List of all assets
  List<AssetGenImage> get values => [google, loginEmote, logo];
}

class $AssetsImagesAwardGen {
  const $AssetsImagesAwardGen();

  /// File path: assets/images/award/awesomeanswer.png
  AssetGenImage get awesomeanswer =>
      const AssetGenImage('assets/images/award/awesomeanswer.png');

  /// File path: assets/images/award/gold.png
  AssetGenImage get gold => const AssetGenImage('assets/images/award/gold.png');

  /// File path: assets/images/award/helpful.png
  AssetGenImage get helpful =>
      const AssetGenImage('assets/images/award/helpful.png');

  /// File path: assets/images/award/platinum.png
  AssetGenImage get platinum =>
      const AssetGenImage('assets/images/award/platinum.png');

  /// File path: assets/images/award/plusone.png
  AssetGenImage get plusone =>
      const AssetGenImage('assets/images/award/plusone.png');

  /// File path: assets/images/award/rocket.png
  AssetGenImage get rocket =>
      const AssetGenImage('assets/images/award/rocket.png');

  /// File path: assets/images/award/thankyou.png
  AssetGenImage get thankyou =>
      const AssetGenImage('assets/images/award/thankyou.png');

  /// File path: assets/images/award/til.png
  AssetGenImage get til => const AssetGenImage('assets/images/award/til.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [awesomeanswer, gold, helpful, platinum, plusone, rocket, thankyou, til];
}

class Assets {
  Assets._();

  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
