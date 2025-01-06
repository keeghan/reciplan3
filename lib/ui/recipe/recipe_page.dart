import 'package:flutter/material.dart';

import '../../util/utils.dart';
import '../settings_screen.dart';
import 'collection_screen.dart';
import 'explore_screen.dart';
import 'favorite_screen.dart';

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
            icon: Icon(Icons.settings),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
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
