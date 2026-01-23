import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:lean_sdk_flutter/lean_sdk_flutter.dart';

void main() {
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkHandling();
  }

  Future<void> _initDeepLinkHandling() async {
    _linkSub = AppLinks().uriLinkStream.listen(
      (uri) {
        _handleIncomingUri(uri);
      },
      onDone: () {
        print('Done listening for URI');
      },
      onError: (err) {
        print('Error listening for URI: $err');
      },
    );
  }

  void _handleIncomingUri(Uri uri) {
    print('URI Path: ${uri.path}');
    print('URI Query Parameters: ${uri.queryParameters}');
    if (uri.path == "/lean-success") {
      // navigatorKey.currentState?.pushReplacementNamed('lean-success-screen');
    } else {
      // navigatorKey.currentState?.pushReplacementNamed('lean-failure-screen');
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Lean SDK Integration',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Lean SDK Integration'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Connect to Bank Account'),
            ElevatedButton(
              onPressed: linkBankAccount,
              child: Text('Connect Account'),
            ),
          ],
        ),
      ),
    );
  }

  void linkBankAccount() {
    final now = DateTime.now();
    final accessTo = DateTime(now.year, now.month, now.day + 1);
    final accessFrom = DateTime(now.year - 1, now.month, now.day);
    showDialog(
      context: context,
      builder: (BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Lean.connect(
            showLogs: true,
            env: 'sandbox',
            // use 'sandbox' for testing & 'production' for Live
            isSandbox: true,
            appToken: '<App-Token>',
            // get this app token from Lean Dashboard
            permissions: [
              LeanPermissions.identity,
              LeanPermissions.transactions,
              LeanPermissions.balance,
              LeanPermissions.accounts,
            ],
            // add permission according to your needs
            country: LeanCountry.sa,
            // use LeanCountry.sa for Saudi Arabia and LeanCountry.ae for UAE
            language: LeanLanguage.en,
            // use LeanLanguage.en for English & LeanLanguage.ar for Arabic
            customerId: '<Customer-ID>',
            // get this customer id from server
            accessToken: '<Access-Token>',
            // get this access token from server
            successRedirectUrl: 'myapp://open.my.app/lean-success',
            // these will be used to redirect back to your app from browser after success or faliure
            failRedirectUrl: 'myapp://open.my.app/lean-fail',
            // you can change URL scheme 'myapp' according to your app name(e.g mytodoapp)
            // to avoid conflict with apps using this generic scheme
            // remember to match this scheme in AndroidManifest.xml and Info.plist
            accessTo: accessTo.toIso8601String(),
            accessFrom: accessFrom.toIso8601String(),
            // optional to setup start and end dates of records to be fetched
            callback: (LeanResponse resp) {
              print(
                'Lean Response: status=${resp.status}, message=${resp.message}, '
                'exitPoint=${resp.exitPoint}, intent=${resp.exitIntentPoint}, '
                'correlationId=${resp.leanCorrelationId}',
              );
            },
            actionCancelled: () {
              print('Lean Action Cancelled');
            },
          ),
        ),
      ),
    );
  }
}
