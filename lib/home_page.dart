import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gallery_image_provider.dart';
import 'bloc/home_bloc.dart';
import 'bloc_provider.dart';
import 'camera.dart';

import 'viewer_page.dart';
import 'bloc/viewer_bloc.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _navSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasBloc<HomeBloc>(context));
    var bloc = BlocProvider.of<HomeBloc>(context);

    _navSubscription ??= bloc.gotoGalleryEventStream.listen((_) =>
        Navigator.push(context, MaterialPageRoute(builder: (context) => 
          BlocProvider<ViewerBloc>(
            bloc: ViewerBloc(bloc.lastEntry),
            builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done ? ViewerPage() : Container(),
          )
        )));
  }

  @override
  void dispose() {
    _navSubscription.cancel();
    _navSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasBloc<HomeBloc>(context));
    var bloc = BlocProvider.of<HomeBloc>(context);

    var o = MediaQuery.of(context).orientation;
    Widget left = GalleryButton(onTap: () {
      HapticFeedback.lightImpact();
      bloc.gotoGalleryEventSink.add(null);
    });

    Widget right = Container();

    if (o == Orientation.landscape) {
      right = left;
      left = Container();
    }

    return HomeLayout(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: CameraWidget(
        takePictureStream: bloc.takePhotoEventStream,
        pictureSink: bloc.photoSink,
      ),
      actions: <Widget>[
        Expanded(child: left),
        Expanded(child: CameraButton(onTap: () {
          HapticFeedback.lightImpact();
          bloc.takePhotoEventSink.add(null);
        })),
        Expanded(child: right),
      ],
    );
  }
}

class HomeLayout extends StatelessWidget {
  HomeLayout({Key key, this.appBar, this.body, this.actions, this.overlay})
      : super(key: key);

  final Widget appBar;
  final Widget body;
  final List<Widget> actions;
  final Widget overlay;

  @override
  Widget build(BuildContext context) {
    var o = MediaQuery.of(context).orientation;
    return Stack(
      children: <Widget>[
        Positioned.fill(child: body ?? Container()),
        Positioned.directional(
            textDirection: TextDirection.ltr,
            top: 0.0,
            start: 0.0,
            end: 0.0,
            child: appBar),
        o == Orientation.portrait
            ? Positioned.directional(
                textDirection: TextDirection.ltr,
                bottom: 0.0,
                start: 0.0,
                end: 0.0,
                child: _containerIfNull(
                    Material(
                        color: Colors.transparent,
                        child: Row(children: actions)),
                    actions),
              )
            : Positioned.directional(
                textDirection: TextDirection.ltr,
                top: 0.0,
                bottom: 0.0,
                end: 0.0,
                child: _containerIfNull(
                    Material(
                        color: Colors.transparent,
                        child: Column(children: actions)),
                    actions),
              ),
        overlay ?? Container()
      ],
    );
  }

  Widget _containerIfNull(Widget w, var cnd) => cnd == null ? Container() : w;
}

class CameraButton extends StatelessWidget {
  CameraButton({Key key, this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(Icons.camera),
      iconSize: 96.0,
      color: Colors.white,
    );
  }
}

class GalleryButton extends StatelessWidget {
  GalleryButton({Key key, this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<HomeBloc>(context);

    return RepaintBoundary(
      child: StreamBuilder(
        stream: bloc.cartoonProcessorStream,
        builder: (context, snapshot) {
          // Process the image on photo event
          if (snapshot.connectionState == ConnectionState.active)
            return FutureBuilder(
                future: snapshot.data,
                builder: (context, snapshot) {
                  // Image processed, show it
                  if (snapshot.connectionState == ConnectionState.done)
                    return _circleButton(
                      GalleryImageProvider(
                          entry: bloc.lastEntry, lod: 25, cartoon: false),
                    );

                  // The image is processing
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                });

          // Load last entry if present else hide the gallery
          return bloc.lastEntry != null
              ? _circleButton(
                  GalleryImageProvider(
                      entry: bloc.lastEntry, lod: 25, cartoon: false),
                )
              : Container();
        },
      ),
    );
  }

  Widget _circleButton(ImageProvider provider) {
    return Material(
      color: Colors.transparent,
      elevation: 2.0,
      shape: CircleBorder(),
      child: Center(
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: provider != null ? DecorationImage(
              image: provider,
              fit: BoxFit.cover,
            ) : null,
          ),
          width: 64.0,
          height: 64.0,
          child: InkWell(
            onTap: onTap,
            customBorder: CircleBorder(),
          ),
        ),
      ),
    );
  }
}
