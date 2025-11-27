import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/product_model.dart';

abstract class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ToggleListTypeEvent extends ProductDetailsEvent {
  const ToggleListTypeEvent();
}

class StartEditingEvent extends ProductDetailsEvent {
  final String fieldName;

  const StartEditingEvent(this.fieldName);

  @override
  List<Object?> get props => [fieldName];
}

class CancelEditingEvent extends ProductDetailsEvent {
  const CancelEditingEvent();
}

class UnfocusFieldEvent extends ProductDetailsEvent {
  const UnfocusFieldEvent();
}

class UpdateProductEvent extends ProductDetailsEvent {
  final ProductModel updatedProduct;

  const UpdateProductEvent(this.updatedProduct);

  @override
  List<Object?> get props => [updatedProduct];
}

class SaveProductEvent extends ProductDetailsEvent {
  final String profileId;

  const SaveProductEvent(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

class ReloadCategoriesEvent extends ProductDetailsEvent {
  const ReloadCategoriesEvent();
}

class LoadCategoriesEvent extends ProductDetailsEvent {
  const LoadCategoriesEvent();
}

