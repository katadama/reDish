import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/category_model.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class RefreshCategories extends CategoryEvent {
  const RefreshCategories();
}

class CategoriesUpdated extends CategoryEvent {
  final List<CategoryModel> categories;

  const CategoriesUpdated(this.categories);

  @override
  List<Object> get props => [categories];
}
