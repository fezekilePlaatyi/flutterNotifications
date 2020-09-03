import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterBase',
      home: Scaffold(
        body: MessageHandler(),
      ),
    );
  }
}

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        print(data);
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _subscribeToTopic();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     content: ListTile(
        //       title: Text(message['notification']['title']),
        //       subtitle: Text(message['notification']['body']),
        //     ),
        //     actions: <Widget>[
        //       FlatButton(
        //         color: Colors.amber,
        //         child: Text('Ok'),
        //         onPressed: () => _showSnackBar(message.toString()),
        //       ),
        //     ],
        //   ),
        // );
        _showSnackBar(message.toString());
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _showSnackBar(message.toString());
        Navigator.push(context, PageTwo(message));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _showSnackBar(message.toString());
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _handleMessages(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('FCM Push Notifications'),
      ),
    );
  }

  // Subscribe the user to a topic
  _subscribeToTopic() async {
    // Subscribe the user to a topic
    _fcm.subscribeToTopic('puppies');
  }

  //
  _showSnackBar(String message) {
    final snackbar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Go',
        onPressed: () => null,
      ),
    );
    Scaffold.of(context).showSnackBar(snackbar);
  }

  //test fcm sending push
  _buildAndSendFCMMessage() async {
    var body = <String, dynamic>{
      'notification': <String, dynamic>{
        'body': 'titledddddddddddddd',
        'title': 'body',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK'
      },
      'priority': 'high',
      'data': <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'status': 'done'
      },
      'to': '/topics/puppies',
    };
    sendFcmMessage(body);
  }

  //send fcm message
  Future<Map<String, dynamic>> sendFcmMessage(Map body) async {
    var mapInJsonString = json.encode(body);
    String serverToken =
        "AAAAfYh_87E:APA91bExovcGf1hqDDszhtZbIsiHDouiKeciBFfeYnFU4721uuzy_nwXFlyX5IZoxDuIHP7OG9tpy7bpQJOa4Rdg6_bRNd4iWuGY9LDlZMfYVziTKARL0tZ900dzP2cbr3gU3buk4K6_";

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: mapInJsonString,
    );

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    return completer.future;
  }
}

class PageTwo extends MaterialPageRoute<Null> {
  PageTwo(Map)
      : super(builder: (BuildContext ctx) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(ctx).canvasColor,
              elevation: 1.0,
            ),
            body: Center(
              child: RaisedButton(
                onPressed: null,
                child: Text(Map.toString()),
              ),
            ),
          );
        });
}
