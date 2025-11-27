import 'package:flutter/material.dart';
import 'package:coo_list/presentation/screens/scan_screen.dart';
import 'package:coo_list/presentation/screens/shopping_list_screen.dart';
import 'package:coo_list/presentation/screens/home_list_screen.dart';
import 'package:coo_list/presentation/screens/recipe_screen.dart';
import 'package:coo_list/presentation/screens/account_settings_screen.dart';
import 'package:coo_list/presentation/screens/category_detail_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/auth/auth_bloc.dart';
import 'package:coo_list/logic/auth/auth_state.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/profile/profile_event.dart';
import 'package:coo_list/logic/profile/profile_state.dart';
import 'package:coo_list/logic/selected_category/selected_category_bloc.dart';
import 'package:coo_list/logic/selected_category/selected_category_event.dart';
import 'package:coo_list/logic/selected_category/selected_category_state.dart';
import 'package:coo_list/logic/recipe/recipe_bloc.dart';
import 'package:coo_list/logic/recipe/recipe_event.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:coo_list/presentation/widgets/profile_avatar.dart';
import 'package:coo_list/config/app_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 2;
  RecipeBloc? _recipeBloc;
  bool _isRecipeGenerated = false;

  final List<String> _screenTitles = [
    'Szkennelés',
    'Bevásárló lista',
    'Otthoni lista',
    'Recept készítése',
    'Beállítások',
  ];

  void updateRecipeState(bool isGenerated) {
    if (_isRecipeGenerated != isGenerated) {
      setState(() {
        _isRecipeGenerated = isGenerated;
        if (isGenerated) {
          _screenTitles[3] = 'Recept';
        } else {
          _screenTitles[3] = 'Recept generátor';
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedProfile();
  }

  @override
  void dispose() {
    _recipeBloc?.close();
    super.dispose();
  }

  Future<void> _loadSelectedProfile() async {
    final profileBloc = context.read<ProfileBloc>();
    final profileState = profileBloc.state;
    if (profileState is ProfileSelected) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final lastProfileId = prefs.getString(AppRouter.lastSelectedProfileKey);

    if (!mounted) return;

    if (lastProfileId != null) {
      profileBloc.add(CheckProfileStatus(autoSelect: true));
    } else {
      profileBloc.add(LoadProfiles(autoSelect: false));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      context
          .read<SelectedCategoryBloc>()
          .add(const LoadSelectedCategory(listType: 1));
    } else if (index == 2) {
      context
          .read<SelectedCategoryBloc>()
          .add(const LoadSelectedCategory(listType: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        final categoryState = context.read<SelectedCategoryBloc>().state;
        if (categoryState is SelectedCategorySelected &&
            ((_selectedIndex == 1 && categoryState.listType == 1) ||
                (_selectedIndex == 2 && categoryState.listType == 2))) {
          context.read<SelectedCategoryBloc>().add(
                ClearSelectedCategory(
                  listType: categoryState.listType,
                ),
              );
          return;
        }
        Navigator.of(context).pop();
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.login,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return Scaffold(
              appBar: AppBar(
                title: BlocBuilder<SelectedCategoryBloc, SelectedCategoryState>(
                  builder: (context, categoryState) {
                    if ((categoryState is SelectedCategorySelected) &&
                        (_selectedIndex == 1 || _selectedIndex == 2)) {
                      return Text(
                        categoryState.category.name,
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    return Text(
                      _screenTitles[_selectedIndex],
                      style: const TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                leading:
                    BlocBuilder<SelectedCategoryBloc, SelectedCategoryState>(
                  builder: (context, categoryState) {
                    if (_selectedIndex == 3 && _isRecipeGenerated) {
                      return IconButton(
                        padding: const EdgeInsets.only(left: 7),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                        ),
                        onPressed: () {
                          _recipeBloc?.add(const ResetRecipeState());
                        },
                      );
                    }

                    if ((categoryState is SelectedCategorySelected) &&
                        (_selectedIndex == 1 || _selectedIndex == 2)) {
                      return IconButton(
                        padding: const EdgeInsets.only(left: 7),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                        ),
                        onPressed: () {
                          context.read<SelectedCategoryBloc>().add(
                                ClearSelectedCategory(
                                  listType: _selectedIndex == 1 ? 1 : 2,
                                ),
                              );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
              ),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _buildCurrentScreen(),
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10),
                    child: GNav(
                      rippleColor: Colors.grey[300]!,
                      hoverColor: Colors.grey[100]!,
                      gap: 3,
                      activeColor: const Color(0xFFF34744),
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      tabBackgroundColor: Colors.transparent,
                      color: Colors.grey[400],
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF34744),
                      ),
                      tabActiveBorder: Border.all(color: Colors.transparent),
                      tabBorder: Border.all(color: Colors.transparent),
                      tabs: [
                        const GButton(
                          icon: LineIcons.qrcode,
                          text: 'Szkennelés',
                        ),
                        const GButton(
                          icon: LineIcons.shoppingCart,
                          text: 'Bevásárló lista',
                        ),
                        const GButton(
                          icon: LineIcons.home,
                          text: 'Otthoni lista',
                        ),
                        const GButton(
                          icon: LineIcons.book,
                          text: 'Recept',
                        ),
                        _buildProfileButton(profileState),
                      ],
                      selectedIndex: _selectedIndex,
                      onTabChange: _onItemTapped,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  GButton _buildProfileButton(ProfileState profileState) {
    if (profileState is ProfileSelected) {
      return GButton(
        icon: Icons.person,
        text: 'Beállítások',
        leading: SizedBox(
          width: 24,
          height: 24,
          child: ProfileAvatar(
            profile: profileState.profile,
            size: 24,
          ),
        ),
      );
    } else {
      return const GButton(
        icon: LineIcons.userCircle,
        text: 'Beállítások',
      );
    }
  }

  Widget _buildCurrentScreen() {
    return BlocBuilder<SelectedCategoryBloc, SelectedCategoryState>(
      builder: (context, categoryState) {
        final bool hasSelectedCategory =
            categoryState is SelectedCategorySelected;
        final CategoryModel? selectedCategory =
            hasSelectedCategory ? (categoryState).category : null;

        if (_selectedIndex == 1) {
          if (hasSelectedCategory) {
            return CategoryDetailScreen(
              key: const ValueKey('shopping_category_detail'),
              category: selectedCategory!,
              listType: 1,
              showAppBar: false,
            );
          }
          return const ShoppingListScreen(
              key: ValueKey('shopping_list_screen'));
        }

        if (_selectedIndex == 2) {
          if (hasSelectedCategory) {
            return CategoryDetailScreen(
              key: const ValueKey('home_category_detail'),
              category: selectedCategory!,
              listType: 2,
              showAppBar: false,
            );
          }
          return const HomeListScreen(key: ValueKey('home_list_screen'));
        }

        switch (_selectedIndex) {
          case 0:
            return const ScanScreen(key: ValueKey('scan_screen'));
          case 3:
            if (_recipeBloc == null) {
              final bloc = RecipeBloc(
                listItemRepository: RepositoryProvider.of(context),
                recipeRepository: RepositoryProvider.of(context),
              );

              _recipeBloc = bloc;

              bloc.add(const LoadHomeInventory());

              return BlocProvider.value(
                value: bloc,
                child: const RecipeScreen(key: ValueKey('recipe_screen')),
              );
            } else {
              return BlocProvider.value(
                value: _recipeBloc!,
                child: const RecipeScreen(key: ValueKey('recipe_screen')),
              );
            }
          case 4:
            return const AccountSettingsScreen(
                key: ValueKey('account_settings_screen'));
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
