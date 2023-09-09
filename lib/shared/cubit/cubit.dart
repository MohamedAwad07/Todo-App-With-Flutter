import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/Archived_Tasks.dart';
import 'package:todo_app/modules/done_tasks/Done_Tasks.dart';
import 'package:todo_app/modules/new_tasks/New_Tasks.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  static AppCubit get(context) => BlocProvider.of(context);

  //variables
  bool isBottomSheet = false;
  IconData iconFloating = Icons.edit;
  List<Map> taskView = [];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  late Database database;

  int currentIndex = 0;
  List<Widget> currentScreen = [
    const NewTasks(),
    const DoneTasks(),
    const ArchivedTasks(),
  ];
  List<String> appTitle = [
    'New Task',
    'Done Tasks',
    'Archived Tasks',
  ];

  // methods
  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeNavBarState());
  }

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        debugPrint('Database created');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT , status TEXT)')
            .then((value) {
          debugPrint('table created');
        }).catchError((error) {
          debugPrint('Error is ${error.toString}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        debugPrint('Database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabase());
    });
  }

  insertIntoDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks (title , date , time , status) VALUES ("$title" , "$date" ,"$time" , "New" )')
          .then((value) {
        debugPrint('$value inserted successfully');
        getDataFromDatabase(database);
        emit(AppInsertDatabase());
      }).catchError((error) {
        debugPrint('Error when inserted is ${error.toString()}');
      });
      return Future.value(42);
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'New') {
          newTasks.add(element);
        } else if (element['status'] == 'Done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });
      print(newTasks);
      print(doneTasks);
      print(archivedTasks);
      emit(AppGetDatabase());
    });
  }

  void changeButtonSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheet = isShow;
    iconFloating = icon;
    emit(AppChangeButtonState());
  }

  void updateData({
    required String status,
    required int id,
  }) {
    database.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [status, id],
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabase());
    });
  }

  void deleteData({
    required int id,
  }) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabase());
    });
  }
}
