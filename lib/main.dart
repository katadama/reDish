import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:coo_list/config/supabase_config.dart';
import 'package:coo_list/data/repositories/auth_repository.dart';
import 'package:coo_list/data/repositories/profile_repository.dart';
import 'package:coo_list/data/repositories/category_repository.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';
import 'package:coo_list/data/repositories/recipe_repository.dart';
import 'package:coo_list/logic/auth/auth_bloc.dart';
import 'package:coo_list/logic/profile/profile_bloc.dart';
import 'package:coo_list/logic/selected_category/selected_category_bloc.dart';
import 'package:coo_list/logic/bin/bin_bloc.dart';
import 'package:coo_list/config/app_router.dart';
import 'package:coo_list/logic/bloc_observer.dart';
import 'package:coo_list/services/openrouter_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await SupabaseConfig.initialize();

  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepository(),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(),
        ),
        RepositoryProvider<ListItemRepository>(
          create: (context) => ListItemRepository(),
        ),
        RepositoryProvider<OpenRouterService>(
          create: (context) => OpenRouterService(),
        ),
        RepositoryProvider<RecipeRepository>(
          create: (context) => RecipeRepository(
            openRouterService: context.read<OpenRouterService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              profileRepository: context.read<ProfileRepository>(),
            ),
          ),
          BlocProvider<SelectedCategoryBloc>(
            create: (context) => SelectedCategoryBloc(
              categoryRepository: context.read<CategoryRepository>(),
            ),
          ),
          BlocProvider<BinBloc>(
            create: (context) => BinBloc(
              listItemRepository: context.read<ListItemRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CooList',
          theme: ThemeData(
            primaryColor: const Color(0xFFF34744),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFF34744),
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
            ),
            scaffoldBackgroundColor: Colors.white,
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Color(0xFF424242),
              contentTextStyle: TextStyle(color: Colors.white),
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
              },
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Color(0xFFF34744),
              selectionHandleColor: Color(0xFFF34744),
              selectionColor: Color(0xFFCCCCCC),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color.fromARGB(255, 109, 109, 109), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFF34744), width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 1.0),
              ),
              floatingLabelStyle: TextStyle(color: Color(0xFFF34744)),
            ),
            segmentedButtonTheme: SegmentedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.white),
                foregroundColor:
                    WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFFF34744);
                  }
                  return Colors.black;
                }),
                side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.grey)),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            tabBarTheme: const TabBarThemeData(
              labelColor: Color(0xFFF34744),
              unselectedLabelColor: Colors.black,
              indicatorColor: Color(0xFFF34744),
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
            ),
          ),
          initialRoute: AppRouter.loading,
          onGenerateRoute: AppRouter.generateRoute,
          home: AppRouter.authRedirect(),
        ),
      ),
    );
  }
}
