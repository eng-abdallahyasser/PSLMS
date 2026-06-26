import 'package:flutter/material.dart';
import 'package:lms/app.dart';
import 'package:lms/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(App());
}
