import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/core/cubit/states.dart';

import '../../presentaion/archivedtasks.dart';
import '../../presentaion/donetasks.dart';
import '../../presentaion/newtasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());
  //obj from cubit
  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  late Database database;
  List<Widget> screens = [
    const TasksScreen(),
    const DoneScreen(),
    const ArchivedScreen(),
  ];
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];
  List<Map> newTasks =[];
  List<Map> doneTasks =[];
  List<Map> archivedTasks =[];

  void changeIndex(int index) {
    currentIndex = index;

    emit(AppChangeBottomNavBar());
  }

  void createDataBase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('DB created');
        database.execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT,date TEXT,time TEXT,status TEXT)').then((value) {
          print('table created');
        }).catchError((error) {
          print(error.toString());
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('DB opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDataBase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database.transaction((txn) async {
      txn.rawInsert(
              'INSERT INTO tasks (title,date,time,status) VALUES("$title","$date","$time","new")')
          .then((value) {
        print('$value insert successfully');
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);

      }).catchError((error) {
        print(error.toString());
      });
    });
  }

  void getDataFromDatabase(database)  {
    emit(AppGetDatabaseLoadingState());
    newTasks=[];
    doneTasks=[];
    archivedTasks=[];
     database.rawQuery('SELECT * FROM tasks').then((value) {


        value.forEach((element) {

          if (element['status'] == 'new') {
            newTasks.add(element);
          }
          else if (element['status'] == 'done') {
            doneTasks.add(element);
          }
          else
          {
           archivedTasks.add(element);
          }


        });
        emit(AppGetDatabaseState());

    });
  }

  void updateData({
  required String status,
  required int id
}){
 database.rawUpdate(
'UPDATE tasks SET status = ? WHERE id= ?',
[status,id]
 ).then((value) {
   getDataFromDatabase(database);
   emit(AppUpdateDatabaseState());

 });
}


  void deleteData({
    required int id
  }){database.rawDelete(
        'DELETE FROM tasks  WHERE id= ?', [id]
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());

    });
  }

  bool isBottomSheetShown = false;
  IconData fbIcon = Icons.edit;

  void changeBottomSheetState(  {required bool isShow ,required IconData icon}){
    isBottomSheetShown =isShow;
    fbIcon =icon;
    emit(AppChangeBottomSheet());

  }


}
