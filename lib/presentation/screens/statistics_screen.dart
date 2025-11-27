import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coo_list/logic/statistics/statistics_bloc.dart';
import 'package:coo_list/logic/statistics/statistics_event.dart';
import 'package:coo_list/data/repositories/statistics_repository.dart';
import 'package:coo_list/utils/profile_colors.dart';
import 'package:coo_list/presentation/widgets/statistics/statistics_pie_chart.dart';
import 'package:coo_list/presentation/widgets/statistics/statistics_empty_state.dart';
import 'package:coo_list/presentation/widgets/statistics/statistics_legend.dart';

class StatisticsScreen extends StatefulWidget {
  static const String routeName = '/statistics';

  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'Otthoni lista',
    'Bevásárló lista',
    'Kuka',
    'Lejárat'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatisticsBloc(
        statisticsRepository: StatisticsRepository(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statisztikák'),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _StatisticsTabContent(listType: 2),
            _StatisticsTabContent(listType: 1),
            _StatisticsTabContent(listType: 3),
            _SpoilageTabContent(),
          ],
        ),
      ),
    );
  }
}

class _SpoilageTabContent extends StatefulWidget {
  const _SpoilageTabContent();

  @override
  State<_SpoilageTabContent> createState() => _SpoilageTabContentState();
}

class _SpoilageTabContentState extends State<_SpoilageTabContent> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<StatisticsBloc>().add(const FetchSpoilageStatisticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StatisticsBloc, StatisticsState>(
      listener: (context, state) {
        if (state is StatisticsError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF424242),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF34744),
            ),
          );
        } else if (state is SpoilageStatisticsLoaded) {
          return _buildSpoilageChart(state.spoilageData);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF34744),
            ),
          );
        }
      },
    );
  }

  Widget _buildSpoilageChart(Map<String, int> spoilageData) {
    final totalItems = spoilageData.values.fold(0, (sum, count) => sum + count);

    if (totalItems == 0) {
      return const StatisticsEmptyState(
        message: 'Nem található lejárati adattal rendelkező termék',
        icon: Icons.inventory_2_outlined,
      );
    }

    final sections = [
      PieChartSection(
        label: 'Ma',
        color: Colors.red,
        value: (spoilageData['spoil_today'] ?? 0).toDouble(),
        count: spoilageData['spoil_today'] ?? 0,
      ),
      PieChartSection(
        label: 'Holnap',
        color: Colors.orange,
        value: (spoilageData['spoil_tomorrow'] ?? 0).toDouble(),
        count: spoilageData['spoil_tomorrow'] ?? 0,
      ),
      PieChartSection(
        label: 'Ezen a héten',
        color: Colors.yellow,
        value: (spoilageData['spoil_this_week'] ?? 0).toDouble(),
        count: spoilageData['spoil_this_week'] ?? 0,
      ),
      PieChartSection(
        label: 'Később',
        color: Colors.green,
        value: (spoilageData['spoil_later'] ?? 0).toDouble(),
        count: spoilageData['spoil_later'] ?? 0,
      ),
    ];

    final legendItems = sections
        .map((section) => LegendItem(
              title: section.label,
              color: section.color,
              count: section.count,
            ))
        .toList();

    return StatisticsPieChart(
      sections: sections,
      legendItems: legendItems,
    );
  }
}

class _StatisticsTabContent extends StatefulWidget {
  final int listType;

  const _StatisticsTabContent({required this.listType});

  @override
  State<_StatisticsTabContent> createState() => _StatisticsTabContentState();
}

