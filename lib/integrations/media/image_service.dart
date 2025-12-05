import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

/// Image quality levels.
enum ImageQuality { low, medium, high, original }

/// Image compression configuration.
class ImageCompressionConfig {
  final int quality;
  final int? maxWidth;
  final int? maxHeight;
  final bool keepExif;

  const ImageCompressionConfig({
    this.quality = 85,
    this.maxWidth,
    this.maxHeight,
    this.keepExif = false,
  });

  factory ImageCompressionConfig.fromQuality(ImageQuality quality) {
    return switch (quality) {
      ImageQuality.low => const ImageCompressionConfig(
          quality: 50,
          maxWidth: 800,
          maxHeight: 800,
        ),
      ImageQuality.medium => const ImageCompressionConfig(
          quality: 70,
          maxWidth: 1200,
          maxHeight: 1200,
        ),
      ImageQuality.high => const ImageCompressionConfig(
          quality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        ),
      ImageQuality.original => const ImageCompressionConfig(
          quality: 100,
        ),
    };
  }
}

/// Image cache configuration.
class ImageCacheConfig {
  final int maxMemoryCacheSize;
  final int maxDiskCacheSize;
  final Duration stalePeriod;

  const ImageCacheConfig({
    this.maxMemoryCacheSize = 100 * 1024 * 1024, // 100 MB
    this.maxDiskCacheSize = 500 * 1024 * 1024, // 500 MB
    this.stalePeriod = const Duration(days: 7),
  });
}

/// Abstract image service interface.
abstract interface class ImageService {
  /// Loads a network image with caching.
  Widget loadNetworkImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
  });

  /// Compresses an image.
  Future<Result<Uint8List>> compressImage(
    Uint8List imageBytes, {
    ImageCompressionConfig config = const ImageCompressionConfig(),
  });

  /// Clears the image cache.
  Future<void> clearCache();

  /// Gets cache size in bytes.
  Future<int> getCacheSize();
}

/// Image service implementation.
/// Note: Requires cached_network_image and flutter_image_compress packages.
class ImageServiceImpl implements ImageService {
  final ImageCacheConfig cacheConfig;

  ImageServiceImpl({
    this.cacheConfig = const ImageCacheConfig(),
  });

  @override
  Widget loadNetworkImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
  }) {
    // Placeholder - requires cached_network_image package
    // return CachedNetworkImage(
    //   imageUrl: url,
    //   width: width,
    //   height: height,
    //   fit: fit,
    //   memCacheWidth: memCacheWidth,
    //   memCacheHeight: memCacheHeight,
    //   placeholder: (context, url) => placeholder ?? const CircularProgressIndicator(),
    //   errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
    // );

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );
  }

  @override
  Future<Result<Uint8List>> compressImage(
    Uint8List imageBytes, {
    ImageCompressionConfig config = const ImageCompressionConfig(),
  }) async {
    try {
      // Placeholder - requires flutter_image_compress package
      // final result = await FlutterImageCompress.compressWithList(
      //   imageBytes,
      //   quality: config.quality,
      //   minWidth: config.maxWidth ?? 1920,
      //   minHeight: config.maxHeight ?? 1080,
      //   keepExif: config.keepExif,
      // );
      // return Success(result);

      // Return original for now
      return Success(imageBytes);
    } catch (e) {
      return Failure(UnexpectedFailure('Image compression failed: $e'));
    }
  }

  @override
  Future<void> clearCache() async {
    // Placeholder - requires cached_network_image package
    // await CachedNetworkImage.evictFromCache(url);
    // or
    // await DefaultCacheManager().emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  @override
  Future<int> getCacheSize() async {
    // Placeholder - requires cached_network_image package
    // final cacheManager = DefaultCacheManager();
    // final info = await cacheManager.getFileFromCache(url);
    return 0;
  }
}

/// Image service factory.
ImageService createImageService({
  ImageCacheConfig config = const ImageCacheConfig(),
}) {
  return ImageServiceImpl(cacheConfig: config);
}
