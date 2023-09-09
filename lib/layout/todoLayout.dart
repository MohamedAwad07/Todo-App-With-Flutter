import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

// variables to be used

var scaffoldKey = GlobalKey<ScaffoldState>();
var formKey = GlobalKey<FormState>();

var titleController = TextEditingController();
var timeController = TextEditingController();
var dateController = TextEditingController();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabase) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.appTitle[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: true,
              builder: (context) => cubit.currentScreen[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Add Task',
              onPressed: () {
                if (cubit.isBottomSheet) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertIntoDatabase(
                        title: titleController.text,
                        date: dateController.text,
                        time: timeController.text);

                    // insertIntoDatabase(
                    //   title: titleController.text,
                    //   date: dateController.text,
                    //   time: timeController.text,
                    // ).then((value) {
                    //   getDataFromDatabase(database).then((value) {
                    //
                    //
                    //     setState(() {
                    //       isBottomSheet = false;
                    //       iconFloating = Icons.edit;
                    //       taskView = value;
                    //       print(taskView);
                    //     });
                    //   });
                    // });
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultTextForm(
                                    controller: titleController,
                                    keyBoardType: TextInputType.text,
                                    label: 'Task title',
                                    preIcon: Icons.title,
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'Title must not be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultTextForm(
                                    controller: timeController,
                                    keyBoardType: TextInputType.datetime,
                                    label: 'Task time',
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) => {
                                            timeController.text = value!
                                                .format(context)
                                                .toString(),
                                          });
                                    },
                                    preIcon: Icons.watch_later_outlined,
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'Time must not be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultTextForm(
                                    controller: dateController,
                                    keyBoardType: TextInputType.datetime,
                                    label: 'Task date',
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2023-10-12'),
                                      ).then((value) => {
                                            dateController.text =
                                                DateFormat.yMMMd()
                                                    .format(value as DateTime),
                                            debugPrint(DateFormat.yMMMd()
                                                .format(value)),
                                          });
                                    },
                                    preIcon: Icons.calendar_today,
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'Date must not be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ]),
                          ),
                        ),
                        elevation: 50.0,
                      )
                      .closed
                      .then((value) => {
                            cubit.changeButtonSheetState(
                                isShow: false, icon: Icons.edit),
                          });
                  cubit.changeButtonSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(
                cubit.iconFloating,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.check_circle_outline,
                    ),
                    label: 'Done'),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive,
                    ),
                    label: 'Archived'),
              ],
            ),
          );
        },
      ),
    );
  }
}
