import 'package:equatable/equatable.dart';
import 'package:coo_list/data/models/list_item_model.dart';

abstract class BinEvent extends Equatable {
  const BinEvent();

  @override
  List<Object?> get props => [];
}

class LoadBinItems extends BinEvent {
  const LoadBinItems();
}

class UpdateBinItemListType extends BinEvent {
  final String itemId;
  final int newListType;
  final String profileId;

  const UpdateBinItemListType({
    required this.itemId,
    required this.newListType,
    required this.profileId,
  });

  @override
  List<Object?> get props => [itemId, newListType, profileId];
}

class BinItemsUpdated extends BinEvent {
  final List<ListItemModel> items;

  const BinItemsUpdated(this.items);

  @override
  List<Object?> get props => [items];
}
