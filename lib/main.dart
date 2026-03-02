import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hash_mufattish/firebase_options.dart';
import 'package:provider/provider.dart';

import 'package:hash_mufattish/services/notification_service.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/LanguageTranslate/l10n.dart';
import 'package:hash_mufattish/Providers/checklist_Provider.dart';
import 'package:hash_mufattish/Providers/edit_Profile_Provider.dart';
import 'package:hash_mufattish/Providers/local_Provider.dart';
import 'package:hash_mufattish/Screens/splashscreen.dart';

// ✅ Global variable notification data store karne ke liye
Map<String, dynamic>? _notificationData;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Notification click callback ke saath init karna
  await NotificationService().init(
    onNotificationClicked: (data) {
      print('Notification clicked with data: $data');
      _notificationData = data;
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<ChecklistProvider>(
          create: (_) => ChecklistProvider(),
        ),
        ChangeNotifierProvider<EditProfileProvider>(
          create: (_) => EditProfileProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // ✅ App initialize hone ke baad notification check karna
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_notificationData != null && mounted) {
        // Notification data process karna
        print('Processing notification data: $_notificationData');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xff0DC5B9),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      locale: provider.locale,
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
