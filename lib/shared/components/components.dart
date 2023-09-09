import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultTextForm({
  required TextEditingController controller,
  required String label,
  required IconData preIcon,
  required String? Function(String? value) validate,
  Function(String value)? onChange,
  Function(String value)? onSubmit,
  void Function()? onTap,
  required TextInputType keyBoardType,
  void Function()? obscure,
  bool isPassword = false,
  IconData? sufIcon,
}) =>
    TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          preIcon,
        ),
        suffixIcon: sufIcon != null
            ? IconButton(
                onPressed: obscure,
                icon: Icon(
                  sufIcon,
                ))
            : null,
      ),
      validator: validate,
      keyboardType: keyBoardType,
      onChanged: onChange,
      onFieldSubmitted: onSubmit,
      onTap: onTap,
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.blue,
              child: Text(
                '${model['time']}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${model['title']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    '${model['date']}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'Done', id: model['id']);
              },
              tooltip: 'Add to Done Tasks',
              icon: const Icon(
                Icons.check_box,
                color: Colors.green,
              ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context)
                    .updateData(status: 'Archived', id: model['id']);
              },
              tooltip: 'Archive this task',
              icon: const Icon(
                Icons.archive,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(
          id: model['id'],
        );
      },
    );

Widget noTasksBuilder({
  required List<Map> taskView,
}) =>
    ConditionalBuilder(
      condition: taskView.isNotEmpty,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) =>
            buildTaskItem(taskView[index], context),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 20.0,
          ),
          child: Container(
            width: double.infinity,
            height: 1.0,
            color: Colors.grey[300],
          ),
        ),
        itemCount: taskView.length,
      ),
      fallback: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              color: Colors.grey,
              size: 60.0,
            ),
            Text(
              'No Tasks Yet , Please add some Tasks',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 70.0,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'You can remove a task by dragging it to the left or right',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
