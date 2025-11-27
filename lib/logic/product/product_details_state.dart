import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/product_model.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {
  final ProductModel product;
  final String? editingField;
  final int selectedListType;

  const ProductDetailsInitial({
    required this.product,
    this.editingField,
    required this.selectedListType,
  });

  @override
  List<Object?> get props => [product, editingField, selectedListType];

  ProductDetailsInitial copyWith({
    ProductModel? product,
    String? editingField,
    int? selectedListType,
    bool clearEditingField = false,
  }) {
    return ProductDetailsInitial(
      product: product ?? this.product,
      editingField:
          clearEditingField ? null : (editingField ?? this.editingField),
      selectedListType: selectedListType ?? this.selectedListType,
    );
  }
}

class ProductDetailsSaving extends ProductDetailsState {
  const ProductDetailsSaving();
}

class ProductDetailsSaveSuccess extends ProductDetailsState {
  final bool needsRefresh;
  final int listType;

  const ProductDetailsSaveSuccess({
    this.needsRefresh = true,
    this.listType = 0,
  });

  @override
  List<Object?> get props => [needsRefresh, listType];
}

class ProductDetailsSaveError extends ProductDetailsState {
  final String message;

  const ProductDetailsSaveError(this.message);

  @override
  List<Object?> get props => [message];
}
