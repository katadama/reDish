import 'package:coo_list/data/models/category_model.dart';
import 'package:equatable/equatable.dart';

abstract class SelectedCategoryEvent extends Equatable {
  const SelectedCategoryEvent();

  @override
  List<Object?> get props => [];
}

class SelectCategory extends SelectedCategoryEvent {
  final CategoryModel category;
  final int listType;

  const SelectCategory({
    required this.category,
    required this.listType,
  });

  @override
  List<Object?> get props => [category, listType];
}

class ClearSelectedCategory extends SelectedCategoryEvent {
  final int listType;

  const ClearSelectedCategory({
    required this.listType,
  });

  @override
  List<Object?> get props => [listType];
}

class LoadSelectedCategory extends SelectedCategoryEvent {
  final int listType;

  const LoadSelectedCategory({
    required this.listType,
  });

  @override
  List<Object?> get props => [listType];
}
