import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  final GlobalKey<CoachMarkState> _calendarMark = GlobalKey();
  final GlobalKey<CoachMarkState> globalKey = GlobalKey();
  List<GlobalKey<CoachMarkState>> keys =
      List.generate(10, (index) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      // appBar: AppBar(
      //   title: const Text("Hello"),
      //   actions: <Widget>[
      //     CoachMark(
      //       key: _calendarMark,
      //       id: 'calendar_mark',
      //       text: 'Tap here to use the Calendar!',
      //       child: GestureDetector(
      //         onLongPress: () => _calendarMark.currentState!.show(),
      //         child: IconButton(
      //           onPressed: () => print('calendar'),
      //           icon: const Icon(Icons.calendar_today),
      //         ),
      //       ),
      //     ),
      //     PopupMenuButton<String>(
      //       itemBuilder: (BuildContext context) {
      //         return <PopupMenuEntry<String>>[
      //           const PopupMenuItem<String>(
      //             value: 'reset',
      //             child: Text('Reset'),
      //           ),
      //         ];
      //       },
      //       onSelected: (String value) {
      //         if (value == 'reset') {}
      //       },
      //     ),
      //   ],
      // ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 30,
          mainAxisSpacing: 50,
        ),
        itemCount: 10,
        itemBuilder: (_, i) {
          return CoachMark(
            key: keys[i],
            id: '$i',
            text: '',
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    keys[i].currentState!.show(i == 0 ? globalKey : null);
                  },
                  child: Container(
                    color: Colors.green,
                    width: 50,
                    height: 50,
                  ),
                ),
                DecoratedBox(
                  key: i == 0 ? globalKey : null,
                  decoration: BoxDecoration(
                      color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class CoachMark extends StatefulWidget {
  const CoachMark({
    Key? key,
    required this.id,
    required this.text,
    required this.child,
  }) : super(key: key);

  final String id;
  final String text;
  final Widget child;

  @override
  CoachMarkState createState() => CoachMarkState();
}

typedef CoachMarkRect = Rect Function();

class CoachMarkState extends State<CoachMark> {
  _CoachMarkRoute? _route;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(CoachMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuild();
  }

  @override
  void reassemble() {
    super.reassemble();
    _rebuild();
  }

  @override
  void dispose() {
    dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rebuild();
    return widget.child;
  }

  void show(GlobalKey? key) {
    if (key != null) {
      var a = key.currentContext!.findRenderObject() as RenderDecoratedBox;
      var b = a.decoration as BoxDecoration;
      print(b.borderRadius);
    }
    if (_route == null) {
      _route = _CoachMarkRoute(
        rect: () {
          final box = context.findRenderObject() as RenderDecoratedBox;
          return box.localToGlobal(Offset.zero) & box.size;
        },
        text: widget.text,
        padding: const EdgeInsets.only(right: 10, top: 0, left: 10),
        onPop: () {
          _route = null;
        },
      );
      Navigator.of(context).push(_route!);
    }
  }

  void _rebuild() {
    if (_route != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _route!.changedExternalState();
      });
    }
  }

  void dismiss() {
    if (_route != null) {
      _route!.dispose();
      _route = null;
    }
  }
}

class _CoachMarkRoute<T> extends PageRoute<T> {
  _CoachMarkRoute({
    required this.rect,
    required this.text,
    this.padding,
    this.onPop,
    this.shadow =
        const BoxShadow(color: const Color(0xB2212121), blurRadius: 8.0),
    this.maintainState = true,
    this.transitionDuration = const Duration(milliseconds: 450),
    RouteSettings? settings,
  }) : super(settings: settings);

  final CoachMarkRect rect;
  final String text;
  final EdgeInsets? padding;
  final BoxShadow shadow;
  final VoidCallback? onPop;

  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  @override
  Color get barrierColor => Colors.black.withOpacity(.2);

  @override
  String get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Rect position = rect();
    if (padding != null) {
      position = padding!.inflateRect(position);
    }
    position = Rect.fromCircle(
        center: position.center, radius: position.longestSide * 0.5);
    final clipper = _CoachMarkClipper(position);
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => Navigator.of(context).pop(),
        child: IgnorePointer(
          ignoring: true,
          child: FadeTransition(
            opacity: animation,
            child: Stack(
              children: <Widget>[
                // Container(
                //   decoration: BoxDecoration(
                //     backgroundBlendMode: BlendMode.srcOut,
                //     gradient: LinearGradient(
                //       colors: [
                //         Color(0xff340048).withOpacity(0),
                //         Color(0xff240032).withOpacity(.85),
                //         Color(0xff240032).withOpacity(.85),
                //       ],
                //       end: Alignment.topCenter,
                //       begin: Alignment.bottomCenter,
                //       stops: [.05, .15, 0.02],
                //     ),
                //   ),
                // ),
                // ClipPath(
                //   clipper: clipper,
                //   child: BackdropFilter(
                //     filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                //     child: Container(
                //       color: Colors.transparent,
                //     ),
                //   ),
                // ),
                CustomPaint(
                  painter: _CoachMarkPainter(
                    rect: position,
                    shadow: shadow,
                  ),
                  child: SizedBox.expand(
                    child: Center(
                      child: Text(text,
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get opaque => false;
}

class _CoachMarkClipper extends CustomClipper<Path> {
  final Rect rect;

  _CoachMarkClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path.combine(PathOperation.difference,
        Path()..addRect(Offset.zero & size), Path()..addOval(rect));
  }

  @override
  bool shouldReclip(_CoachMarkClipper old) => rect != old.rect;
}

class _CoachMarkPainter extends CustomPainter {
  _CoachMarkPainter({
    required this.rect,
    required this.shadow,
  });

  final Rect rect;
  final BoxShadow shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final circle = rect.inflate(0);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawColor(shadow.color, BlendMode.dstATop);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          bottomRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
        shadow.toPaint()..blendMode = BlendMode.clear);
    canvas.drawRect(circle, shadow.toPaint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CoachMarkPainter old) => old.rect != rect;

  @override
  bool shouldRebuildSemantics(_CoachMarkPainter oldDelegate) => false;
}
