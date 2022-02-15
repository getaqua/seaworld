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
import 'package:seaworld/views/flow/frame.dart';
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
    return FlowView(
      flow: widget.flow,
      builder: (result, flow, refetch) => Container(
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
                  index == 0 ? _prefixes : ContentWidget(flow.content[index-1]),
                itemCount: flow.content.length + 1
            ) : Center(child: Icon(Mdi.alert, color: Colors.red));
          }
        ),
      ),
    );
  }
}