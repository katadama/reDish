import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/data/repositories/category_repository.dart';
import 'package:coo_list/logic/category/category_event.dart';
import 'package:coo_list/logic/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;
  final int listType;
  StreamSubscription? _categoriesSubscription;

  CategoryBloc({
    required this.categoryRepository,
    required this.listType,
  }) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<RefreshCategories>(_onLoadCategories);
    on<CategoriesUpdated>(_onCategoriesUpdated);
  }

  Future<void> _onLoadCategories(
    CategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());

    try {
      await _categoriesSubscription?.cancel();

      final stream = listType == ListType.shopping
          ? categoryRepository.streamCategoriesWithShoppingCounts()
          : categoryRepository.streamCategoriesWithHomeCounts();

      _categoriesSubscription = stream.listen(
        (categories) => add(CategoriesUpdated(categories)),
        onError: (error) {
          emit(CategoryError('Nem sikerült betölteni a kategóriákat: $error'));
        },
      );
    } catch (e) {
      emit(CategoryError('Nem sikerült betölteni a kategóriákat: $e'));
    }
  }

  void _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoryState> emit,
  ) {
    emit(CategoryLoaded(event.categories));
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
