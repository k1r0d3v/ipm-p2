import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraWidget extends StatefulWidget {
  CameraWidget({Key key, this.pictureSink, this.takePictureStream})
      : super(key: key);

  final Sink<List<int>> pictureSink;
  final Stream takePictureStream;

  @override
  _CameraWidgetState createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController _controller;

  @override
  void initState() {
    super.initState();

    availableCameras().then((cameras) {
      // TODO: Select back camera
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      _controller.initialize().then((_) => mounted ? setState(() {}) : null);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null && _controller.value.isInitialized
        ? _cameraReady(context)
        : _cameraNoReady(context);
  }

  Widget _cameraReady(BuildContext context) {
    return StreamBuilder(
        stream: widget.takePictureStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active)
            return _cameraPreview(context);

          return _Flash(
            child: FutureBuilder(
              future: _takePicture(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done)
                  widget.pictureSink?.add(snapshot.data);

                return _cameraPreview(context);
              },
            ),
          );
        });
  }

  Widget _cameraPreview(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    final ratio = size.width > size.height
        ? size.height / size.width
        : size.width / size.height;

    return RepaintBoundary(
      child: Center(
        child: RotatedBox(
          quarterTurns: orientation == Orientation.portrait ? 0 : -1,
          child: Transform.scale(
            scale: _controller.value.aspectRatio / ratio,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cameraNoReady(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: Colors.white), //TODO: Theme.of(context).backgroundColor?
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  Future<List<int>> _takePicture() async {
    if (!_controller.value.isInitialized)
      //showInSnackBar('Error: select a camera first.');
      return null;

    final Directory folder = await path_provider.getTemporaryDirectory();
    final String filename = '${folder.path}/${DateTime.now().toString()}.jpg';

    // A capture is already pending, do nothing.
    if (_controller.value.isTakingPicture) return null;

    try {
      await _controller.takePicture(filename);
      return await File(filename).readAsBytes();
    } on CameraException catch (e) {
      print('$e');
      // TODO: _showCameraException(e);
      return null;
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}

class _Flash extends StatefulWidget {
  _Flash({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  _FlashState createState() => _FlashState();
}

class _FlashState extends State<_Flash> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() => setState(() {}));
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _controller.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(_Flash oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: _animation.value,
              child: Container(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}
