import 'package:flutter/material.dart';

import 'package:reciplan3/util/utils.dart';
import 'package:reciplan3/presentation/features/settings/settings_screen.dart';
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
        backgroundColor: ReciplanCustomColors.appBarColor,
        foregroundColor: Colors.white,
        title: const Text('Reciplan'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Explore'),
              Tab(text: 'Collection'),
              Tab(text: 'Favorite'),
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
