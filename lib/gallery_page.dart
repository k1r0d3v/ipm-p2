import 'package:flutter/material.dart';
import 'model/gallery_storage.dart';
import 'bloc_provider.dart';
import 'bloc/gallery_bloc.dart';
import 'bloc/viewer_bloc.dart';
import 'gallery_image_provider.dart';
import 'viewer_page.dart';

class GalleryPage extends StatefulWidget {
  @override
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  List<GalleryStorageEntry> entries;
  List<bool> selected;
  int selectedCount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      var bloc = BlocProvider.of<GalleryBloc>(context);
      selectedCount = 0;
      bloc.storage.list().toList().then((list) {
        setState(() {
          entries = list;
          selected = <bool>[];
          for (var i in entries)
            selected.add(false);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    var bloc = BlocProvider.of<GalleryBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Gallery'),
          actions: <Widget>[
            selectedCount > 0
                ? IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      for (int i = 0; i < selected.length; i++) {
                        if (selected[i]) {
                          bloc.storage.delete(entries[i].key);
                          entries.removeAt(i);
                          selected.removeAt(i);
                        }
                      }
                      setState(() {
                        selectedCount = 0;
                      });
                    })
                : Container()
          ],
        ),
        body: selected != null
            ? RepaintBoundary(child: _grid(entries, orientation))
            : Center(child: CircularProgressIndicator()));
  }

  Widget _grid(List<GalleryStorageEntry> entries, Orientation orientation) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          crossAxisCount: orientation == Orientation.portrait ? 2 : 4),
      padding: EdgeInsets.all(4.0),
      itemCount: entries.length,
      itemBuilder: (context, index) => Material(
            type: MaterialType.transparency,
            child: Center(
              child: Ink(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        colorFilter: selected[index]
                            ? ColorFilter.mode(
                                Colors.blue.withOpacity(0.6), BlendMode.srcATop)
                            : null,
                        image: GalleryImageProvider(
                          entry: entries[index],
                          lod: 40,
                          cartoon: false,
                        ),
                        fit: BoxFit.cover)),
                child: InkWell(onLongPress: () {
                  setState(() {
                    selectedCount++;
                    selected[index] = true;
                  });
                }, onTap: () {
                  if (selectedCount > 0) {
                    setState(() {
                      if (selected[index]) {
                        selectedCount--;
                        selected[index] = false;
                      } else {
                        selectedCount++;
                        selected[index] = true;
                      }
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<ViewerBloc>(
                              bloc: ViewerBloc(entries, index),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.done) return Container();
                                return ViewerPage();
                              },
                            ),
                      ),
                    );
                  }
                }),
              ),
            ),
          ),
    );
  }
}
