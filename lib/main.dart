// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vision/splash.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
  if (kDebugMode) {
    print(message.data);
  }
  flutterLocalNotificationsPlugin.show(
    message.data.hashCode,
    message.data['title'],
    message.data['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channel.description,
      ),
    ),
  );
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
      // routes: {
      //   "red": (_) => RedPage(),
      //   "green": (_) => GreenPage(),
      // },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "";
  String url = "https://zarwh.com/app";
  bool isLoading = true;
  final _key = UniqueKey();
  String? token;
  bool? serviceEnabled;
  LocationPermission? permission;
  final GlobalKey webViewKey = GlobalKey();
  WebViewController? _webViewController;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  String jsString =
      'document.addEventListener("contextmenu", event => event.preventDefault());';

  @override
  void initState() {
    // TODO: implement initState
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    pSetting();
    var initialzationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android.smallIcon,
              ),
            ));
      }
    });
    getToken();
    // getTopics();
    _determinePosition();
    super.initState();
  }
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {

    }
    // setState(() {
    //
    // });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    /// إضافة ايتم
    if (mounted) {

    }
    // setState(() {
    //
    //
    // });
    _refreshController.loadComplete();
  }
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showAlertDialog(context);
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showAlertDialog(context);
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        await Geolocator.openLocationSettings();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Permissions are denied"),
      content: const Text(
          "we cannot request permissions.you could try requesting permissions again"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  late WebViewController webViewController;
 final sessionCookie = const WebViewCookie(
  name: 'my_session_cookie',
  value: 'cookie_value',
  domain: 'www.zarwh.com/app',
  );
  Future<void> _refresh(){
    // one of these should work. uncomment and see which one works.
    // controller.refresh()
    // controller.reload()
    return Future.delayed(const Duration(seconds: 2));
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (kDebugMode) {
          print('The user tries to pop()');
        }
        return false;
      },
      child: Scaffold(

        // backgroundColor:const Color(0xff37bfc3) ,
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   centerTitle: true,
        //   automaticallyImplyLeading: false,
        // ),
        body:   Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child:  WebView(
                        zoomEnabled: false,

                        initialCookies: [sessionCookie],
                          key: webViewKey,
                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                        ),
                      },
                          onWebViewCreated: (WebViewController webViewController) async {
                            _webViewController = webViewController;
                            _controller.complete(webViewController);
                          },
                          onPageFinished: (_) {
                            _webViewController!.runJavascript(jsString);
                            // _webViewController!.runJavascriptReturningResult(jsString);
                            setState(() {
                              isLoading = false;
                            });
                          },
                          onPageStarted: (_){
                            _webViewController!.runJavascript(jsString);
                            // _webViewController!.runJavascriptReturningResult(jsString);
                            setState(() {
                              isLoading = true;
                            });
                          },
                          // navigationDelegate: (NavigationRequest request) {
                          //   setState(() {
                          //     isLoading = true;
                          //   });
                          //
                          //   //Any other url works
                          //   return NavigationDecision.navigate;
                          // },
                          javascriptMode: JavascriptMode.unrestricted,
                          initialUrl: this.url,
                        navigationDelegate: (NavigationRequest request) {
                          // print("a1${request.url}///${token}///${Platform.isAndroid}");
// if(true){
                          if(
                          request.url.toString().toLowerCase().trim().contains(new RegExp("redirectSetToken".toLowerCase().trim(), caseSensitive: false))
                              ||  request.url.toString().toLowerCase().trim().contains(new RegExp("https://www.zarwh.com/app/user/login/redirectSetToken?userID=".toLowerCase().trim(), caseSensitive: false))
                          ){
                            // if(request.url.contains("https://www.zarwh.com/app/user/login/redirectSetToken?userID=")||
                            //     request.url.contains("redirectSetToken")){
                            // String userID="https://www.zarwh.com/app/user/login/redirectSetToken?userID=2".toString().split("=")[1];

                            String userID=request.url.toString().split("=")[1];
                            String url = "https://www.zarwh.com/app/user/login/setToken?Auth-key=${"zarwh-set-token"}&userID=${userID}&token=${token}&platform=${Platform.isAndroid?"android":Platform.isIOS?"ios":Platform.isFuchsia?"fuchsia":Platform.isWindows?"windows":""}";
                            Map<String, String> headers = {
                              //    'Content-Type': 'application/json',
                            };
                            print("vvv////${url}");
                            http.get(Uri.parse(url), headers: headers,
                              //     body: {
                              //   "platform":Platform.isAndroid?"android":Platform.isIOS?"ios":Platform.isFuchsia?"fuchsia":Platform.isWindows?"windows":"",
                              //   "Auth-key": "zarwh-set-token",
                              //   "userID":"165",
                              //   "token": "123",
                              // }
                            ).then((response) {
                              print("aaa${response.statusCode}");
                              print("aaa${response.body}");

                              if (response.statusCode == 200) {
                                var body = jsonDecode(response.body);
                                //  print("aaacc${body['mob_code']}");

                                if (body['status']=='Success') {

                                } else {

                                }
                              } else {

                              }


                            }).catchError((e) {

                              print('eeee:${e.toString()}');

                            });
                            return NavigationDecision.navigate;
                          }else{

                            return NavigationDecision.navigate;
                          }


                        },

                      ),

                  ),
                  isLoading
                      ? Center(
                          child: CupertinoActivityIndicator(),
                        )
                      : Stack(),
                ],
              ),


        ),

    );
  }

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
    setState(() {
      token = token;
    });
    if (kDebugMode) {
      print(token);
    }
  }

  pSetting() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('User granted provisional permission');
      }
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }
}

