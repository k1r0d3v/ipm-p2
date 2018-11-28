import 'package:flutter/material.dart';

import 'bloc_provider.dart';
import 'bloc/home_bloc.dart';

import 'home_page.dart';
import 'model/fs_gallery_storage.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPM-P2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<HomeBloc>(
        bloc: HomeBloc(FSGalleryStorage()),
        builder: (context, snapshot) => 
          snapshot.connectionState == ConnectionState.done ?
          HomePage() : Container()
      ),
    );
  }
}

void main() => runApp(MyApp());
