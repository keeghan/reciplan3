import 'package:flutter/material.dart';

import 'package:reciplan3/presentation/features/settings/settings_screen.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'collection_screen.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                AppRoute.build(context, const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            tabs: const [
              Tab(text: 'Explore'),
              Tab(text: 'Collection'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExploreScreen(),
          CollectionScreen(),
          FavoriteScreen(),
        ],
      ),
    );
  }
}
