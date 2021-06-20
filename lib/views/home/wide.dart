import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';

class WideHomeView extends StatefulWidget {
  @override
  _WideHomeViewState createState() => _WideHomeViewState();
}

class _WideHomeViewState extends State<WideHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Config.cache.serverName),
      ),
    );
  }
}