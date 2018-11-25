import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bloc/home_bloc.dart';
import 'bloc_provider.dart';
import 'camera.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasBloc<HomeBloc>(context));

    var o = MediaQuery.of(context).orientation;
    Widget left = GalleryButton(onTap: () {
      HapticFeedback.lightImpact();
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
      body: CameraWidget(),
      actions: <Widget>[
        Expanded(child: left),
        Expanded(child: CameraButton(onTap: () {
          HapticFeedback.lightImpact();
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
    return RepaintBoundary(
      child: _circleButton(null)
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
