import 'package:coo_list/data/models/category_model.dart';
import 'package:equatable/equatable.dart';

abstract class SelectedCategoryState extends Equatable {
  const SelectedCategoryState();

  @override
  List<Object?> get props => [];
}

class SelectedCategoryInitial extends SelectedCategoryState {
  const SelectedCategoryInitial();
}

class SelectedCategorySelected extends SelectedCategoryState {
  final CategoryModel category;
  final int listType;

  const SelectedCategorySelected({
    required this.category,
    required this.listType,
  });

  @override
  List<Object?> get props => [category, listType];
}

class SelectedCategoryNone extends SelectedCategoryState {
  final int listType;

  const SelectedCategoryNone({
    required this.listType,
  });

  @override
  List<Object?> get props => [listType];
}



