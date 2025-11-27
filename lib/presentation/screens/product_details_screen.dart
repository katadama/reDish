import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/repositories/category_repository.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_state.dart';
import 'package:coo_list/logic/product/product_details_bloc.dart';
import 'package:coo_list/logic/product/product_details_event.dart';
import 'package:coo_list/logic/product/product_details_state.dart';
import 'package:line_icons/line_icons.dart';
import 'package:coo_list/utils/category_images.dart';
import 'package:coo_list/utils/category_icons.dart';
import 'package:coo_list/utils/profile_colors.dart';
import 'package:coo_list/utils/style_utils.dart';
import 'package:coo_list/utils/date_utils.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  final File? image;
  final String? productId;
  final int initialListType;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    this.image,
    this.productId,
    this.initialListType = 2,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailsBloc(
        product: product,
        categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
        productId: productId,
        initialListType: initialListType,
      ),
      child: Builder(
          builder: (context) => GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  context
                      .read<ProductDetailsBloc>()
                      .add(const UnfocusFieldEvent());
                },
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leading: IconButton(
                      padding: const EdgeInsets.only(left: 7),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: Color(0xFF000000),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    centerTitle: true,
                    title: const Text(
                      'Termék adatai',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        color: Color(0xFF000000),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  body: BlocConsumer<ProductDetailsBloc, ProductDetailsState>(
                    listener: (context, state) {
                      if (state is ProductDetailsSaveSuccess) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Termék sikeresen mentve'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        Navigator.of(context).pop({
                          'refresh': true,
                          'listType': state.listType,
                        });
                      } else if (state is ProductDetailsSaveError) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hiba: ${state.message}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is! ProductDetailsInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF34744),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Focus(
                                        onFocusChange: (hasFocus) {},
                                        child: TextFormField(
                                          initialValue: state.product.name,
                                          style: const TextStyle(
                                            fontFamily: 'SF Pro',
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF333333),
                                          ),
                                          maxLines: 2,
                                          minLines: 1,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 0,
                                              vertical: 12,
                                            ),
                                            filled: false,
                                            hintText: 'Termék neve',
                                            isCollapsed: false,
                                          ),
                                          onChanged: (value) {
                                            context
                                                .read<ProductDetailsBloc>()
                                                .add(UpdateProductEvent(
                                                  state.product
                                                      .copyWith(name: value),
                                                ));
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.10),
                                            blurRadius: 3,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildToggleButton(
                                            context: context,
                                            icon: LineIcons.shoppingCart,
                                            isSelected:
                                                state.selectedListType == 1,
                                            onTap: () => context
                                                .read<ProductDetailsBloc>()
                                                .add(
                                                    const ToggleListTypeEvent()),
                                            backgroundColor:
                                                state.selectedListType == 1
                                                    ? Colors.red
                                                    : Colors.white,
                                            iconColor:
                                                state.selectedListType == 1
                                                    ? Colors.white
                                                    : Colors.grey,
                                          ),
                                          _buildToggleButton(
                                            context: context,
                                            icon: LineIcons.home,
                                            isSelected:
                                                state.selectedListType == 2,
                                            onTap: () => context
                                                .read<ProductDetailsBloc>()
                                                .add(
                                                    const ToggleListTypeEvent()),
                                            backgroundColor:
                                                state.selectedListType == 2
                                                    ? Colors.red
                                                    : Colors.white,
                                            iconColor:
                                                state.selectedListType == 2
                                                    ? Colors.white
                                                    : Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 32, 24, 24),
                              children: [
                                _build2x2InfoGrid(context, state),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 4, bottom: 16, top: 8),
                                  child: Text(
                                    'Részletek',
                                    style: StyleUtils.listHeaderStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                _buildDetailsGrid(context, state),
                              ],
                            ),
                          ),
                          BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
                            builder: (context, state) {
                              if (state is! ProductDetailsInitial) {
                                return const SizedBox.shrink();
                              }

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      offset: const Offset(0, -4),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: state is ProductDetailsSaving
                                        ? null
                                        : () => _saveProduct(context),
                                    borderRadius: BorderRadius.circular(15),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: const Color(
                                            0xFFFF4D4F),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: const Color(0xFFF2F3FA)
                                              .withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18),
                                        child: state is ProductDetailsSaving
                                            ? const Center(
                                                child: SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                ),
                                              )
                                            : const Center(
                                                child: Text(
                                                  'Mentés',
                                                  style: TextStyle(
                                                    fontFamily: 'SF Pro',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              )),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? (backgroundColor ?? Theme.of(context).primaryColor)
                : (backgroundColor == Colors.white
                    ? Colors.white
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                isSelected ? (iconColor ?? Colors.white) : Colors.grey.shade600,
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

  Widget _build2x2InfoGrid(BuildContext context, ProductDetailsInitial state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCategoryCard(context, state),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProfileCard(context, state),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildAddedDateCard(context, state),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildExpirationOrTimeCard(context, state),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, ProductDetailsInitial state) {
    final ProductDetailsBloc bloc = context.read<ProductDetailsBloc>();
    final List<String> categories = bloc.categories;

    final String currentCategory = state.product.category;
    final bool categoryExists = categories.contains(currentCategory);

    final List<String> displayCategories = [...categories];
    if (!categoryExists && currentCategory.isNotEmpty) {
      displayCategories.add(currentCategory);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Kategória',
            style: TextStyle(
              fontFamily: 'SF Pro',
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF2F3FA),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.only(
            left: 5,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentCategory,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                size: 25,
                color: Colors.grey.shade500,
              ),
              onTap: () {
                bloc.add(const ReloadCategoriesEvent());
              },
              items: displayCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          CategoryImages.getImageForCategory(category),
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              CategoryIcons.getIconForCategory(category),
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<ProductDetailsBloc>().add(UpdateProductEvent(
                        state.product.copyWith(category: value),
                      ));
                }
              },
              selectedItemBuilder: (BuildContext context) {
                return displayCategories.map<Widget>((String category) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            CategoryImages.getImageForCategory(category),
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                CategoryIcons.getIconForCategory(category),
                                size: 40,
                                color: Colors.black54,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, ProductDetailsInitial state) {
    if (state.product.profileName == null ||
        state.product.profileName!.isEmpty ||
        state.product.profileColorIndex == null) {
      return const SizedBox.shrink();
    }

    final String profileName = state.product.profileName!;
    final int profileColorIndex = state.product.profileColorIndex!;
    final String profileInitial =
        profileName.isNotEmpty ? profileName[0].toUpperCase() : '?';

    Color profileColor;
    try {
      profileColor = ProfileColors.getColorByIndex(profileColorIndex);
    } catch (e) {
      profileColor = Colors.blue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Profil',
            style: TextStyle(
              fontFamily: 'SF Pro',
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF2F3FA),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: profileColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profileInitial,
                    style: TextStyle(
                      color: _isColorBright(profileColor)
                          ? Colors.black87
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profileName,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddedDateCard(
      BuildContext context, ProductDetailsInitial state) {
    if (state.product.lastMovedAt == null) {
      return const SizedBox.shrink();
    }

    final DateTime lastMovedAt = state.product.lastMovedAt!;
    final String formattedDate =
        '${lastMovedAt.year}.${lastMovedAt.month.toString().padLeft(2, '0')}.${lastMovedAt.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Listához hozzáadva',
            style: TextStyle(
              fontFamily: 'SF Pro',
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF2F3FA),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.subdirectory_arrow_right,
                size: 24,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontFamily: 'SF Pro',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpirationOrTimeCard(
      BuildContext context, ProductDetailsInitial state) {
    final int listType = state.selectedListType;
    final ProductModel product = state.product;

    if (product.lastMovedAt == null) {
      return const SizedBox.shrink();
    }

    if (listType == 2) {
      final daysUntilSpoiled = product.getDaysUntilSpoiled();
      if (daysUntilSpoiled == null) {
        return const SizedBox.shrink();
      }

      final String spoilageStatus =
          ProductDateUtils.getSpoilageStatusMessage(daysUntilSpoiled);
      final Color statusColor =
          ProductDateUtils.getSpoilageStatusColor(daysUntilSpoiled);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Lejárat',
              style: TextStyle(
                fontFamily: 'SF Pro',
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF2F3FA),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 24,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    spoilageStatus,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      final String timeInListMessage =
          ProductDateUtils.getTimeInListMessage(product.lastMovedAt!);
      const Color blueColor = Colors.blue;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Listában',
              style: TextStyle(
                fontFamily: 'SF Pro',
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF2F3FA),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.only(
              left: 9,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 26,
                  color: blueColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    timeInListMessage,
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: blueColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDetailsGrid(BuildContext context, ProductDetailsInitial state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildQuantityCard(context, state),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceCard(context, state),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildWeightCard(context, state),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSpoilageTimeCard(context, state),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceCard(BuildContext context, ProductDetailsInitial state) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, fieldState) {
        if (fieldState is! ProductDetailsInitial) {
          return const SizedBox.shrink();
        }

        final bool isEditing = fieldState.editingField == 'Price';

        return DetailItemWidget(
          title: 'Ár',
          value: '${fieldState.product.price} FT',
          imagePath: 'assets/images/ar.png',
          fieldName: 'Price',
          suffixText: 'Ft',
          labelText: 'Ár',
          isEditing: isEditing,
          onTap: () => context
              .read<ProductDetailsBloc>()
              .add(const StartEditingEvent('Price')),
          onChanged: (value) {
            final price = int.tryParse(value);
            if (price != null) {
              context.read<ProductDetailsBloc>().add(UpdateProductEvent(
                    fieldState.product.copyWith(price: price),
                  ));
            }
          },
        );
      },
    );
  }

  Widget _buildWeightCard(BuildContext context, ProductDetailsInitial state) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, fieldState) {
        if (fieldState is! ProductDetailsInitial) {
          return const SizedBox.shrink();
        }

        final bool isEditing = fieldState.editingField == 'Weight';

        return DetailItemWidget(
          title: 'Súly',
          value: '${fieldState.product.weight} g',
          imagePath: 'assets/images/suly.png',
          fieldName: 'Weight',
          suffixText: 'g',
          labelText: 'Súly',
          isEditing: isEditing,
          onTap: () => context
              .read<ProductDetailsBloc>()
              .add(const StartEditingEvent('Weight')),
          onChanged: (value) {
            final weight = int.tryParse(value);
            if (weight != null) {
              context.read<ProductDetailsBloc>().add(UpdateProductEvent(
                    fieldState.product.copyWith(weight: weight),
                  ));
            }
          },
        );
      },
    );
  }

  Widget _buildQuantityCard(BuildContext context, ProductDetailsInitial state) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, fieldState) {
        if (fieldState is! ProductDetailsInitial) {
          return const SizedBox.shrink();
        }

        final bool isEditing = fieldState.editingField == 'Quantity';

        return DetailItemWidget(
          title: 'Mennyiség',
          value: '${fieldState.product.db} darab',
          imagePath: 'assets/images/mennyiseg.png',
          fieldName: 'Quantity',
          suffixText: 'darab',
          labelText: 'Mennyiség',
          isEditing: isEditing,
          onTap: () => context
              .read<ProductDetailsBloc>()
              .add(const StartEditingEvent('Quantity')),
          onChanged: (value) {
            final quantity = int.tryParse(value);
            if (quantity != null) {
              final validQuantity = quantity <= 0 ? 1 : quantity;
              context.read<ProductDetailsBloc>().add(UpdateProductEvent(
                    fieldState.product.copyWith(db: validQuantity),
                  ));
            }
          },
        );
      },
    );
  }

  Widget _buildSpoilageTimeCard(
      BuildContext context, ProductDetailsInitial state) {
    return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
      builder: (context, fieldState) {
        if (fieldState is! ProductDetailsInitial) {
          return const SizedBox.shrink();
        }

        final bool isEditing = fieldState.editingField == 'Lejárati idő';

        return DetailItemWidget(
          title: 'Lejárat',
          value: '${fieldState.product.spoilage} nap',
          imagePath: 'assets/images/lejarat.png',
          fieldName: 'Lejárati idő',
          suffixText: 'nap',
          labelText: 'Lejárat',
          isEditing: isEditing,
          onTap: () => context
              .read<ProductDetailsBloc>()
              .add(const StartEditingEvent('Lejárati idő')),
          onChanged: (value) {
            final days = int.tryParse(value);
            if (days != null) {
              context.read<ProductDetailsBloc>().add(UpdateProductEvent(
                    fieldState.product.copyWith(spoilage: days),
                  ));
            }
          },
          errorFallbackIcon: const Icon(
            Icons.access_time_outlined,
            size: 24,
            color: Colors.black54,
          ),
        );
      },
    );
  }

  Future<void> _saveProduct(BuildContext context) async {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is! ProfileSelected) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nincs kiválasztott profil'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final bloc = context.read<ProductDetailsBloc>();
    final state = bloc.state;

    if (state is ProductDetailsInitial) {
      if (state.product.db <= 0) {
        bloc.add(UpdateProductEvent(
          state.product.copyWith(db: 1),
        ));
      }
    }

    bloc.add(SaveProductEvent(profileState.profile.id));
  }
}

class DetailItemWidget extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;
  final String fieldName;
  final String suffixText;
  final String labelText;
  final bool isEditing;
  final Function(String) onChanged;
  final VoidCallback onTap;
  final Widget? errorFallbackIcon;

  const DetailItemWidget({
    super.key,
    required this.title,
    required this.value,
    required this.imagePath,
    required this.fieldName,
    required this.suffixText,
    required this.labelText,
    required this.isEditing,
    required this.onChanged,
    required this.onTap,
    this.errorFallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditing ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF2F3FA),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedCrossFade(
          firstChild: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 8, top: 15, right: 0, bottom: 15),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Image.asset(
                          imagePath,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return errorFallbackIcon ??
                                const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 24,
                                  color: Colors.black54,
                                );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'SF Pro',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          secondChild: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        context
                            .read<ProductDetailsBloc>()
                            .add(const UnfocusFieldEvent());
                      }
                    },
                    child: TextFormField(
                      initialValue: value.split(' ')[0],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixText: suffixText,
                        labelText: labelText,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState:
              isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ),
    );
  }
}
