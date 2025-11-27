import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:coo_list/logic/selected_category/selected_category_bloc.dart';
import 'package:coo_list/logic/selected_category/selected_category_event.dart';
import 'package:coo_list/utils/category_images.dart';
import 'package:coo_list/utils/style_utils.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int listType;

  const CategoryCard({
    super.key,
    required this.category,
    required this.listType,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryImagePath =
        CategoryImages.getImageForCategory(category.name);

    final int itemCount = category.itemCount ?? 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: StyleUtils.cardBorderRadius,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 3,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: StyleUtils.cardBorderRadius,
        child: InkWell(
          onTap: () {
            context.read<SelectedCategoryBloc>().add(SelectCategory(
                  category: category,
                  listType: listType,
                ));
          },
          borderRadius: StyleUtils.cardBorderRadius,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  width: StyleUtils.categoryImageSize,
                  height: StyleUtils.categoryImageSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      categoryImagePath,
                      width: StyleUtils.categoryImageSize,
                      height: StyleUtils.categoryImageSize,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.name,
                          style: StyleUtils.categoryNameStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$itemCount termék',
                          style: StyleUtils.itemCountStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
