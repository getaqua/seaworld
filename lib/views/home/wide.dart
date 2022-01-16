import 'dart:async';

import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/widgets/content.dart';
import 'package:seaworld/widgets/empty.dart';
import 'package:seaworld/widgets/pfp.dart';
import 'package:seaworld/widgets/post.dart';

class WideHomeView extends StatefulWidget {
  @override
  _WideHomeViewState createState() => _WideHomeViewState();
}

class _WideHomeViewState extends State<WideHomeView> {
  static const int _widthBreakpoint = 872;
  //Future<List<Content>> _content = API.followedContent();
  List<Content> _lastContent = [];
  final StreamController<List<Content>> _content = StreamController.broadcast();
  int _page = 1;
  final PageController pageController = PageController(initialPage: 1);

  void refreshContent() async {
    //setState(() {});
    try {
      _content.add(await API.followedContent());
    } catch(e) {
      _content.addError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    refreshContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Config.cache.serverName),
        actions: [
          IconButton(onPressed: () => refreshContent(), icon: Icon(Mdi.refresh)),
          IconButton(onPressed: () => Get.toNamed("/settings"), icon: Icon(Mdi.cog))
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(8))
        ),
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: pageController,
        onPageChanged: (index) {
          if (index == 1) {refreshContent();}
        },
        children: [
          Center( // Flows tab
            child: SizedBox(
              width: 480,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                    child: Text("flows.joined".tr, style: Get.textTheme.subtitle2),
                  ),
                  FutureBuilder<List<PartialFlow>>(
                    future: API.joinedFlows<PartialFlow>(),
                    builder: (context, snapshot) => snapshot.hasData ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (final flow in snapshot.data!) if (flow.snowflake != Config.cache.userFlow.snowflake) 
                        ListTile(
                          leading: ProfilePicture(
                            child: flow.avatarUrl != null ? NetworkImage(flow.avatarUrl!) : null,
                            size: 48, notchSize: 16,
                            fallbackChild: FallbackProfilePicture(flow: flow)
                          ),
                          title: Text(flow.name),
                          subtitle: Text(flow.id),
                          onTap: () => Get.toNamed("/flow/"+flow.snowflake),
                        ),
                        if ((snapshot.data?.length??0) <= 1) Padding(
                          padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                          child: Text("flows.none".tr, style: Get.textTheme.caption),
                        ),
                      ]
                    ) : Center(child: CircularProgressIndicator(value: null))
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                    child: Text("flows.following".tr, style: Get.textTheme.subtitle2),
                  ),
                  FutureBuilder<List<PartialFlow>>(
                    future: API.followedFlows<PartialFlow>(),
                    builder: (context, snapshot) => snapshot.hasData ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (final flow in snapshot.data!) if (flow.snowflake != Config.cache.userFlow.snowflake) 
                        ListTile(
                          leading: ProfilePicture(
                            child: flow.avatarUrl != null ? NetworkImage(flow.avatarUrl!) : null,
                            size: 48, notchSize: 16,
                            fallbackChild: FallbackProfilePicture(flow: flow)
                          ),
                          title: Text(flow.name),
                          subtitle: Text(flow.id),
                          onTap: () => Get.toNamed("/flow/"+flow.snowflake),
                        ),
                        if ((snapshot.data?.length??0) <= 1) Padding(
                          padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                          child: Text("flows.none".tr, style: Get.textTheme.caption),
                        ),
                      ]
                    ) : Center(child: CircularProgressIndicator(value: null))
                  ),
                ],
              ),
            )
          ),
          Row( // Home tab
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (MediaQuery.of(context).size.width >= _widthBreakpoint) Column(
                children: [
                  Container(
                    width: 360,
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.all(8.0),
                    child: NewContentCard(refreshContent: refreshContent),
                  ),
                ],
              ),
              Expanded(
                flex: (Get.mediaQuery.size.width < _widthBreakpoint) ? 1 : 0,
                child: RefreshIndicator(
                  onRefresh: () async {
                    refreshContent();
                    try {
                      await for (var _ in _content.stream) {
                        return;
                      }
                    } catch (e) {
                      return;
                    }
                    //await Future.doWhile(() => (_refreshing));
                  },
                  child: Center(
                    child: Container(
                      width: 480,
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: StreamBuilder<List<Content>>(
                        stream: _content.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) _lastContent = snapshot.data!;
                          final _prefixes = Column(children:[
                            Container(height: 8), // top padding the hard way
                            if (Get.mediaQuery.size.width < _widthBreakpoint) NewContentCard(),
                            if (snapshot.hasError) Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Mdi.weatherLightning, color: Colors.red),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("crash.connectionerror.title".tr, style: Get.textTheme.headline6?.copyWith(color: Colors.red)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("crash.connectionerror.generic".tr, style: Get.textTheme.bodyText2),
                                    ),
                                  ]
                                )
                              ]
                            ),
                            if (!snapshot.hasData && !snapshot.hasError) Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: CircularProgressIndicator(value: null, color: Get.theme.colorScheme.secondary)
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text("home.content.loading".tr, style: Get.textTheme.headline6?.copyWith(color: Get.theme.colorScheme.secondary)),
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(8.0),
                                    //   child: Text("home.".tr, style: Get.textTheme.bodyText2),
                                    // ),
                                  ]
                                )
                              ]
                            )
                          ]);
                          return (!snapshot.hasData && !snapshot.hasError && _lastContent.isEmpty) ? Center(child: CircularProgressIndicator(value: null))
                            : (snapshot.hasData && snapshot.data!.isEmpty) ? ListView.builder(
                              itemBuilder: (context, index) => 
                                index == 0 ? _prefixes : NormalEmptyState(),
                              itemCount: snapshot.data!.length + 2
                          ) : (snapshot.hasData) ? ListView.builder(
                              itemBuilder: (context, index) => 
                                index == 0 ? _prefixes : ContentWidget(snapshot.data![index-1]),
                              itemCount: snapshot.data!.length + 1
                          ) : (!snapshot.hasData && _lastContent.isNotEmpty) ? ListView.builder(
                              itemBuilder: (context, index) => 
                                index == 0 ? _prefixes : ContentWidget(_lastContent[index-1]),
                              itemCount: _lastContent.length + 1
                          ) : Center(child: Icon(Mdi.alert, color: Colors.red));
                        }
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0), bottom: Radius.zero),
        child: BottomNavigationBar(
          onTap: (index) {
            _page = index;
            pageController.animateTo(index.toDouble()*MediaQuery.of(context).size.width, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Get.theme.brightness == Brightness.light ? Get.theme.colorScheme.primary : Get.theme.primaryColor,
          selectedItemColor: Get.theme.brightness == Brightness.light ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.onSurface,
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
          currentIndex: _page,
        ),
      ),
    );
  }
}