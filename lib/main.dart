import 'package:flutter/material.dart';
import 'package:wastemanagement/services/authcheck.dart';
import 'package:wastemanagement/services/firebase_options.dart';



import 'package:firebase_core/firebase_core.dart';



void main()async {

  await WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  
  runApp(const MainApp());

  

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:AuthCheck(),
    );
  }
}
