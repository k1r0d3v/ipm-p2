import 'package:flutter/material.dart';
import 'bloc/bloc.dart';

Type _typeOf<T>() => T;

/// InheritedWidget this take the advantage
/// of the method inheritFromWBloc provider implementing idgetOfExactType that is O(1) with a small constant factor
/// but not supports states for calling dispose and init.
class _InheritedBloc<T extends Bloc> extends InheritedWidget {
  _InheritedBloc({Key key, @required this.bloc, this.child})
      : super(key: key, child: child);

  final T bloc;
  final Widget child;

  static T of<T extends Bloc>(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(_typeOf<_InheritedBloc<T>>())
              as _InheritedBloc<T>)
          ?.bloc;

  @override
  bool updateShouldNotify(_InheritedBloc<T> oldWidget) =>
      bloc != oldWidget.bloc;
}

class _BlocStateProvider<T extends Bloc> extends StatefulWidget {
  _BlocStateProvider({Key key, @required this.bloc, this.builder})
      : super(key: key);

  final T bloc;
  final AsyncWidgetBuilder<Bloc> builder;

  __BlocStateProviderState<T> createState() => __BlocStateProviderState<T>();
}

class __BlocStateProviderState<T extends Bloc>
    extends State<_BlocStateProvider> {
  T _bloc;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc;

    var futureInit = (_bloc as StatefulBloc)?.init();
    if (futureInit != null) {
      futureInit?.whenComplete(() => setState(() {
            _ready = true;
          }));
    } else
      _ready = true;
  }

  @override
  void dispose() {
    (_bloc as StatefulBloc)?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ready
        ? _InheritedBloc<T>(
            bloc: _bloc,
            child: widget.builder(
                context, AsyncSnapshot<T>.withData(ConnectionState.done, _bloc)))
        : widget.builder(
            context, AsyncSnapshot<T>.withData(ConnectionState.waiting, null));
  }
}

class BlocProvider<T extends Bloc> extends StatelessWidget {
  BlocProvider({Key key, @required this.bloc, this.builder}) : super(key: key);

  final T bloc;
  final AsyncWidgetBuilder<Bloc> builder;

  // TODO: Check when the BLOC is ready to use and assert if not
  static T of<T extends Bloc>(BuildContext context) =>
      _InheritedBloc.of<T>(context);

  @override
  Widget build(BuildContext context) {
    if (bloc is StatefulBloc)
      return _BlocStateProvider<T>(
        bloc: bloc,
        builder: builder,
      );
    else if (bloc is StatelessBloc)
      return _InheritedBloc<T>(
        bloc: bloc,
        child: builder(
            context, AsyncSnapshot<T>.withData(ConnectionState.done, bloc)),
      );
    else
      assert(false,
          '${context.widget.runtimeType} widget require a stateless or statefull bloc.');

    return null;
  }
}

bool debugCheckHasBloc<T extends Bloc>(BuildContext context) {
  var t = _typeOf<BlocProvider<T>>();

  assert(() {
    if (context.widget is! Material &&
        context.ancestorWidgetOfExactType(t) == null) {
      final StringBuffer message = StringBuffer();
      message.writeln('No $t widget found.');
      message.writeln('${context.widget.runtimeType} widget require a $t '
          'widget ancestor.');
      message.writeln(
          'To introduce a ${context.widget.runtimeType} widget, you can either directly '
          'include one, or use a widget that contains $t itself.');
      message.writeln(
          'The specific widget that could not find a $t ancestor was:');
      message.writeln('  ${context.widget}');
      final List<Widget> ancestors = <Widget>[];
      context.visitAncestorElements((Element element) {
        ancestors.add(element.widget);
        return true;
      });
      if (ancestors.isNotEmpty) {
        message.write('The ancestors of this widget were:');
        for (Widget ancestor in ancestors) message.write('\n  $ancestor');
      } else {
        message.writeln('This widget is the root of the tree, so it has no '
            'ancestors, let alone a "$t" ancestor.');
      }
      throw FlutterError(message.toString());
    }
    return true;
  }());
  return true;
}
