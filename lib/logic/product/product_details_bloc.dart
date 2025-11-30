import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/utils/list_type_constants.dart';
import 'package:coo_list/data/models/product_model.dart';
import 'package:coo_list/data/repositories/category_repository.dart';
import 'package:coo_list/logic/product/product_details_event.dart';
import 'package:coo_list/logic/product/product_details_state.dart';
import 'package:coo_list/config/supabase_config.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final CategoryRepository categoryRepository;
  final List<String> _categories = [];
  final String? _productId;

  ProductDetailsBloc({
    required ProductModel product,
    required this.categoryRepository,
    String? productId,
    int initialListType = ListType.shopping,
  })  : _productId = productId,
        super(ProductDetailsInitial(
          product: product,
          selectedListType: initialListType,
        )) {
    on<ToggleListTypeEvent>(_onToggleListType);
    on<StartEditingEvent>(_onStartEditing);
    on<CancelEditingEvent>(_onCancelEditing);
    on<UnfocusFieldEvent>(_onUnfocusField);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<SaveProductEvent>(_onSaveProduct);
    on<ReloadCategoriesEvent>(_onReloadCategories);
    on<LoadCategoriesEvent>(_onLoadCategories);

    add(const LoadCategoriesEvent());
  }

  List<String> get categories => _categories;

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    try {
      final categoryNames = await categoryRepository.getCategoryNames();

      _categories.clear();
      _categories.addAll(categoryNames);

      if (state is ProductDetailsInitial) {
        final currentState = state as ProductDetailsInitial;
        emit(currentState.copyWith());
      }
    } catch (e) {
      // Error loading categories - categories list remains empty
      // State is not updated to avoid disrupting the UI
    }
  }

  Future<void> _onReloadCategories(
    ReloadCategoriesEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    await _onLoadCategories(const LoadCategoriesEvent(), emit);
  }

  void _onToggleListType(
    ToggleListTypeEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsInitial) {
      final currentState = state as ProductDetailsInitial;
      emit(currentState.copyWith(
        selectedListType: currentState.selectedListType == ListType.shopping
            ? ListType.home
            : ListType.shopping,
      ));
    }
  }

  void _onStartEditing(
    StartEditingEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsInitial) {
      final currentState = state as ProductDetailsInitial;
      emit(currentState.copyWith(
        editingField: event.fieldName,
      ));
    }
  }

  void _onCancelEditing(
    CancelEditingEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsInitial) {
      final currentState = state as ProductDetailsInitial;
      emit(currentState.copyWith(
        clearEditingField: true,
      ));
    }
  }

  void _onUnfocusField(
    UnfocusFieldEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsInitial) {
      final currentState = state as ProductDetailsInitial;
      emit(currentState.copyWith(
        clearEditingField: true,
      ));
    }
  }

  void _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsInitial) {
      final currentState = state as ProductDetailsInitial;
      emit(currentState.copyWith(
        product: event.updatedProduct,
        editingField: currentState.editingField,
      ));
    }
  }

  Future<void> _onSaveProduct(
    SaveProductEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is! ProductDetailsInitial) return;

    final currentState = state as ProductDetailsInitial;
    final product = currentState.product;
    final listType = currentState.selectedListType;

    emit(const ProductDetailsSaving());

    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) {
        emit(const ProductDetailsSaveError('User not authenticated'));
        return;
      }

      final category =
          await categoryRepository.getCategoryByName(product.category);
      if (category == null) {
        emit(const ProductDetailsSaveError('Category not found'));
        return;
      }
      final categoryId = category.id;

      final listItemData = product.toListItemJson(
        userId: user.id,
        profileId: event.profileId,
        listType: listType,
        categoryId: categoryId,
      );

      if (_productId != null) {
        await SupabaseConfig.client
            .from('list_items')
            .update(listItemData)
            .eq('id', _productId);
      } else {
        await SupabaseConfig.client.from('list_items').insert(listItemData);
      }

      emit(ProductDetailsSaveSuccess(listType: listType));
    } catch (e) {
      emit(ProductDetailsSaveError('Nem sikerült menteni a terméket: $e'));
    }
  }
}
