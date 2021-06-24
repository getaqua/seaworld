import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/widgets/content.dart';

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
        actions: [
          IconButton(onPressed: () => Get.toNamed("/settings"), icon: Icon(Mdi.cog))
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(8))
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: Center(
          child: Container(
            width: 480,
            margin: EdgeInsets.all(8.0),
            child: FutureBuilder<List<Content>>(
              future: API.followedContent(),
              builder: (context, snapshot) => 
              (!snapshot.hasData && !snapshot.hasError) ? Center(child: CircularProgressIndicator(value: null))
              : (snapshot.hasData) ? ListView.builder(
                itemBuilder: (context, index) => ContentWidget(snapshot.data![index]),
                itemCount: snapshot.data!.length,
              ) : Center(child: Icon(Mdi.alert, color: Colors.red))
            ),
          ),
        ),
      ),
    );
  }
}