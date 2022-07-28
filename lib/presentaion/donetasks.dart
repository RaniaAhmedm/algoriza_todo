import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/core/cubit/states.dart';

import 'component.dart';
import '../core/cubit/cubit.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return   BlocConsumer<AppCubit,AppStates>(
        listener: (context,state){},
        builder: (context,state){
          var tasks = AppCubit.get(context).doneTasks;
          return  tasksBuilder(tasks: tasks);

        }

    );


  }
}
