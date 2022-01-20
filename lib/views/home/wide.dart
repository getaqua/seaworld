import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/content.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/widgets/content.dart';
import 'package:seaworld/widgets/empty.dart';
import 'package:seaworld/widgets/pfp.dart';
import 'package:seaworld/widgets/post.dart';

// ignore: use_key_in_widget_constructors
class WideHomeView extends StatefulWidget {
  @override
  _WideHomeViewState createState() => _WideHomeViewState();
}

class _WideHomeViewState extends State<WideHomeView> {
  static const int _widthBreakpoint = 872;
  //Future<List<Content>> _content = API.followedContent();
  //final StreamController<List<Content>> _content = StreamController.broadcast();
  int _page = 1;
  final PageController pageController = PageController(initialPage: 1);
  final ScrollController homeController = ScrollController();
  final ScrollController flowsController = ScrollController();

  // void refreshContent() async {
  //   //setState(() {});
  //   try {
  //     _content.add(await API.followedContent());
  //   } catch(e) {
  //     _content.addError(e);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    //refreshContent();
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(ContentAPI.followedContent),
        fetchPolicy: FetchPolicy.cacheAndNetwork
      ),
      builder: (result, {fetchMore, refetch}) {
        final List<Content>? content = result.data?["getFollowedContent"]?.map<Content>((v) => Content.fromJSON(v)).toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(Config.cache.serverName),
            actions: [
              IconButton(onPressed: () => refetch?.call(), icon: Icon(Mdi.refresh)),
              IconButton(onPressed: () => context.go("/settings"), icon: Icon(Mdi.cog))
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.zero, bottom: Radius.circular(8))
            ),
          ),
          body: PageView(
            scrollDirection: Axis.horizontal,
            controller: pageController,
            onPageChanged: (index) {
              if (index == 1) {refetch?.call();}
            },
            children: [
              Center( // Flows tab
                child: SizedBox(
                  width: 480,
                  child: ListView(
                    controller: flowsController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                        child: Text("flows.joined".tr(), style: context.textTheme().subtitle2),
                      ),
                      Query(
                        options: QueryOptions(
                          document: gql(FlowAPI.followedFlows)
                        ),
                        builder: (result, {fetchMore, refetch}) => result.isNotLoading ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (final flow in result.data?["getFollowedFlows"]?.map((v) => PartialFlow.fromJSON(v))) if (flow.snowflake != Config.cache.userFlow.snowflake) 
                            ListTile(
                              leading: ProfilePicture(
                                child: flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+flow.avatarUrl!) : null,
                                size: 48, notchSize: 12,
                                fallbackChild: FallbackProfilePicture(flow: flow)
                              ),
                              title: Text(flow.name),
                              subtitle: Text(flow.id),
                              onTap: () => context.go("/flow/"+flow.snowflake),
                            ),
                            if (result.data?["getFollowedFlows"]?.isNotEmpty != true && result.hasException) Row(
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
                            else if ((result.data?["getFollowedFlows"].length??0) <= 1) Padding(
                              padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                              child: Text("flows.none".tr(), style: context.textTheme().caption),
                            ),
                          ]
                        ) : Center(child: CircularProgressIndicator(value: null))
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                        child: Text("flows.following".tr(), style: context.textTheme().subtitle2),
                      ),
                      Query(
                        options: QueryOptions(
                          document: gql(FlowAPI.joinedFlows)
                        ),
                        builder: (result, {fetchMore, refetch}) => result.isNotLoading ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (final flow in result.data?["getJoinedFlows"]?.map((v) => PartialFlow.fromJSON(v))) if (flow.snowflake != Config.cache.userFlow.snowflake) 
                            ListTile(
                              leading: ProfilePicture(
                                child: flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+flow.avatarUrl!) : null,
                                size: 48, notchSize: 12,
                                fallbackChild: FallbackProfilePicture(flow: flow)
                              ),
                              title: Text(flow.name),
                              subtitle: Text(flow.id),
                              onTap: () => context.go("/flow/"+flow.snowflake),
                            ),
                            if (result.data?["getJoinedFlows"]?.isNotEmpty != true && result.hasException) Row(
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
                            else if ((result.data?["getJoinedFlows"].length??0) <= 1) Padding(
                              padding: const EdgeInsets.all(8.0) - EdgeInsets.only(bottom: 8.0),
                              child: Text("flows.none".tr(), style: context.textTheme().caption),
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
                        child: NewContentCard(refreshContent: refetch),
                      ),
                    ],
                  ),
                  Expanded(
                    flex: (MediaQuery.of(context).size.width < _widthBreakpoint) ? 1 : 0,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        refetch?.call();
                        //await Future.doWhile(() => (_refreshing));
                      },
                      child: Center(
                        child: Container(
                          width: 480,
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          padding: EdgeInsets.symmetric(vertical: 0),
                          child: Builder(
                            builder: (context) {
                              //if (snapshot.hasData) _lastContent = snapshot.data!;
                              final _prefixes = Column(children:[
                                Container(height: 8), // top padding the hard way
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
                                ),
                                if (result.isLoading) Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SizedBox(
                                        height: 32,
                                        width: 32,
                                        child: CircularProgressIndicator(value: null, color: context.theme().colorScheme.secondary)
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text("home.content.loading".tr(), style: context.textTheme().headline6?.copyWith(color: context.theme().colorScheme.secondary)),
                                        ),
                                        // Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: Text("home.".tr(), style: context.textTheme().bodyText2),
                                        // ),
                                      ]
                                    )
                                  ]
                                )
                              ]);
                              return (content?.isNotEmpty != false && result.isLoading) ? Center(child: CircularProgressIndicator(value: null))
                                : (content?.isEmpty == true && !result.hasException) ? ListView.builder(
                                  controller: homeController,
                                  itemBuilder: (context, index) => 
                                    index == 0 ? _prefixes : NormalEmptyState(),
                                  itemCount: content!.length + 2
                              ) : (content?.isNotEmpty == true) ? ListView.builder(
                                  controller: homeController,
                                  itemBuilder: (context, index) => 
                                    index == 0 ? _prefixes : ContentWidget(content![index-1]),
                                  itemCount: content!.length + 1
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
            backgroundColor: context.theme().brightness == Brightness.light ? context.theme().colorScheme.primary : context.theme().primaryColor,
            selectedItemColor: context.theme().brightness == Brightness.light ? context.theme().colorScheme.onPrimary : context.theme().colorScheme.onSurface,
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
    );
  }
}