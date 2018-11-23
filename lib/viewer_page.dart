import 'package:flutter/material.dart';
import 'bloc_provider.dart';
import 'bloc/viewer_bloc.dart';
import 'progressive_image.dart';

class ViewerPage extends StatefulWidget {
  @override
  ViewerPageState createState() => ViewerPageState();
}

class ViewerPageState extends State<ViewerPage> {
  PageController _controller;
  bool _cartoon = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var bloc = BlocProvider.of<ViewerBloc>(context);
    _controller = PageController(initialPage: bloc.index);
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<ViewerBloc>(context);
        return new Scaffold(
           appBar: new AppBar(
             title: Text (''),
              backgroundColor: Colors.black),
           body: new Container(
              decoration: new BoxDecoration(
                color: const Color(0xff000000),
                border: Border.all(
                  color: Colors.black,
                  width: 8.0,
                ),
              ),
              child: new Stack(
                children: <Widget> [
                   new PageView.builder(
                     controller: _controller,
                     reverse: true,
                     physics: new AlwaysScrollableScrollPhysics(),
                     scrollDirection: Axis.vertical,
                     itemCount: bloc.entries.length,
                     itemBuilder: (context, index) {
                       return ProgressiveImage(
                         entry: bloc.entries[index],
                         cartoon: _cartoon,
                         lods: [30,100],
                         fit: BoxFit.cover);
                     }
                   ),
                 ]),
              ),
           bottomNavigationBar: BottomAppBar(
             color: Colors.black,
             child: new Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               mainAxisSize: MainAxisSize.max,
               children: <Widget>[
                 IconButton(icon: Icon(
                     Icons.share,
                     color: Colors.white,
                     size: 32.0),
                   padding: new EdgeInsets.only(left: 75.0, bottom: 8.0),
                   alignment: Alignment.bottomLeft,
                   onPressed: () {
                   },
                 ),
                 IconButton(icon: Icon(
                     Icons.swap_vert,
                     color: Colors.white,
                     size: 32.0),
                   padding: new EdgeInsets.only(right: 75.0, bottom: 8.0),
                   tooltip: 'Swap real / cartoon',
                   alignment: Alignment.bottomRight,
                   onPressed: ()=> setState(() {
                       _cartoon = !_cartoon;
                   }),
                 ),
             ]),
          ));
    }
}

