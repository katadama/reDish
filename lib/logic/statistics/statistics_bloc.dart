import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/data/repositories/statistics_repository.dart';
import 'package:coo_list/logic/statistics/statistics_event.dart';
import 'package:equatable/equatable.dart';

part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StatisticsRepository _statisticsRepository;

  StatisticsBloc({required StatisticsRepository statisticsRepository})
      : _statisticsRepository = statisticsRepository,
        super(StatisticsInitial()) {
    on<FetchCategoryDistributionEvent>(_onFetchCategoryDistribution);
    on<FetchProfileDistributionEvent>(_onFetchProfileDistribution);
    on<FetchPriceDistributionEvent>(_onFetchPriceDistribution);
    on<FetchSpoilageStatisticsEvent>(_onFetchSpoilageStatistics);
  }

  Future<void> _onFetchCategoryDistribution(
    FetchCategoryDistributionEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());

    try {
      final categoryData =
          await _statisticsRepository.getItemCountByCategory(event.listType);
      emit(CategoryDistributionLoaded(
          categoryData: categoryData, listType: event.listType));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  Future<void> _onFetchProfileDistribution(
    FetchProfileDistributionEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());

    try {
      final profileData =
          await _statisticsRepository.getItemCountByProfile(event.listType);
      emit(ProfileDistributionLoaded(
          profileData: profileData, listType: event.listType));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  Future<void> _onFetchPriceDistribution(
    FetchPriceDistributionEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());

    try {
      final priceData =
          await _statisticsRepository.getPriceByCategory(event.listType);
      emit(PriceDistributionLoaded(
          priceData: priceData, listType: event.listType));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }

  Future<void> _onFetchSpoilageStatistics(
    FetchSpoilageStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());

    try {
      final spoilageData = await _statisticsRepository.getSpoilageStatistics();
      emit(SpoilageStatisticsLoaded(spoilageData: spoilageData));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }
}
