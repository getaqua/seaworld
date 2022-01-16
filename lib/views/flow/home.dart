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
import 'package:seaworld/widgets/post.dart';
import 'package:super_scaffold/super_scaffold.dart';

class FlowHomeView extends StatefulWidget {
  final PartialFlow flow;
  const FlowHomeView({
    Key? key, required this.flow
  }) : super(key: key);
  @override
  _FlowHomeViewState createState() => _FlowHomeViewState();
}

class _FlowHomeViewState extends State<FlowHomeView> {
  static const int _widthBreakpoint = 872;
  //Future<List<Content>> _content = API.followedContent();
  List<Content> _lastContent = [];
  final StreamController<List<Content>> _content = StreamController.broadcast();
  void refreshContent() async {
    //setState(() {});
    _content.add((await API.getFlowAndContent(widget.flow.id)).content);
  }

  @override
  void initState() {
    super.initState();
    refreshContent();
  }

  @override
  Widget build(BuildContext context) {
    return SuperScaffold(
      appBar: SuperAppBar(
        title: Text(Config.cache.serverName),
        actions: [
          IconButton(onPressed: () => refreshContent(), icon: Icon(Mdi.refresh)),
          IconButton(onPressed: () => Get.toNamed("/settings"), icon: Icon(Mdi.cog))
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(8))
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                color: Get.theme.colorScheme.secondary,
              ),
              child: Column(
                children: [
                  // The user's profile picture avatar sphere thing
                  // The user's name and ID
                ],
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
              ),
            ),
            ListTile(
              selected: true,
              onTap: () {},
              title: Text("Home"),
            ),
            ListTile(
              onTap: () {},
              title: Text("Placeholder page"),
            ),
            ListTile(
              onTap: () {},
              title: Text("Chat"),
            ),
            ListTile(
              onTap: () {},
              title: Text("Placeholder page #2"),
            ),
          ],
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
                        )
                      ]);
                      return (!snapshot.hasData && !snapshot.hasError) ? Center(child: CircularProgressIndicator(value: null))
                        : (snapshot.hasData && snapshot.data!.isEmpty) ? ListView.builder(
                          itemBuilder: (context, index) => 
                            index == 0 ? _prefixes : NormalEmptyState(flow: widget.flow),
                          itemCount: snapshot.data!.length + 2
                      ) : (snapshot.hasData) ? ListView.builder(
                          itemBuilder: (context, index) => 
                            index == 0 ? _prefixes : ContentWidget(snapshot.data![index-1]),
                          itemCount: snapshot.data!.length + 1
                      ) : (snapshot.hasError) ? ListView.builder(
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
    );
  }
}