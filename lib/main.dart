import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/layout/todoLayout.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_app/shared/observer.dart';

Future main() async {
// Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
