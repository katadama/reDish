import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomContextMenu extends StatefulWidget {
  final Widget child;

  final List<CustomContextMenuItem> menuItems;

  final Color menuBackgroundColor;

  final double menuBorderRadius;

  final double menuElevation;

  final EdgeInsets menuPadding;

  final Duration animationDuration;

  final bool useBlurEffect;

  final double blurSigma;

  final VoidCallback? onMenuOpen;

  final VoidCallback? onMenuClose;

  static _CustomContextMenuState? _activeContextMenuState;

  static void removeOverlay() {
    _activeContextMenuState?._removeOverlay();
  }

  const CustomContextMenu({
    super.key,
    required this.child,
    required this.menuItems,
    this.menuBackgroundColor = Colors.white,
    this.menuBorderRadius = 8.0,
    this.menuElevation = 4.0,
    this.menuPadding = const EdgeInsets.symmetric(vertical: 0),
    this.animationDuration = const Duration(milliseconds: 150),
    this.useBlurEffect = true,
    this.blurSigma = 5.0,
    this.onMenuOpen,
    this.onMenuClose,
  });

  @override
  State<CustomContextMenu> createState() => _CustomContextMenuState();
}

class _CustomContextMenuState extends State<CustomContextMenu>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;

  final GlobalKey _widgetKey = GlobalKey();

  late AnimationController _animationController;

  bool _isMenuShowing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _widgetKey,
      onLongPress: () => _showContextMenu(context),
      onTapDown: (details) => _storeTapPosition(details),
      onSecondaryTapDown: (details) {
        _storeTapPosition(details);
        _showContextMenu(context);
      },
      onTap: () {
        if (_isMenuShowing) {
          _removeOverlay();
        }
      },
      child: Opacity(
        opacity: _isMenuShowing ? 0.0 : 1.0,
        child: widget.child,
      ),
    );
  }

  void _storeTapPosition(TapDownDetails details) {
  }

  void _showContextMenu(BuildContext context) {
    if (_isMenuShowing) {
      return;
    }
    HapticFeedback.heavyImpact();
    CustomContextMenu._activeContextMenuState = this;
    _isMenuShowing = true;

    final RenderBox renderBox =
        _widgetKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    final double left = position.dx;
    final double itemTop = position.dy;
    final double itemBottom = itemTop + size.height;
    const double menuGap = 8.0;
    final double width = size.width;

    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    final double estimatedMenuHeight =
        widget.menuItems.length * 48.0 + widget.menuPadding.vertical;

    final bool wouldOverflowBottom =
        (itemBottom + menuGap + estimatedMenuHeight) > screenHeight;
    final bool wouldOverflowRight = (left + width) > screenWidth;

    double slideUpAmount = 0.0;
    if (wouldOverflowBottom) {
      final double overflowAmount =
          (itemBottom + menuGap + estimatedMenuHeight) - screenHeight;
      slideUpAmount = overflowAmount + 20.0;
    }

    final double top = itemBottom + menuGap;

    final double adjustedLeft = wouldOverflowRight
        ? screenWidth - width
        : left;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Positioned.fill(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _removeOverlay,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5.0 * _animationController.value,
                            sigmaY: 5.0 * _animationController.value,
                          ),
                          child: Container(
                            color: Colors.black
                                .withValues(alpha: 0.1 * _animationController.value),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: left,
                      top: position.dy,
                      width: width,
                      height: size.height,
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return Positioned(
                left: adjustedLeft,
                top: position.dy,
                width: width,
                height: size.height,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1.0, end: 1.03),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) {
                    final double yOffset = _isMenuShowing
                        ? -slideUpAmount *
                            _animationController
                                .value
                        : 0.0;

                    return Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.scale(
                        scale: _isMenuShowing ? scale : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(widget.menuBorderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: 0.15 * _animationController.value),
                                blurRadius: 8.0 * _animationController.value,
                                spreadRadius: 2.0 * _animationController.value,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(widget.menuBorderRadius),
                            child: Material(
                              color: Colors.transparent,
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final double menuYOffset = wouldOverflowBottom
                  ? -slideUpAmount *
                      _animationController.value
                  : 0.0;

              return Positioned(
                left: adjustedLeft,
                top: top + menuYOffset,
                width:
                    width,
                child: child!,
              );
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final alignment = wouldOverflowBottom
                    ? Alignment.bottomCenter
                    : Alignment.topCenter;

                return Transform.scale(
                  scale: 0.82 +
                      (0.2 *
                          _animationController.value),
                  alignment: alignment,
                  child: Opacity(
                    opacity: _animationController
                        .value,
                    child: Container(
                      width: width,
                      constraints: BoxConstraints(
                        minWidth: width,
                        maxWidth: width,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: widget.useBlurEffect
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(widget.menuBorderRadius),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: widget.blurSigma,
                              sigmaY: widget.blurSigma),
                          child: _buildMenuContainer(),
                        ),
                      )
                    : _buildMenuContainer(),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _animationController.forward();

    widget.onMenuOpen?.call();
  }

  Widget _buildMenuContainer() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      decoration: BoxDecoration(
        color: widget.useBlurEffect
            ? widget.menuBackgroundColor.withValues(alpha: 1.0)
            : widget.menuBackgroundColor,
        borderRadius: BorderRadius.circular(widget.menuBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: widget.menuElevation,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: widget.menuPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildMenuItems(),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    final List<Widget> items = [];

    for (int i = 0; i < widget.menuItems.length; i++) {
      final item = widget.menuItems[i];

      if (item is CustomContextMenuDivider) {
        items.add(
          SizedBox(
            width: double.infinity,
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.withValues(alpha: 0.2),
            ),
          ),
        );
        continue;
      }

      items.add(SizedBox(
        width: double.infinity,
        child: _buildMenuItem(item),
      ));

      if (i < widget.menuItems.length - 1 &&
          widget.menuItems[i + 1] is! CustomContextMenuDivider) {
        items.add(
          const SizedBox(
            width: double.infinity,
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    return items;
  }

  Widget _buildMenuItem(CustomContextMenuItem item) {
    return InkWell(
      onTap: () {
        _removeOverlay();
        if (mounted) {
          item.onTap?.call();
        }
      },
      borderRadius: BorderRadius.circular(widget.menuBorderRadius / 2),
      splashColor: Colors.grey.withValues(alpha: 0.1),
      highlightColor: Colors.grey.withValues(alpha: 0.05),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                color: item.isDestructive ? Colors.red : item.iconColor,
                size: 16.0,
              ),
              const SizedBox(width: 12.0),
            ],
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.isDestructive ? Colors.red : Colors.black87,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeOverlay() {
    if (_overlayEntry != null && _isMenuShowing) {
      if (_animationController.isAnimating || _animationController.value > 0) {
        _animationController.reverse().then((_) {
          if (_overlayEntry != null && mounted) {
            _overlayEntry!.remove();
            _overlayEntry = null;
            _isMenuShowing = false;

            if (CustomContextMenu._activeContextMenuState == this) {
              CustomContextMenu._activeContextMenuState = null;
            }

            widget.onMenuClose?.call();
          }
        });
      } else {
        _overlayEntry!.remove();
        _overlayEntry = null;
        _isMenuShowing = false;

        if (CustomContextMenu._activeContextMenuState == this) {
          CustomContextMenu._activeContextMenuState = null;
        }

        if (mounted) {
          widget.onMenuClose?.call();
        }
      }
    }
  }
}

class CustomContextMenuItem {
  final String title;

  final IconData? icon;

  final Color iconColor;

  final bool isDestructive;

  final VoidCallback? onTap;

  CustomContextMenuItem({
    required this.title,
    this.icon,
    this.iconColor = Colors.black87,
    this.isDestructive = false,
    this.onTap,
  });
}

class CustomContextMenuDivider extends CustomContextMenuItem {
  CustomContextMenuDivider()
      : super(
          title: '',
          onTap: null,
        );
}
