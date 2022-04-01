
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import 'PushNotifcation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<PushNotification> lstNotification =[];
  late final FirebaseMessaging _messaging;

  PushNotification? _notificationInfo;

  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  void registerNotification() async {
    
    await Firebase.initializeApp();

    FirebaseMessaging.instance.getToken().then((token)  {
      print('FCM TOKEN:');
      print(token);
      print('END');
    });

    
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);



    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (Platform.isAndroid) {
      
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(message.notification?.title ?? "TITLE");
        print(message.notification?.body ?? "BODY");
        var notification = PushNotification();
        notification.title = message.notification?.title ?? "TITLE";
        notification.body = message.notification?.body ?? "BODY";
        this.lstNotification.add(notification);

        setState(() {
          _notificationInfo = notification;
        });
        
      });




    } else if (Platform.isIOS) {
   
      if ( settings.authorizationStatus == AuthorizationStatus.authorized) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print(message.notification?.title ?? "TITLE");
          print(message.notification?.body ?? "BODY");
          
          
        });
      } else {
        print('User declined or has not accepted permission');
      }
    }

  }




  @override
  void initState() {
   
    registerNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      this.lstNotification.add(notification);

      setState(() {
        _notificationInfo = notification;
      });
    });

    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(widget.title),
      ),
      body: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'List remote notifications:',
            ),
        Expanded(
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: this.lstNotification.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  child: ListTile(leading: Text(this.lstNotification[index].title.toString()),
                    title: Text(this.lstNotification[index].body.toString()),
                  )
                );
              }
          ),
        )
          ],
        ),
      ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}