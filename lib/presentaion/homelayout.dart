import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/core/cubit/cubit.dart';
import 'package:todoapp/core/cubit/states.dart';

class HomeLayout extends StatelessWidget
{

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context)=>AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit , AppStates>(
     listener: (BuildContext context , AppStates states){
       if(states is AppInsertDatabaseState){
         Navigator.pop(context);
       }
     },
        builder: (BuildContext context , AppStates state){
       AppCubit cubit = BlocProvider.of(context);
       return Scaffold(
         key: scaffoldKey,
         appBar: AppBar(
           toolbarHeight: 70.0,
           backgroundColor: Colors.white,
           elevation: 0.0,
           centerTitle: true,
           title: Text( cubit.titles[cubit.currentIndex],
             style: TextStyle(fontSize: 25.0),
           ),
           flexibleSpace: Container(
             decoration: const BoxDecoration(
               color: Colors.blue,
               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40.0),bottomRight:Radius.circular(40.0), ),
             ),
           ),

         ),
         body: ConditionalBuilder(
           builder: (context) => cubit.screens[cubit.currentIndex],
           condition: state is! AppGetDatabaseLoadingState,
           fallback: (context) => const Center(child: CircularProgressIndicator()),
         ),
         floatingActionButton: FloatingActionButton(
           onPressed: () {
             if (cubit.isBottomSheetShown) {
               if (formKey.currentState!.validate()) {
                 cubit.insertToDataBase(title: titleController.text, time: timeController.text, date: dateController.text);

               }
             } else {
               scaffoldKey.currentState!
                   .showBottomSheet(
                     (context) => Container(
                   color: Colors.white,
                   padding: const EdgeInsets.all(20.0),
                   child: Form(
                     key: formKey,
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         TextFormField(
                           decoration: const InputDecoration(
                             enabledBorder: OutlineInputBorder(
                               borderRadius:
                               BorderRadius.all(Radius.circular(20.0)),
                             ),
                             hintText: 'Task Title',
                             prefixIcon: Icon(Icons.title),
                           ),
                           controller: titleController,
                           keyboardType: TextInputType.text,
                           validator: (value) {
                             if (value!.isEmpty) {
                               return "title must not be empty";
                             } else {
                               return null;
                             }
                           },
                         ),
                         const SizedBox(
                           height: 10.0,
                         ),
                         TextFormField(
                           decoration: const InputDecoration(
                             enabledBorder: OutlineInputBorder(
                               borderRadius:
                               BorderRadius.all(Radius.circular(20.0)),
                             ),
                             hintText: 'Task Time',
                             prefixIcon: Icon(Icons.watch_later_outlined),
                           ),
                           controller: timeController,
                           keyboardType: TextInputType.datetime,
                           validator: (value) {
                             if (value!.isEmpty) {
                               return "time must not be empty";
                             } else {
                               return null;
                             }
                           },
                           onTap: () {
                             showTimePicker(
                               context: context,
                               initialTime: TimeOfDay.now(),
                             ).then((value) {
                               timeController.text =
                                   value!.format(context).toString();
                               print(value.format(context));
                             });
                           },
                         ),
                         const SizedBox(
                           height: 10.0,
                         ),
                         TextFormField(
                           decoration: const InputDecoration(
                             enabledBorder: OutlineInputBorder(
                               borderRadius:
                               BorderRadius.all(Radius.circular(20.0)),
                             ),
                             hintText: 'Task Date',
                             prefixIcon: Icon(Icons.calendar_today),
                           ),
                           controller: dateController,
                           keyboardType: TextInputType.datetime,
                           validator: (value) {
                             if (value!.isEmpty) {
                               return "date must not be empty";
                             } else {
                               return null;
                             }
                           },
                           onTap: () {
                             showDatePicker(
                                 context: context,
                                 initialDate: DateTime.now(),
                                 firstDate: DateTime.now(),
                                 lastDate: DateTime.parse('2021-12-29'))
                                 .then((value) {
                               dateController.text = DateFormat.yMMMd()
                                   .format(value!)
                                   .toString();
                               print(DateFormat.yMMMd().format(value));
                             });
                           },
                         ),
                       ],
                     ),
                   ),
                 ),
                 elevation: 15.0,
               )
                   .closed
                   .then((value) {
                     cubit.changeBottomSheetState(isShow: false, icon: Icons.edit);
               });

               cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
             }
           },
           child: Icon(cubit.fbIcon),
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
                 icon: Icon(Icons.check_circle_outline), label: 'Done'),
             BottomNavigationBarItem(
                 icon: Icon(Icons.archive_outlined), label: 'Archived'),
           ],
         ),
       );
        },
      ),
    );
  }


}


