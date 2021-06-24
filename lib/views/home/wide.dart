import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/widgets/content.dart';
import 'package:seaworld/widgets/post.dart';

class WideHomeView extends StatefulWidget {
  @override
  _WideHomeViewState createState() => _WideHomeViewState();
}

class _WideHomeViewState extends State<WideHomeView> {
  static const int _widthBreakpoint = 872;
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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (Get.mediaQuery.size.width >= _widthBreakpoint) Column(
            children: [
              Container(
                width: 360,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.all(8.0),
                child: NewContentCard(),
              ),
            ],
          ),
          Expanded(
            flex: (Get.mediaQuery.size.width < _widthBreakpoint) ? 1 : 0,
            child: RefreshIndicator(
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
                      itemBuilder: (context, index) => 
                        index == 0 && Get.mediaQuery.size.width < _widthBreakpoint ? NewContentCard()
                        : index == 0 ? Container()
                        : ContentWidget(snapshot.data![index-1]),
                      itemCount: snapshot.data!.length + 1,
                    ) : Center(child: Icon(Mdi.alert, color: Colors.red))
                  ),
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}