import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
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

class FlowView extends StatefulWidget {
  final PartialFlow flow;
  final Widget Function(QueryResult result, PartialFlow flow, void Function()? refetch) builder;
  const FlowView({
    Key? key, required this.flow, required this.builder
  }) : super(key: key);
  @override
  _FlowViewState createState() => _FlowViewState();
}

class _FlowViewState extends State<FlowView> {
  //static const int _widthBreakpoint = 872;
  //Future<List<Content>> _content = API.followedContent();
  //List<Content> _lastContent = []; //graphQL cache does this for us now
  //final StreamController<List<Content>> _content = StreamController.broadcast();
  ScrollController drawerScrollController = ScrollController();
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
                  selected: GoRouter.of(context).location == "/flow/"+flow.snowflake,
                  onTap: () => context.go("/flow/"+flow.snowflake),
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
                Builder(builder: (context) => widget.builder(result, flow, refetch)),
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