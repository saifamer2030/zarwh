
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vision/main.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}
class _SplashState extends State<Splash> {
///
  @override
  void initState() {
    super.initState();




    Future.delayed(Duration(seconds: 4), () async {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 2000),
          pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return MyHomePage();
          },
          // transitionsBuilder: (
          //     BuildContext context,
          //     Animation<double> animation,
          //     Animation<double> secondaryAnimation,
          //     Widget child) {
          //   return Align(
          //     child: FadeTransition(
          //       opacity: animation,
          //       child: child,
          //     ),
          //   );
          // },
        ),
      );

    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        // decoration: BoxDecoration(
        //   // image: DecorationImage(
        //   //   image: const AssetImage('assets/images/background.png'),
        //   //   fit: BoxFit.fill,
        //   // ),
        // ),
        child:
            Center(
              child: Hero(
                tag: "logoA",
                child: AvatarGlow(
                  glowColor: Colors.orangeAccent,
                  endRadius: 300.0,
                  duration: Duration(milliseconds: 1500),
                  repeat: true,
                  showTwoGlows: true,
                  child: Container(
                    width: 302.0,
                    height: 191.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/logo.png'),
                      ),
                    ),
                  ),
                ),
              ),

        ),

      ),
    );
  }
}
