import 'package:flutter/material.dart';

import 'package:reciplan3/logic/app/app.dart';
import 'package:reciplan3/logic/app/bootstrap/app_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.bootstrap();
  runApp(MyApp(dependencies: dependencies));
}
