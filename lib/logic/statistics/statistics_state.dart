part of 'statistics_bloc.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CategoryDistributionLoaded extends StatisticsState {
  final List<Map<String, dynamic>> categoryData;
  final int listType;

  const CategoryDistributionLoaded({
    required this.categoryData,
    required this.listType,
  });

  @override
  List<Object?> get props => [categoryData, listType];
}

class ProfileDistributionLoaded extends StatisticsState {
  final List<Map<String, dynamic>> profileData;
  final int listType;

  const ProfileDistributionLoaded({
    required this.profileData,
    required this.listType,
  });

  @override
  List<Object?> get props => [profileData, listType];
}

class PriceDistributionLoaded extends StatisticsState {
  final List<Map<String, dynamic>> priceData;
  final int listType;

  const PriceDistributionLoaded({
    required this.priceData,
    required this.listType,
  });

  @override
  List<Object?> get props => [priceData, listType];
}

class SpoilageStatisticsLoaded extends StatisticsState {
  final Map<String, int> spoilageData;

  const SpoilageStatisticsLoaded({
    required this.spoilageData,
  });

  @override
  List<Object?> get props => [spoilageData];
}
