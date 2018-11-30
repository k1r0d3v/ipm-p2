import 'package:flutter/material.dart';
import 'bloc_provider.dart';
import 'bloc/viewer_bloc.dart';
import 'gallery_image_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'dart:typed_data';

class ViewerPage extends StatefulWidget {
  @override
  ViewerPageState createState() => ViewerPageState();
}

class ViewerPageState extends State<ViewerPage> {
  PageController _controller;
  bool _cartoon = true;
  int _index;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var bloc = BlocProvider.of<ViewerBloc>(context);
    _index = bloc.index;
    _controller = PageController(initialPage: bloc.index);
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<ViewerBloc>(context);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: PageView.builder(
            controller: _controller,
            itemCount: bloc.entries.length,
            itemBuilder: (context, index) => Image(
                image: GalleryImageProvider(
                    entry: bloc.entries[index], lod: 100, cartoon: _cartoon)),
          ),
        ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          start: 0.0,
          end: 0.0,
          top: 0.0,
          child: AppBar(
            title: Text(''),
            backgroundColor: Colors.black26,
            elevation: 0.0,
          ),
        ),
        Positioned.directional(
          textDirection: TextDirection.ltr,
          start: 0.0,
          end: 0.0,
          bottom: 0.0,
          child: Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.black54.withOpacity(0.0)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.share,
                            size: 32.0,
                          ),
                          tooltip: 'Share',
                          color: Colors.white,
                          onPressed: () => (_cartoon
                                  ? bloc.entries[_index].cartoon(100)
                                  : bloc.entries[_index].photo(100))
                              .then((bytes) => EsysFlutterShare.shareImage(
                                  '${bloc.entries[_index].key}.jpg',
                                  Uint8List.fromList(bytes).buffer.asByteData(),
                                  'Share image')),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            Icons.swap_vert,
                            size: 32.0,
                          ),
                          tooltip: 'Swap real / cartoon',
                          color: Colors.white,
                          onPressed: () => setState(() {
                                _cartoon = !_cartoon;
                              }),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
