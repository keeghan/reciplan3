import 'package:flutter/material.dart';

import '../../main.dart';
import '../../plan_viewmodel.dart';

class ManageDayScreen extends StatefulWidget {
  final int dayId;

  const ManageDayScreen({super.key, required this.dayId});

  @override
  State<ManageDayScreen> createState() => _ManageDayScreenState();
}

class _ManageDayScreenState extends State<ManageDayScreen> {
  late PlanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<PlanViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Manage Day ${widget.dayId}'),
      ),
    );
  }
}
