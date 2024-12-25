import 'package:flutter/material.dart';

import 'recipe/collection_screen.dart';
import 'recipe/explore_screen.dart';
import 'recipe/favorite_screen.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> with TickerProviderStateMixin {
  late TabController _tabController;

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
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
        children: const [ExploreScreen(), CollectionScreen(), FavoriteScreen()],
      ),
    );
  }
}
