import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/product_model.dart';

abstract class BinState extends Equatable {
  const BinState();

  @override
  List<Object?> get props => [];
}

class BinInitial extends BinState {
  const BinInitial();
}

class BinLoading extends BinState {
  const BinLoading();
}

class BinLoaded extends BinState {
  final List<ProductModel> products;
  final Map<String, String> productIds;

  const BinLoaded(this.products, this.productIds);

  @override
  List<Object?> get props => [products, productIds];
}

class BinError extends BinState {
  final String message;

  const BinError(this.message);

  @override
  List<Object?> get props => [message];
}
