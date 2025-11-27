import 'package:flutter/material.dart';
import 'package:coo_list/config/list_type_constants.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/utils/date_utils.dart';
import 'package:coo_list/utils/profile_colors.dart';
import 'package:coo_list/utils/style_utils.dart';

class ProductListItem extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final int listType;

  const ProductListItem({
    super.key,
    required this.product,
    this.onTap,
    this.listType = ListType.shopping,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilSpoiled = product.getDaysUntilSpoiled();
    final spoilageStatus = daysUntilSpoiled != null
        ? ProductDateUtils.getSpoilageStatusMessage(daysUntilSpoiled)
        : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          top: 10,
          right: 16,
          bottom: 8,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: Text(
                    product.name,
                    style: StyleUtils.categoryNameStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildInfoItemWithImage(
                      imagePath: 'assets/images/mennyiseg.png',
                      text: '${product.db} db',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoItemWithImage(
                      imagePath: 'assets/images/suly.png',
                      text: '${product.weight} g',
                    ),
                    const SizedBox(width: 12),
                    _buildInfoItemWithImage(
                      imagePath: 'assets/images/ar.png',
                      text: '${product.price} FT',
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                if (listType == ListType.shopping &&
                    product.lastMovedAt != null)
                  _buildTimeInListInfo(product.lastMovedAt!)
                else if (listType == ListType.home)
                  _buildSpoilageInfo(spoilageStatus, daysUntilSpoiled)
                else
                  _buildTimeInListInfo(
                      DateTime.now().subtract(const Duration(days: 3))),
              ],
            ),
            if (product.profileName != null && product.profileName!.isNotEmpty)
              Positioned(
                top: 0,
                right: 0,
                child: _buildProfileIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItemWithImage({
    required String imagePath,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          imagePath,
          width: 14,
          height: 14,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: StyleUtils.itemCountStyle,
        ),
      ],
    );
  }

  Widget _buildProfileIndicator() {
    if (product.profileName == null ||
        product.profileName!.isEmpty ||
        product.profileColorIndex == null) {
      return const SizedBox.shrink();
    }

    final profileInitial = product.profileName![0].toUpperCase();

    Color profileColor;
    try {
      profileColor = ProfileColors.getColorByIndex(product.profileColorIndex!);
    } catch (e) {
      profileColor = Colors.blue;
    }

    return Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: profileColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          profileInitial,
          style: TextStyle(
            color: _isColorBright(profileColor) ? Colors.black87 : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _isColorBright(Color color) {
    final brightness = (0.299 * (color.r * 255.0).round().clamp(0, 255) +
            0.587 * (color.g * 255.0).round().clamp(0, 255) +
            0.114 * (color.b * 255.0).round().clamp(0, 255)) /
        255;
    return brightness > 0.6;
  }

  Widget _buildSpoilageInfo(String spoilageStatus, int? daysUntilSpoiled) {
    final color = daysUntilSpoiled != null
        ? ProductDateUtils.getSpoilageStatusColor(daysUntilSpoiled)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            spoilageStatus,
            style: StyleUtils.itemCountStyle.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInListInfo(DateTime lastMovedDate) {
    const Color blueColor = Colors.blue;
    final timeInListMessage =
        ProductDateUtils.getTimeInListMessage(lastMovedDate);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Row(
        children: [
          const Icon(
            Icons.history_rounded,
            size: 16,
            color: blueColor,
          ),
          const SizedBox(width: 4),
          Text(
            timeInListMessage,
            style: StyleUtils.itemCountStyle.copyWith(color: blueColor),
          ),
        ],
      ),
    );
  }
}
