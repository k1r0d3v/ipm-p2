import 'package:flutter/material.dart';

import 'bloc_provider.dart';
import 'bloc/test_bloc.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPM-P2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<TestBloc>(
        bloc: TestBloc(),
        builder: (context, snapshot) => Container(),
      ),
    );
  }
}

void main() => runApp(MyApp());
