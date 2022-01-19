import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart" hide Flow;
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/widgets/content.dart';
import 'package:seaworld/widgets/empty.dart';
import 'package:seaworld/widgets/pfp.dart';
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
  //static const int _widthBreakpoint = 872;
  //Future<List<Content>> _content = API.followedContent();
  List<Content> _lastContent = [];
  final StreamController<List<Content>> _content = StreamController.broadcast();
  ScrollController drawerScrollController = ScrollController();
  ScrollController scrollController = ScrollController();
  // bool _lastSeenAboveTheThreshold = true;
  // static const _scrollThreshold = 64;
  // String? _bannerUrl;
  // void refreshContent() async {
  //   //setState(() {});
  //   final flow = (await API.getFlowAndContent(flow.id));
  //   _bannerUrl = flow.bannerUrl;
  //   _content.add(flow.content);
  // }

  @override
  void initState() {
    super.initState();
    //refreshContent();
    // scrollController.addListener(() {
    //   if (scrollController.position.pixels > _scrollThreshold && _lastSeenAboveTheThreshold) {
    //     setState(() {_lastSeenAboveTheThreshold = false;});
    //   } else if (scrollController.position.pixels < _scrollThreshold && !_lastSeenAboveTheThreshold) {
    //     setState(() {_lastSeenAboveTheThreshold = true;});
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(FlowAPI.getFlowWithContent),
        variables: {"id": widget.flow.snowflake}
      ),
      builder: (result, {fetchMore, refetch}) {
        /// Can be [Flow], [PartialFlow], or [FlowWithContent].
        /// Check them all.
        late final PartialFlow flow;
        if (result.data?["getFlow"] == null) {
          flow = widget.flow;
        } else if (result.data?["getFlow"]["content"] == null) {
          flow = Flow.fromJSON(result.data!["getFlow"]);
        } else {
          flow = FlowWithContent.fromJSON(result.data!["getFlow"]);
        }
        return SuperScaffold(
        appBar: SuperAppBar(
          title: Row(
            children: [
              ProfilePicture(
                child: flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+flow.avatarUrl!) : null,
                size: 36, notchSize: 8,
                fallbackChild: FallbackProfilePicture(flow: flow)
              ),
              SizedBox(width: 12),
              Text(flow.name),
            ],
          ),
          actions: [
            IconButton(onPressed: () => refetch?.call(), icon: Icon(Mdi.refresh)),
            //IconButton(onPressed: () => context.go("/settings"), icon: Icon(Mdi.cog))
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
                  color: context.theme().colorScheme.secondary,
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
                            //   child: IconButton(onPressed: () => Navigator.pop(context)(), icon: Icon(Mdi.arrowLeft)),
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
                                        style: context.textTheme().headline6,
                                        maxLines: 1,
                                        overflow: TextOverflow.fade,
                                        textAlign: TextAlign.start,
                                      ),
                                      Text(
                                        Config.cache.userFlow.id,
                                        style: context.textTheme().caption,
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
                            onPressed: () => Navigator.pop(context)
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
                title: Text("flow.feature.home".tr()),
              ),
              ListTile(
                onTap: () {},
                title: Text("Placeholder page"),
              ),
              ListTile(
                onTap: () {},
                title: Text("flow.feature.chat".tr()),
              ),
              ListTile(
                onTap: () {},
                title: Text("Placeholder page #2"),
              ),
              if (flow.myPermissions.update == AllowDeny.ALLOW) ListTile(
                onTap: () => context.go("/flow/"+flow.snowflake+"/settings", extra: flow),
                title: Text("flow.feature.settings".tr()),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            refetch?.call();
            // try {
            //   await for (var _ in _content.stream) {
            //     return;
            //   }
            // } catch (e) {
            //   return;
            // }
            //await Future.doWhile(() => (_refreshing));
          },
          child: Center(
            child: Container(
              width: 480,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              padding: EdgeInsets.symmetric(vertical: 0),
              child: Builder(
                builder: (context) {
                  //if (result.data) _lastContent = snapshot.data!;
                  final _prefixes = Column(children:[
                    Container(height: 8), // top padding the hard way
                    Card(
                      color: Colors.lightBlue,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (flow.bannerUrl != null && flow.bannerUrl != "") Image.network(API.get.urlScheme+Config.server+flow.bannerUrl!, height: 240, width: double.infinity, fit: BoxFit.fitWidth),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ProfilePicture(
                                  child: flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+flow.avatarUrl!) : null,
                                  size: 72, notchSize: 24,
                                  fallbackChild: FallbackProfilePicture(flow: flow)
                                ),
                              ),
                              Expanded(child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(flow.name, 
                                      style: context.textTheme().headline4?.copyWith(color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade
                                    ),
                                    Text(flow.id,
                                      style: context.textTheme().headline6?.copyWith(color: Colors.black),
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
                            if (flow.myPermissions.join == AllowDeny.ALLOW) Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {}, // check if joined???
                                child: Text("flow.join".tr()),
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
                                child: Text("flow.follow".tr()), 
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.black38 : Colors.black),
                                  overlayColor: MaterialStateColor.resolveWith((states) => Colors.black26)
                                ),
                              ),
                            ),
                          ], mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.max,),
                          if (flow.description?.isNotEmpty == true) Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(flow.description!, style: context.textTheme().bodyText2?.copyWith(color: Colors.black)),
                          )
                        ],
                      ),
                    ),
                    if (result.hasException) Row(
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
                              child: Text("crash.connectionerror.title".tr(), style: context.textTheme().headline6?.copyWith(color: Colors.red)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("crash.connectionerror.generic".tr(), style: context.textTheme().bodyText2),
                            ),
                          ]
                        )
                      ]
                    )
                  ]);
                  return (flow is! FlowWithContent) ? Center(child: CircularProgressIndicator(value: null))
                    : (flow.content.isEmpty && !result.hasException) ? ListView.builder(
                      controller: scrollController,
                      itemBuilder: (context, index) => 
                        index == 0 ? _prefixes : NormalEmptyState(flow: flow),
                      itemCount: flow.content.length + 2
                  ) : (flow.content.isNotEmpty) ? ListView.builder(
                      controller: scrollController,
                      itemBuilder: (context, index) => 
                        index == 0 ? _prefixes : ContentWidget((flow as FlowWithContent).content[index-1]),
                      itemCount: flow.content.length + 1
                  ) : Center(child: Icon(Mdi.alert, color: Colors.red));
                }
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}