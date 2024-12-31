import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ReciplanImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const ReciplanImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetworkImage(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      );
    } else {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        );
      } else {
        return Container(
          height: height,
          width: width,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.image_not_supported),
          ),
        );
      }
    }
  }
}






// //Image Loader with caching
// class NetworkImageWithPlaceholder extends StatelessWidget {
//   final String imageUrl;
//   final double height;
//   final double width;
//   final BoxFit fit;

//   const NetworkImageWithPlaceholder({
//     super.key,
//     required this.imageUrl,
//     required this.height,
//     required this.width,
//     this.fit = BoxFit.cover,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CachedNetworkImage(
//       imageUrl: imageUrl,
//       height: height,
//       width: width,
//       fit: fit,
//       placeholder: (context, url) => Container(
//         color: Colors.grey[300],
//         child: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//       errorWidget: (context, url, error) => Container(
//         color: Colors.grey[300],
//         child: const Icon(Icons.error),
//       ),
//     );
//   }
// }
