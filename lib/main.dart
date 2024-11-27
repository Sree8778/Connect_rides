import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:users_connect_app/appInfo/app_info.dart';
import 'package:users_connect_app/auth/signin_page.dart';
import 'package:users_connect_app/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for Android and iOS
  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD0hstqPcfhpW_MGA8GKH1dtPp1shzL310",
        authDomain: "connect-8bc28.firebaseapp.com",
        projectId: "connect-8bc28",
        storageBucket: "connect-8bc28.appspot.com",
        messagingSenderId: "1055809100624",
        appId: "1:1055809100624:web:e3b77c62406934255e2a55",
        measurementId: "G-9K0ZQHPN86",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Request location permission
  await Permission.locationWhenInUse.isDenied.then((value) {
    if (value) {
      Permission.locationWhenInUse.request();
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Users App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Set home page based on user authentication status
        home: FirebaseAuth.instance.currentUser == null
            ? const SigninPage()
            : const HomePage(),
      ),
    );
  }
}
