import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/repositories/list_item_repository.dart';
import 'package:coo_list/utils/product_processing_helper.dart';
import 'package:coo_list/logic/bin/bin_event.dart';
import 'package:coo_list/logic/bin/bin_state.dart';

class BinBloc extends Bloc<BinEvent, BinState> {
  final ListItemRepository listItemRepository;
  StreamSubscription? _binItemsSubscription;

  BinBloc({required this.listItemRepository}) : super(const BinInitial()) {
    on<LoadBinItems>(_onLoadBinItems);
    on<UpdateBinItemListType>(_onUpdateBinItemListType);
    on<BinItemsUpdated>(_onBinItemsUpdated);
  }

  Future<void> _onLoadBinItems(
    LoadBinItems event,
    Emitter<BinState> emit,
  ) async {
    emit(const BinLoading());

    try {
      await _binItemsSubscription?.cancel();

      _binItemsSubscription = listItemRepository.streamBinItems().listen(
        (items) => add(BinItemsUpdated(items)),
        onError: (error) {
          emit(BinError('Nem sikerült betölteni a kukát: $error'));
        },
      );
    } catch (e) {
      emit(BinError('Nem sikerült betölteni a kukát: $e'));
    }
  }

  void _onBinItemsUpdated(
    BinItemsUpdated event,
    Emitter<BinState> emit,
  ) {
    if (event.items.isEmpty) {
      emit(const BinLoaded([], <String, String>{}));
      return;
    }

    final products = ProductProcessingHelper.processItemsToProducts(
      event.items,
      listItemRepository,
    );

    final sortedProducts = ProductProcessingHelper.sortProductsByDate(
      products,
      ascending: false,
    );

    final productIds = ProductProcessingHelper.buildProductIdMapping(
      sortedProducts,
      event.items,
      listItemRepository,
    );

    emit(BinLoaded(sortedProducts, productIds));
  }

  Future<void> _onUpdateBinItemListType(
    UpdateBinItemListType event,
    Emitter<BinState> emit,
  ) async {
    try {
      await listItemRepository.updateItemListType(
        event.itemId,
        event.newListType,
        event.profileId,
      );
    } catch (e) {
      emit(BinError('Nem sikerült frissíteni a terméket: $e'));
    }
  }

  @override
  Future<void> close() {
    _binItemsSubscription?.cancel();
    return super.close();
  }
}
