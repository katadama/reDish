import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:coo_list/data/repositories/category_repository.dart';
import 'package:coo_list/logic/category/category_bloc.dart';
import 'package:coo_list/logic/category/category_event.dart';
import 'package:coo_list/logic/category/category_state.dart';
import 'package:coo_list/presentation/widgets/category/category_card.dart';
import 'package:coo_list/utils/style_utils.dart';

class CategoryGridConfig {
  final int listType;
  final String emptyStateMessage;
  final String initialStateMessage;

  const CategoryGridConfig({
    required this.listType,
    required this.emptyStateMessage,
    required this.initialStateMessage,
  });
}

class CategoryGridScreen extends StatefulWidget {
  final CategoryGridConfig config;

  const CategoryGridScreen({
    super.key,
    required this.config,
  });

  @override
  State<CategoryGridScreen> createState() => _CategoryGridScreenState();
}

class _CategoryGridScreenState extends State<CategoryGridScreen> {
  late CategoryBloc _categoryBloc;

  @override
  void initState() {
    super.initState();
    _categoryBloc = CategoryBloc(
      categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
      listType: widget.config.listType,
    )..add(const LoadCategories());
  }

  @override
  void dispose() {
    _categoryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _categoryBloc,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _CategoryGridView(config: widget.config),
          ),
        ),
      ),
    );
  }
}

class _CategoryGridView extends StatelessWidget {
  final CategoryGridConfig config;

  const _CategoryGridView({required this.config});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF34744),
            ),
          );
        }

        if (state is CategoryError) {
          return Center(
            child: Text(
              'Hiba: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is CategoryLoaded) {
          return _buildCategoryGrid(context, state.categories);
        }

        return Center(
          child: Text(config.initialStateMessage),
        );
      },
    );
  }

  Widget _buildCategoryGrid(
      BuildContext context, List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(config.emptyStateMessage),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.035,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: StyleUtils.cardSpacing,
        mainAxisSpacing: StyleUtils.cardSpacing,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          listType: config.listType,
        );
      },
    );
  }
}
