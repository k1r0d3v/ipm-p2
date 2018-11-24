import 'package:flutter/material.dart';

import 'bloc_provider.dart';
import 'bloc/home_bloc.dart';

import 'home_page.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPM-P2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<HomeBloc>(
        bloc: HomeBloc(),
        builder: (context, snapshot) => HomePage(),
      ),
    );
  }
}

void main() => runApp(MyApp());
