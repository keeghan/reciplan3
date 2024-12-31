import 'package:flutter/material.dart';
import 'package:reciplan3/ui/plan/manage_day_screen.dart';
import 'package:reciplan3/ui/widgets/plan_day_item.dart';

import '../../main.dart';
import '../../plan_viewmodel.dart';
import '../../util/util.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late PlanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<PlanViewModel>();
    _viewModel.loadWeekRecipes();
    _viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _viewModel.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }

  Future<void> clearPlans() async {
    await _viewModel.clearPlans();
    if (_viewModel.error == null) {
      showSnackBar(context, "Plans Cleared");
    } else {
      showSnackBar(context, _viewModel.error!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        onFocusChange: (hasFocus) {
          _viewModel.loadWeekRecipes();
        },
        //TODO: fix AppBar
        child: Scaffold(
          // appBar: AppBar(
          //   actions: [
          //     IconButton(
          //         onPressed: () {
          //           showDeleteConfirmationDialog(
          //             context,
          //             "Confirm Action",
          //             "Are you sure you want to clear plans for the Week?",
          //             clearPlans,
          //           );
          //         },
          //         icon: Icon(Icons.delete))
          //   ],
          // ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _viewModel.weekRecipes.length,
                  itemBuilder: (context, index) {
                    final dayId = _viewModel.weekRecipes.keys.elementAt(index);
                    final recipes = _viewModel.weekRecipes[dayId];
                    if (recipes == null) {
                      return Center(child: Text('${_viewModel.error}'));
                    }
                    return PlanDayItem(
                      dayId: dayId,
                      dayRecipes: recipes,
                      onEditDayPlanPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageDayScreen(dayId: dayId),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              //Test Reload
              TextButton(
                onPressed: () => _viewModel.loadWeekRecipes(),
                child: Text("Reload"),
              )
            ],
          ),
        ));
  }
}
