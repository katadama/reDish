import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/auth/auth_bloc.dart';
import 'package:coo_list/logic/auth/auth_state.dart';
import 'package:coo_list/data/repositories/profile_repository.dart';
import 'package:coo_list/presentation/screens/login_screen.dart';
import 'package:coo_list/presentation/screens/register_screen.dart';
import 'package:coo_list/presentation/screens/loading_screen.dart';
import 'package:coo_list/presentation/screens/profile_selection_screen.dart';
import 'package:coo_list/presentation/screens/profile_creation_screen.dart';
import 'package:coo_list/presentation/screens/main_navigation_screen.dart';
import 'package:coo_list/presentation/screens/scan_screen.dart';
import 'package:coo_list/presentation/screens/shopping_list_screen.dart';
import 'package:coo_list/presentation/screens/category_detail_screen.dart';
import 'package:coo_list/presentation/screens/home_list_screen.dart';
import 'package:coo_list/presentation/screens/recipe_screen.dart';
import 'package:coo_list/presentation/screens/account_settings_screen.dart';
import 'package:coo_list/presentation/screens/product_details_screen.dart';
import 'package:coo_list/presentation/screens/recipe_result_screen.dart';
import 'package:coo_list/presentation/screens/statistics_screen.dart';
import 'package:coo_list/presentation/screens/bin_screen.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coo_list/config/supabase_config.dart';
import 'dart:io';

class CategoryDetailArgs {
  final CategoryModel category;
  final int listType;

  CategoryDetailArgs({
    required this.category,
    this.listType = 1,
  });
}

class ProductDetailsArgs {
  final ProductModel product;
  final File? image;
  final String? productId;
  final int initialListType;

  ProductDetailsArgs({
    required this.product,
    this.image,
    this.productId,
    this.initialListType = 1,
  });
}

class LoginArgs {
  final String? prefilledEmail;

  LoginArgs({this.prefilledEmail});
}

class RecipeResultArgs {
  final dynamic recipe;

  RecipeResultArgs({required this.recipe});
}

class AppRouter {
  static const String loading = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profileSelection = '/profile-selection';
  static const String profileCreation = '/profile-creation';
  static const String scan = '/scan';
  static const String shoppingList = '/shopping-list';
  static const String categoryDetail = '/category-detail';
  static const String productDetails = '/product-details';
  static const String homeList = '/home-list';
  static const String recipe = '/recipe';
  static const String accountSettings = '/account-settings';
  static const String recipeResult = '/recipe-result';
  static const String statistics = '/statistics';
  static const String bin = '/bin';
  static const String lastSelectedProfileKey = 'last_selected_profile_id';

  static Route<dynamic> _errorRoute(String message) {
    return _buildRoute(
      Scaffold(
        body: Center(child: Text(message)),
      ),
    );
  }

  static Route<dynamic> _buildRoute(Widget page, {bool useSlide = false}) {
    if (useSlide) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
    }

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.easeInOut;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final opacityAnimation = animation.drive(tween);
        return FadeTransition(opacity: opacityAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case login:
        if (args is LoginArgs) {
          return _buildRoute(LoginScreen(prefilledEmail: args.prefilledEmail));
        } else if (args is Map<String, dynamic>) {
          final prefilledEmail = args['prefilledEmail'] as String?;
          return _buildRoute(LoginScreen(prefilledEmail: prefilledEmail));
        }
        return _buildRoute(const LoginScreen());

      case register:
        return _buildRoute(const RegisterScreen(), useSlide: true);

      case main:
        return _buildRoute(const MainNavigationScreen());

      case profileSelection:
        return _buildRoute(const ProfileSelectionScreen());

      case profileCreation:
        return _buildRoute(const ProfileCreationScreen(), useSlide: true);

      case scan:
        return _buildRoute(const ScanScreen());

      case shoppingList:
        return _buildRoute(const ShoppingListScreen());

      case categoryDetail:
        if (args is CategoryDetailArgs) {
          return _buildRoute(
            CategoryDetailScreen(
              category: args.category,
              listType: args.listType,
            ),
            useSlide: true,
          );
        } else if (args is Map<String, dynamic>) {
          final category = args['category'] as CategoryModel?;
          final listType = args['listType'] as int? ?? 1;
          if (category != null) {
            return _buildRoute(
              CategoryDetailScreen(category: category, listType: listType),
              useSlide: true,
            );
          }
        }
        return _errorRoute('Kategória nem található');

      case productDetails:
        if (args is ProductDetailsArgs) {
          return _buildRoute(
            ProductDetailsScreen(
              product: args.product,
              image: args.image,
              productId: args.productId,
              initialListType: args.initialListType,
            ),
            useSlide: true,
          );
        } else if (args is Map<String, dynamic> &&
            args.containsKey('product')) {
          final product = args['product'] as ProductModel?;
          if (product != null) {
            return _buildRoute(
              ProductDetailsScreen(
                product: product,
                image: args['image'] as File?,
                productId: args['productId'] as String?,
                initialListType: args['initialListType'] as int? ?? 1,
              ),
              useSlide: true,
            );
          }
        }
        return _errorRoute('Termék nem található');

      case homeList:
        return _buildRoute(const HomeListScreen());

      case recipe:
        return _buildRoute(const RecipeScreen());

      case recipeResult:
        if (args is RecipeResultArgs) {
          return _buildRoute(
            RecipeResultScreen(recipe: args.recipe),
            useSlide: true,
          );
        } else if (args is Map<String, dynamic> && args.containsKey('recipe')) {
          return _buildRoute(
            RecipeResultScreen(recipe: args['recipe']),
            useSlide: true,
          );
        }
        return _errorRoute('Recept nem található');

      case accountSettings:
        return _buildRoute(const AccountSettingsScreen());

      case statistics:
        return _buildRoute(const StatisticsScreen());

      case bin:
        return _buildRoute(const BinScreen());

      default:
        return _errorRoute('Az oldal nem található');
    }
  }

  static Widget authRedirect() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return _buildAuthenticatedScreen(context);
        } else if (state is Unauthenticated || state is AuthError) {
          return const LoginScreen();
        } else if (state is AuthInitial) {
          return const LoadingScreen();
        }
        return const LoginScreen();
      },
    );
  }

  static Widget _buildAuthenticatedScreen(BuildContext context) {
    final profileRepository = context.read<ProfileRepository>();

    return FutureBuilder<Widget>(
      future: _getAuthenticatedDestination(profileRepository),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        return snapshot.data ?? const LoadingScreen();
      },
    );
  }

  static Future<Widget> _getAuthenticatedDestination(
      ProfileRepository repository) async {
    final hasProfiles = await _checkProfilesAndLastSelected(repository);

    if (!hasProfiles) {
      return const ProfileCreationScreen();
    }

    final lastProfileId = await _getLastSelectedProfileId();
    if (lastProfileId != null) {
      return const MainNavigationScreen();
    }

    return const ProfileSelectionScreen();
  }

  static Future<bool> _checkProfilesAndLastSelected(
      ProfileRepository repository) async {
    final supabase = SupabaseConfig.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final response = await supabase
          .from('profiles')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return await repository.hasProfiles();
    }
  }

  static Future<String?> _getLastSelectedProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastSelectedProfileKey);
  }
}
