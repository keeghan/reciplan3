import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/presentation/widgets/network_image_with_placeholder.dart';
import 'package:reciplan3/util/utils.dart';

class DirectionsScreen extends StatelessWidget {
  final Recipe recipe;

  const DirectionsScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: ReciplanCustomColors.appBarColor,
            foregroundColor: Colors.white,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
                final deltaExtent = settings.maxExtent - settings.minExtent;
                final t = (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
                    .clamp(0.0, 1.0);

                return FlexibleSpaceBar(
                  centerTitle: false,
                  expandedTitleScale: 1.5,
                  titlePadding: EdgeInsets.lerp(
                    const EdgeInsets.only(left: 16, bottom: 16),
                    const EdgeInsets.only(left: 72, bottom: 16),
                    t,
                  ),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ReciplanImage(
                        imageUrl: recipe.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                          heroTag: 'youtube',
                          onPressed: () {
                            launchUrl(
                              Uri.parse(recipe.videoLink),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Center(
                  child: Text(
                    'Ingredients',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    recipe.ingredients,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Recipe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    recipe.direction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
