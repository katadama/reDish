import 'package:flutter/material.dart';

class RecipeTabsView extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;

  const RecipeTabsView({
    super.key,
    required this.tabs,
    required this.children,
  }) : assert(tabs.length == children.length,
            'A fülek és a gyermekek hosszának meg kell egyeznie');

  @override
  State<RecipeTabsView> createState() => _RecipeTabsViewState();
}

class _RecipeTabsViewState extends State<RecipeTabsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            tabs: widget.tabs
                .map((title) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ))
                .toList(),
            labelColor: const Color(0xFFF34744),
            unselectedLabelColor: const Color(0xFF4A545A),
            indicatorColor: const Color(0xFFF34744),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
