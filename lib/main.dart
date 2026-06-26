import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lms/app.dart';
import 'package:lms/firebase_options.dart';
import 'package:lms/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  await initDependencies();
  runApp(App());
}