class _StatisticsTabContentState extends State<_StatisticsTabContent> {
  String _selectedChart = 'Category';
  String? _lastSelectedChart;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lastSelectedChart == null) {
      _loadChartData(_selectedChart);
      _lastSelectedChart = _selectedChart;
    }
  }

  void _loadChartData(String chartType) {
    final bloc = context.read<StatisticsBloc>();
    switch (chartType) {
      case 'Category':
        bloc.add(FetchCategoryDistributionEvent(listType: widget.listType));
        break;
      case 'Profile':
        bloc.add(FetchProfileDistributionEvent(listType: widget.listType));
        break;
      case 'Price':
        bloc.add(FetchPriceDistributionEvent(listType: widget.listType));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'Category',
                label: Text('Kategória szerint'),
                icon: Icon(Icons.category),
              ),
              ButtonSegment<String>(
                value: 'Profile',
                label: Text('Profil szerint'),
                icon: Icon(Icons.person),
              ),
              ButtonSegment<String>(
                value: 'Price',
                label: Text('Ár szerint'),
                icon: Icon(Icons.attach_money),
              ),
            ],
            selected: {_selectedChart},
            onSelectionChanged: (Set<String> selection) {
              final newSelection = selection.first;
              if (newSelection != _lastSelectedChart) {
                setState(() {
                  _selectedChart = newSelection;
                  _lastSelectedChart = newSelection;
                });
                _loadChartData(newSelection);
              }
            },
          ),
        ),
        Expanded(
          child: _buildSelectedChart(),
        ),
      ],
    );
  }

  Widget _buildSelectedChart() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF34744),
            ),
          );
        }

        switch (_selectedChart) {
          case 'Category':
            if (state is CategoryDistributionLoaded &&
                state.listType == widget.listType) {
              return _buildCategoryChart(state.categoryData);
            }
            break;
          case 'Profile':
            if (state is ProfileDistributionLoaded &&
                state.listType == widget.listType) {
              return _buildProfileChart(state.profileData);
            }
            break;
          case 'Price':
            if (state is PriceDistributionLoaded &&
                state.listType == widget.listType) {
              return _buildPriceChart(state.priceData);
            }
            break;
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCategoryChart(List<Map<String, dynamic>> categoryData) {
    if (categoryData.isEmpty) {
      return const StatisticsEmptyState(
        message: 'Nincs elérhető adat',
        icon: Icons.category_outlined,
      );
    }

    final chartData = _processTopItems(
      categoryData,
      5,
      (item) => item['count'] as int,
      (item, otherCount) => {
        'id': 'other',
        'name': 'Egyéb',
        'count': otherCount,
      },
    );

    final colors = _getChartColors();
    final sections = <PieChartSection>[];
    final legendItems = <LegendItem>[];

    for (int i = 0; i < chartData.length; i++) {
      final data = chartData[i];
      final color = colors[i % colors.length];
      final count = data['count'] as int;
      final name = data['name'] as String;

      sections.add(PieChartSection(
        label: name,
        color: color,
        value: count.toDouble(),
        count: count,
      ));
      legendItems.add(LegendItem(
        title: name,
        color: color,
        count: count,
      ));
    }

    return StatisticsPieChart(
      sections: sections,
      legendItems: legendItems,
    );
  }

  Widget _buildProfileChart(List<Map<String, dynamic>> profileData) {
    if (profileData.isEmpty) {
      return const StatisticsEmptyState(
        message: 'Nincs elérhető adat',
        icon: Icons.person_outline,
      );
    }

    final sections = <PieChartSection>[];
    final legendItems = <LegendItem>[];

    for (final data in profileData) {
      final count = data['count'] as int;
      final name = data['name'] as String;
      final colorIndex = data['color'] as int;
      final color = ProfileColors.getColorByIndex(colorIndex);

      sections.add(PieChartSection(
        label: name,
        color: color,
        value: count.toDouble(),
        count: count,
      ));
      legendItems.add(LegendItem(
        title: name,
        color: color,
        count: count,
      ));
    }

    return StatisticsPieChart(
      sections: sections,
      legendItems: legendItems,
    );
  }

  Widget _buildPriceChart(List<Map<String, dynamic>> priceData) {
    if (priceData.isEmpty) {
      return const StatisticsEmptyState(
        message: 'Nincs elérhető adat',
        icon: Icons.attach_money_outlined,
      );
    }

    final chartData = _processTopItems(
      priceData,
      5,
      (item) => (item['totalPrice'] as num).toDouble(),
      (item, otherPrice) => {
        'id': 'other',
        'name': 'Egyéb',
        'totalPrice': otherPrice,
      },
    );

    final colors = _getChartColors();
    final sections = <PieChartSection>[];
    final legendItems = <LegendItem>[];

    for (int i = 0; i < chartData.length; i++) {
      final data = chartData[i];
      final color = colors[i % colors.length];
      final price = (data['totalPrice'] as num).toDouble();
      final name = data['name'] as String;

      sections.add(PieChartSection(
        label: name,
        color: color,
        value: price,
        count: price.toInt(),
      ));
      legendItems.add(LegendItem(
        title: name,
        color: color,
        count: price.toInt(),
        unit: 'Ft',
      ));
    }

    return StatisticsPieChart(
      sections: sections,
      legendItems: legendItems,
    );
  }

  List<Map<String, dynamic>> _processTopItems<T extends num>(
    List<Map<String, dynamic>> data,
    int topCount,
    T Function(Map<String, dynamic>) getValue,
    Map<String, dynamic> Function(Map<String, dynamic>, T) createOtherItem,
  ) {
    if (data.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> chartData = [];
    final firstValue = getValue(data[0]);
    num otherValue = firstValue is double ? 0.0 : 0;

    for (int i = 0; i < data.length; i++) {
      if (i < topCount) {
        chartData.add(data[i]);
      } else {
        final value = getValue(data[i]);
        otherValue = otherValue + value;
      }
    }

    if (otherValue > 0) {
      final T typedOtherValue = (firstValue is double
          ? otherValue.toDouble()
          : otherValue.toInt()) as T;
      chartData.add(createOtherItem(data[0], typedOtherValue));
    }

    return chartData;
  }

  List<Color> _getChartColors() {
    return [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.grey,
    ];
  }
}
