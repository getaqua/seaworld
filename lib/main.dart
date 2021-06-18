import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seaworld/views/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Seaworld/Aqua',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: "/login",
      getPages: [
        GetPage(name: "/login", page: () => const LoginView())
      ],
    );
  }
}