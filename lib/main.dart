import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: 'Ain_shams Car pooling',
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
    home: SignInPage(),
  ));
}
