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
  Future<List<Content>> _content = API.followedContent();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Config.cache.serverName),
        actions: [
          IconButton(onPressed: () => setState(() {_content = API.followedContent();}), icon: Icon(Mdi.refresh)),
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
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: FutureBuilder<List<Content>>(
                    future: _content,
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
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0), bottom: Radius.zero),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Get.theme.colorScheme.primary,
          selectedItemColor: Get.theme.colorScheme.onPrimary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.water_rounded),
              label: "Flows",
            ),
            BottomNavigationBarItem(
              icon: Icon(Mdi.home),
              label: "Feed",
            ),
            BottomNavigationBarItem(
              icon: Icon(Mdi.message),
              label: "Chat",
            ),
          ],
          currentIndex: 1,
        ),
      ),
    );
  }
}