import 'package:adaptive_breakpoints/adaptive_breakpoints.dart';
import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart" hide Flow;
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/breakpoints.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/widgets/content.dart';
import 'package:seaworld/widgets/empty.dart';
import 'package:seaworld/widgets/flowpreview.dart';
import 'package:seaworld/widgets/inappnotif.dart';
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
  //static const int _widthBreakpoint = 872;
  //Future<List<Content>> _content = API.followedContent();
  //List<Content> _lastContent = []; //graphQL cache does this for us now
  //final StreamController<List<Content>> _content = StreamController.broadcast();
  ScrollController drawerScrollController = ScrollController();
  ScrollController scrollController = ScrollController();
  ScrollController memberController = ScrollController();
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
              if (MediaQuery.of(context).size.width < 1088) Builder(
                builder: (context) {
                  final scaffold = Scaffold.of(context);
                  return IconButton(
                    onPressed: () => scaffold.openEndDrawer(),
                    icon: Icon(Mdi.accountMultiple)
                  );
                }
              )
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
                              //   child: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Mdi.arrowLeft)),
                              // ),
                              Expanded(child: Container()),
                              Align(
                                heightFactor: 1,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ProfilePicture(
                                        child: Config.cache.userFlow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+Config.cache.userFlow.avatarUrl!) : null,
                                        size: 48, notchSize: 16,
                                        fallbackChild: FallbackProfilePicture(flow: Config.cache.userFlow)
                                      ),
                                    ),
                                    Text("flow.actor".tr(), style: context.textTheme().overline)
                                  ],
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
                if (flow.myPermissions.update == AllowDeny.allow) ListTile(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
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
                                if (flow.myPermissions.join == AllowDeny.allow && !flow.isJoined) Mutation(
                                  options: MutationOptions(
                                    document: gql(FlowAPI.joinFlow),
                                    onCompleted: (_) => refetch?.call(),
                                    onError: (error) => InAppNotification.showOverlayIn(context, InAppNotification(
                                      corner: Corner.bottomStart,
                                      icon: Icon(Mdi.accountAlert),
                                      title: Text("error.flow.join.title".tr()),
                                      text: Text("error.flow.join.description".tr()),
                                    ))
                                  ),
                                  builder: (runMutation, result) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      onPressed: result?.isLoading ?? false ? null : () => runMutation({"id": flow.snowflake}),
                                      child: Text("flow.join".tr()),
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.black38 : Colors.black),
                                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.black26)
                                      ),
                                    ),
                                  ),
                                )
                                else if (flow.isJoined) Mutation(
                                  options: MutationOptions(
                                    document: gql(FlowAPI.leaveFlow),
                                    onCompleted: (_) => refetch?.call(),
                                    onError: (error) => InAppNotification.showOverlayIn(context, InAppNotification(
                                      corner: Corner.bottomStart,
                                      icon: Icon(Mdi.accountAlert),
                                      title: Text("error.flow.leave.title".tr()),
                                      text: Text("error.flow.leave.description".tr()),
                                    ))
                                  ),
                                  builder: (runMutation, result) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      onPressed: result?.isLoading ?? false ? null : () => runMutation({"id": flow.snowflake}),
                                      child: Text("flow.leave".tr()),
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.black38 : Colors.black),
                                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.black26)
                                      ),
                                    ),
                                  ),
                                ),
                                if (flow.myPermissions.read == AllowDeny.allow && !flow.isFollowing) Mutation(
                                  options: MutationOptions(
                                    document: gql(FlowAPI.followFlow),
                                    onCompleted: (_) => refetch?.call(),
                                    onError: (error) => InAppNotification.showOverlayIn(context, InAppNotification(
                                      corner: Corner.bottomStart,
                                      icon: Icon(Mdi.accountAlert),
                                      title: Text("error.flow.follow.title".tr()),
                                    ))
                                  ),
                                  builder: (runMutation, result) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OutlinedButton(
                                      onPressed: result?.isLoading ?? false ? null : () => runMutation({"id": flow.snowflake}),
                                      child: Text("flow.follow".tr()), 
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.black38 : Colors.black),
                                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.black26)
                                      ),
                                    ),
                                  ),
                                )
                                else if (flow.isFollowing) Mutation(
                                  options: MutationOptions(
                                    document: gql(FlowAPI.unfollowFlow),
                                    onCompleted: (_) => refetch?.call(),
                                    onError: (error) => InAppNotification.showOverlayIn(context, InAppNotification(
                                      corner: Corner.bottomStart,
                                      icon: Icon(Mdi.accountAlert),
                                      title: Text("error.flow.unfollow.title".tr()),
                                    ))
                                  ),
                                  builder: (runMutation, result) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: OutlinedButton(
                                      onPressed: result?.isLoading ?? false ? null : () => runMutation({"id": flow.snowflake}),
                                      child: Text("flow.unfollow".tr()), 
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateColor.resolveWith((states) => states.contains(MaterialState.disabled) ? Colors.black38 : Colors.black),
                                        overlayColor: MaterialStateColor.resolveWith((states) => Colors.black26)
                                      ),
                                    ),
                                  ),
                                )
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
                        ),
                        if (flow.myPermissions.post == AllowDeny.allow) NewContentCard(
                          flow: flow,
                          refreshContent: refetch,
                        )
                      ]);
                      return (flow is! FlowWithContent && result.isLoading) ? Center(child: CircularProgressIndicator(value: null))
                        : (flow is! FlowWithContent) ? SingleChildScrollView(child: _prefixes)
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
                if (MediaQuery.of(context).size.width >= 1088 && (flow as Flow).members.length > 1) Container(
                  width: 320,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: Builder(builder: (c) => _buildMemberList(c, flow))
                )
              ],
            ),
          ),
          endDrawer: Drawer(
            child: Builder(builder: (c) => _buildMemberList(c, flow))
          ),
        );
      }
    );
  }

  Widget _buildMemberList(BuildContext context, PartialFlow flow) {
    return ListView(
      controller: memberController,
      children: [
        if (flow is Flow) for (final member in flow.members) InkWell(
          onTap: () {},
          onTapDown: (details) => FlowPreviewPopupMenu().show(
            context: context, 
            flow: member.member, 
            position: MediaQuery.of(context).size.width > 328+328 
            ? (context.findRenderObject() as RenderBox?)?.localToGlobal(const Offset(0,0))
            : const Offset(16, 16),  
            offset: MediaQuery.of(context).size.width > 328+328 ? Offset(-328, 8) : Offset(0, 0)
          ),
          child: Tooltip(
            message: "flow.showpreview".tr(),
            child: ListTile(
              leading: ProfilePicture(
                child: member.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+member.avatarUrl!) : null,
                size: 48, notchSize: 16,
                fallbackChild: FallbackProfilePicture(flow: member.member)
              ),
              title: Text(flow.name),
              subtitle: Text(flow.id),
            ),
          ),
        )
      ],
    );
  }
}