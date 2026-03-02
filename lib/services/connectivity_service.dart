import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class NetworkService {
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  void initialize(BuildContext context) {
    getConnectivity(context);
  }

  void getConnectivity(BuildContext context) {
    subscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && !isAlertSet) {
          showDialogBox(context);
          isAlertSet = true;
        }
      },
    );
  }

  // void showDialogBox(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // Prevents dismissal by tapping outside
  //     builder: (BuildContext context) => WillPopScope(
  //       onWillPop: () async => false, // Prevents dismissal by back button
  //       child: CupertinoAlertDialog(
  //         title: Text(
  //          ('No Connection'),
  //         ),
  //         content: Text(
  //           ('Please check your internet connectivity'),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () async {
  //               isAlertSet = false;
  //               Navigator.pop(context);
  //               isDeviceConnected =
  //                   await InternetConnectionChecker().hasConnection;
  //               if (!isDeviceConnected && !isAlertSet) {
  //                 showDialogBox(context);
  //                 isAlertSet = true;
  //               }
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void showDialogBox(BuildContext context) {
    Alert(
      context: context,
      title: "No Connection",
      content: const Text("Please check your internet connectivity"),
      buttons: [
        DialogButton(
          onPressed: () async {
            isAlertSet = false;
            Navigator.pop(context);
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && !isAlertSet) {
              showDialogBox(context);
              isAlertSet = true;
            }
          },
          color: Colors.black,
          child: Text("OK", style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  void dispose() {
    subscription.cancel();
  }
}
