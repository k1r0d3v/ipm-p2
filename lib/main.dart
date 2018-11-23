import 'package:flutter/material.dart';

import 'model/fs_gallery_storage.dart';
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
        bloc: HomeBloc(FSGalleryStorage()),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return Container();
          return HomePage();
        },
      ),
    );
  }
}

void main() => runApp(MyApp());
