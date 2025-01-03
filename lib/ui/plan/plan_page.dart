import 'package:flutter/material.dart';

import '../../main.dart';
import '../../plan_viewmodel.dart';
import '../widgets/plan_day_item.dart';
import 'manage_day_screen.dart';

class PlanPage extends StatefulWidget {
   const PlanPage({super.key});

  @override
  State<StatefulWidget> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> with WidgetsBindingObserver {
  late PlanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<PlanViewModel>();
    WidgetsBinding.instance.addObserver(this);
  }

  //Refresh WeekPlans whenever page comes into focus
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _viewModel.loadWeekRecipes();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                if (_viewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_viewModel.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _viewModel.loadWeekRecipes(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_viewModel.isLoading && _viewModel.weekRecipes.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: _viewModel.weekRecipes.length,
                  itemBuilder: (context, index) {
                    final dayId = _viewModel.weekRecipes.keys.elementAt(index);
                    final recipes = _viewModel.weekRecipes[dayId];

                    if (recipes == null) {
                      return const SizedBox.shrink();
                    }

                    return PlanDayItem(
                      dayId: dayId,
                      dayRecipes: recipes,
                      onEditDayPlanPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ManageDayScreen(dayId: dayId)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          TextButton(
            onPressed: () => _viewModel.loadWeekRecipes(),
            child: const Text("Reload"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
