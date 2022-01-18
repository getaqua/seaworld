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
  ScrollController drawerScrollController = ScrollController();
  ScrollController scrollController = ScrollController();
  bool _lastSeenAboveTheThreshold = true;
  static const _scrollThreshold = 64;
  String? _bannerUrl;
  void refreshContent() async {
    //setState(() {});
    final flow = (await API.getFlowAndContent(widget.flow.id));
    _bannerUrl = flow.bannerUrl;
    _content.add(flow.content);
  }

  @override
  void initState() {
    super.initState();
    refreshContent();
    scrollController.addListener(() {
      if (scrollController.position.pixels > _scrollThreshold && _lastSeenAboveTheThreshold) {
        setState(() {_lastSeenAboveTheThreshold = false;});
      } else if (scrollController.position.pixels < _scrollThreshold && !_lastSeenAboveTheThreshold) {
        setState(() {_lastSeenAboveTheThreshold = true;});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SuperScaffold(
      appBar: SuperAppBar(
        title: Row(
          children: [
            ProfilePicture(
              child: widget.flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+widget.flow.avatarUrl!) : null,
              size: 36, notchSize: 8,
              fallbackChild: FallbackProfilePicture(flow: widget.flow)
            ),
            SizedBox(width: 12),
            Text(widget.flow.name),
          ],
        ),
        actions: [
          IconButton(onPressed: () => refreshContent(), icon: Icon(Mdi.refresh)),
          //IconButton(onPressed: () => Get.toNamed("/settings"), icon: Icon(Mdi.cog))
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(8))
        ),
      ),
      drawer: Drawer(
        child: ListView(
          controller: drawerScrollController,
          children: [
            Theme(
              data: Theme.of(context).copyWith(dividerTheme: DividerThemeData(thickness: 0, space: 0, color: Colors.transparent)),
              child: Material(
                color: Get.theme.colorScheme.secondary,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                child: DrawerHeader(
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Column(
                        children: [
                          // Align(
                          //   heightFactor: 1,
                          //   alignment: Alignment.topLeft,
                          //   child: IconButton(onPressed: () => Get.back(), icon: Icon(Mdi.arrowLeft)),
                          // ),
                          Expanded(child: Container()),
                          Align(
                            heightFactor: 1,
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ProfilePicture(
                                child: Config.cache.userFlow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+Config.cache.userFlow.avatarUrl!) : null,
                                size: 48, notchSize: 16,
                                fallbackChild: FallbackProfilePicture(flow: Config.cache.userFlow)
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Config.cache.userFlow.name, 
                                      style: Get.textTheme.headline6,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      textAlign: TextAlign.start,
                                    ),
                                    Text(
                                      Config.cache.userFlow.id,
                                      style: Get.textTheme.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: Container()),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Mdi.chevronDown),
                              )
                            ],
                          )
                          // The user's name and ID
                        ],
                        //mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                      ),
                      Positioned(
                        top: -8, left: -8,
                        child: IconButton(
                          icon: Icon(Mdi.arrowLeft),
                          onPressed: () => Get.back()
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              selected: true,
              onTap: () {},
              title: Text("flow.feature.home".tr),
            ),
            ListTile(
              onTap: () {},
              title: Text("Placeholder page"),
            ),
            ListTile(
              onTap: () {},
              title: Text("flow.feature.chat".tr),
            ),
            ListTile(
              onTap: () {},
              title: Text("Placeholder page #2"),
            ),
            if (widget.flow.myPermissions.update == AllowDeny.allow) ListTile(
              onTap: () => Get.toNamed("/flow/"+widget.flow.snowflake+"/settings", arguments: widget.flow),
              title: Text("flow.feature.settings".tr),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
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
                  Card(
                    color: Colors.lightBlue,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_bannerUrl != null && _bannerUrl != "") Image.network(API.get.urlScheme+Config.server+_bannerUrl!, height: 240, width: double.infinity, fit: BoxFit.fitWidth),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ProfilePicture(
                                child: widget.flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+widget.flow.avatarUrl!) : null,
                                size: 72, notchSize: 24,
                                fallbackChild: FallbackProfilePicture(flow: widget.flow)
                              ),
                            ),
                            Expanded(child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.flow.name, 
                                    style: Get.textTheme.headline4?.copyWith(color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade
                                  ),
                                  Text(widget.flow.id,
                                    style: Get.textTheme.headline6?.copyWith(color: Colors.black),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                        // use this RichText for extra stuff,
                        // like (pride) flags, location, etc
                        //RichText(text: TextSpan())
                        // TODO: tagline here, eventually
                        Row(children: [
                          if (widget.flow.myPermissions.join == AllowDeny.allow) Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              onPressed: () {}, // check if joined???
                              child: Text("flow.join".tr),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.black38 : Colors.black),
                                overlayColor: MaterialStateColor.resolveWith((states) => Colors.black26)
                              ),
                            ),
                          ), // make this button visible by turning it black
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: null,
                              child: Text("flow.follow".tr), 
                              style: ButtonStyle(
                                foregroundColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.black38 : Colors.black),
                                overlayColor: MaterialStateColor.resolveWith((states) => Colors.black26)
                              ),
                            ),
                          ),
                        ], mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.max,),
                        if (widget.flow.description?.isNotEmpty == true) Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.flow.description!, style: Get.textTheme.bodyText2?.copyWith(color: Colors.black)),
                        )
                      ],
                    ),
                  ),
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
                    controller: scrollController,
                    itemBuilder: (context, index) => 
                      index == 0 ? _prefixes : NormalEmptyState(flow: widget.flow),
                    itemCount: snapshot.data!.length + 2
                ) : (snapshot.hasData) ? ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) => 
                      index == 0 ? _prefixes : ContentWidget(snapshot.data![index-1]),
                    itemCount: snapshot.data!.length + 1
                ) : (snapshot.hasError) ? ListView.builder(
                    controller: scrollController,
                    itemBuilder: (context, index) => 
                      index == 0 ? _prefixes : ContentWidget(_lastContent[index-1]),
                    itemCount: _lastContent.length + 1
                ) : Center(child: Icon(Mdi.alert, color: Colors.red));
              }
            ),
          ),
        ),
      ),
    );
  }
}