import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/models/category_model.dart';
import 'package:coo_list/data/repositories/category_repository.dart';
import 'package:coo_list/logic/selected_category/selected_category_event.dart';
import 'package:coo_list/logic/selected_category/selected_category_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedCategoryBloc
    extends Bloc<SelectedCategoryEvent, SelectedCategoryState> {
  final CategoryRepository categoryRepository;

  static const String _prefKeySharedCategory = 'shared_category';
  static const String _prefKeyShoppingCategory = 'selected_shopping_category';
  static const String _prefKeyHomeCategory = 'selected_home_category';

  SelectedCategoryBloc({required this.categoryRepository})
      : super(const SelectedCategoryInitial()) {
    on<SelectCategory>(_onSelectCategory);
    on<ClearSelectedCategory>(_onClearSelectedCategory);
    on<LoadSelectedCategory>(_onLoadSelectedCategory);
  }

  Future<void> _onSelectCategory(
      SelectCategory event, Emitter<SelectedCategoryState> emit) async {
    emit(SelectedCategorySelected(
      category: event.category,
      listType: event.listType,
    ));

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_prefKeySharedCategory, event.category.id);
    await _saveListSpecificCategory(prefs, event.listType, event.category.id);
  }

  Future<void> _onClearSelectedCategory(
      ClearSelectedCategory event, Emitter<SelectedCategoryState> emit) async {
    emit(SelectedCategoryNone(listType: event.listType));

    final prefs = await SharedPreferences.getInstance();
    await _clearAllCategories(prefs);
  }

  Future<void> _onLoadSelectedCategory(
      LoadSelectedCategory event, Emitter<SelectedCategoryState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    final categoryId = _loadCategoryId(prefs, event.listType);

    if (categoryId == null) {
      emit(SelectedCategoryNone(listType: event.listType));
      return;
    }

    try {
      final category = await _loadCategoryById(categoryId);
      if (category != null) {
        emit(SelectedCategorySelected(
          category: category,
          listType: event.listType,
        ));
        await prefs.setString(_prefKeySharedCategory, categoryId);
      } else {
        await _clearInvalidCategory(prefs, event.listType);
        emit(SelectedCategoryNone(listType: event.listType));
      }
    } catch (e) {
      await _clearInvalidCategory(prefs, event.listType);
      emit(SelectedCategoryNone(listType: event.listType));
    }
  }

  String? _loadCategoryId(SharedPreferences prefs, int listType) {
    final sharedCategoryId = prefs.getString(_prefKeySharedCategory);
    if (sharedCategoryId != null) {
      return sharedCategoryId;
    }

    final listSpecificKey = _getListSpecificKey(listType);
    return prefs.getString(listSpecificKey);
  }

  Future<CategoryModel?> _loadCategoryById(String categoryId) async {
    try {
      return await categoryRepository.getCategoryById(categoryId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveListSpecificCategory(
      SharedPreferences prefs, int listType, String categoryId) async {
    final key = _getListSpecificKey(listType);
    await prefs.setString(key, categoryId);
  }

  Future<void> _clearAllCategories(SharedPreferences prefs) async {
    await prefs.remove(_prefKeySharedCategory);
    await prefs.remove(_prefKeyShoppingCategory);
    await prefs.remove(_prefKeyHomeCategory);
  }

  Future<void> _clearInvalidCategory(
      SharedPreferences prefs, int listType) async {
    await prefs.remove(_getListSpecificKey(listType));
    await prefs.remove(_prefKeySharedCategory);
  }

  String _getListSpecificKey(int listType) {
    return listType == 1 ? _prefKeyShoppingCategory : _prefKeyHomeCategory;
  }
}
