import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/network/eh_image_cache_manager.dart';
import '../core/parser/gallery_detail_parser.dart';

class ThumbnailGrid extends StatelessWidget {
  final List<ThumbnailInfo> thumbnails;
  final void Function(int index)? onThumbnailTap;

  const ThumbnailGrid({
    super.key,
    required this.thumbnails,
    this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: thumbnails.length,
      itemBuilder: (context, index) {
        final thumb = thumbnails[index];
        return GestureDetector(
          onTap: () => onThumbnailTap?.call(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: thumb.isSprite
                ? _buildSpriteThumbnail(context, thumb)
                : CachedNetworkImage(
                    imageUrl: thumb.thumbUrl,
                    fit: BoxFit.cover,
                    cacheManager: EhImageCacheManager.instance,
                    placeholder: (_, __) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSpriteThumbnail(BuildContext context, ThumbnailInfo thumb) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = constraints.maxWidth;
        final cellH = constraints.maxHeight;
        final scaleX = cellW / thumb.spriteWidth;
        final scaleY = cellH / thumb.spriteHeight;
        final scale = scaleX > scaleY ? scaleX : scaleY;

        return ClipRect(
          child: SizedBox(
            width: cellW,
            height: cellH,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: Offset(
                  -thumb.spriteOffsetX * scale,
                  -thumb.spriteOffsetY * scale,
                ),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: CachedNetworkImage(
                    imageUrl: thumb.thumbUrl,
                    cacheManager: EhImageCacheManager.instance,
                    placeholder: (_, __) => SizedBox(
                      width: cellW,
                      height: cellH,
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                    errorWidget: (_, __, ___) => SizedBox(
                      width: cellW,
                      height: cellH,
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
