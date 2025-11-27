import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategoryDistributionEvent extends StatisticsEvent {
  final int listType;

  const FetchCategoryDistributionEvent({required this.listType});

  @override
  List<Object?> get props => [listType];
}

class FetchProfileDistributionEvent extends StatisticsEvent {
  final int listType;

  const FetchProfileDistributionEvent({required this.listType});

  @override
  List<Object?> get props => [listType];
}

class FetchPriceDistributionEvent extends StatisticsEvent {
  final int listType;

  const FetchPriceDistributionEvent({required this.listType});

  @override
  List<Object?> get props => [listType];
}

class FetchSpoilageStatisticsEvent extends StatisticsEvent {
  const FetchSpoilageStatisticsEvent();
}

