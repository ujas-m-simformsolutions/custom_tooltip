import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:genopets_tooltip/un-used%20files%20kept%20just%20for%20reference/gradient_helper.dart';

GlobalKey key = GlobalKey();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List keys = List.generate(10, (index) => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 30,
              mainAxisSpacing: 50,
            ),
            itemCount: 10,
            itemBuilder: (_, i) {
              return Container(
                key: keys[i],
                width: 100,
                height: 100,
                color: Colors.red,
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: GradientHelper(
                key: keys[5],
                screenSize: MediaQuery.of(context).size,
              ).getGradient(
                colors: [
                  Color(0xff340048).withOpacity(0),
                  Color(0xff240032).withOpacity(.85),
                  Color(0xff240032).withOpacity(.85),
                ],
              ),
            ),
          ),
          // ClipPath(
          //   clipper: CoachMarkClipper(
          //     Rect.fromLTWH(MediaQuery.of(context).size.width, 0, 100, 100),
          //   ),
          //   child: BackdropFilter(
          //     filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          //     child: Container(
          //       color: Colors.transparent,
          //     ),
          //   ),
          // ),
          // Positioned(
          //   top: 0,
          //   right: 0,
          //   child: CustomPaint(
          //     painter: CoachMarkPainter(
          //       rect: Rect.fromLTWH(
          //           MediaQuery.of(context).size.width, 0, 100, 100),
          //       shadow: const BoxShadow(
          //         color: Color(0xB2212121),
          //         blurRadius: 8.0,
          //       ),
          //       clipper: CoachMarkClipper(
          //         Rect.fromLTWH(MediaQuery.of(context).size.width, 0, 100, 100),
          //       ),
          //     ),
          //     child: Container(
          //       height: 100,
          //       width: 100,
          //       key: key,
          //       color: Colors.green,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
