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
          drawer: Drawer(
            child: CustomScrollView(
              controller: drawerScrollController,
              slivers: [
                Theme(
                  data: Theme.of(context).copyWith(dividerTheme: DividerThemeData(thickness: 0, space: 0, color: Colors.transparent)),
                  child: SliverToBoxAdapter(
                    child: Material(
                      color: context.theme().colorScheme.secondary,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                      child: DrawerHeader(
                        margin: EdgeInsets.zero,
                        decoration: flow.bannerUrl?.isNotEmpty == true ? BoxDecoration(
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                          image: DecorationImage(
                            image: NetworkImage(API.get.urlScheme+Config.server+flow.bannerUrl!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken)
                          ),
                        ) : null,
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
                                          child: flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+flow.avatarUrl!) : null,
                                          size: 48, notchSize: 16,
                                          fallbackChild: FallbackProfilePicture(flow: flow)
                                        ),
                                      ),
                                      Text("flow.youarein".tr(), style: context.textTheme().overline)
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
                                            flow.name, 
                                            style: context.textTheme().headline6,
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            flow.id,
                                            style: context.textTheme().caption,
                                            maxLines: 1,
                                            overflow: TextOverflow.fade,
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Expanded(child: Container()),
                                    // Padding(
                                    //   padding: const EdgeInsets.all(4.0),
                                    //   child: Icon(Mdi.chevronDown),
                                    // )
                                  ],
                                )
                                // The user's name and ID
                              ],
                              //mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                            ),
                            Builder(
                              builder: (context) {
                                return Positioned(
                                  top: -8, left: -8,
                                  child: IconButton(
                                    icon: Icon(Mdi.arrowLeft),
                                    onPressed: () {
                                      if (Scaffold.maybeOf(context)?.isDrawerOpen == true) Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  )
                                );
                              }
                            ),
                            // Positioned(
                            //   top: -8, right: -8,
                            //   child: IconButton(
                            //     icon: Icon(Mdi.weatherLightning),
                            //     onPressed: null
                            //   )
                            // )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ListTileTheme(
                  iconColor: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.6),
                  textColor: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.6),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  style: ListTileStyle.drawer,
                  child: SliverList(delegate: SliverChildListDelegate([
                    ListTile(
                      selected: GoRouter.of(context).location == "/flow/"+flow.snowflake,
                      onTap: () => context.go("/flow/"+flow.snowflake),
                      title: Text("flow.feature.home".tr()),
                      leading: Icon(Mdi.home),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                    ListTile(
                      onTap: () {},
                      // Use this and subtitle style for events
                      iconColor: Theme.of(context).colorScheme.secondary,
                      title: Text("Placeholder page",),
                      subtitle: Text("There's an event in here!",
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      leading: Icon(Mdi.oneUp),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                    ListTile(
                      onTap: () {},
                      // Use these two styles to help indicate new messages
                      textColor: Theme.of(context).textTheme.bodyText2?.color,
                      iconColor: Theme.of(context).textTheme.bodyText2?.color,
                      title: Text("flow.feature.chat".tr()),
                      leading: Icon(Mdi.poundBoxOutline),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                    ListTile(
                      onTap: () {},
                      leading: Icon(null),
                      title: Text("Placeholder page #2"),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                    if (flow.myPermissions.update == AllowDeny.allow) ListTile(
                      onTap: () => context.go("/flow/"+flow.snowflake+"/settings", extra: flow),
                      title: Text("flow.feature.settings".tr()),
                      leading: Icon(Mdi.cog),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                  ])),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PopupMenuButton(
                              child: ProfilePicture(
                                child: Config.cache.userFlow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+Config.cache.userFlow.avatarUrl!) : null,
                                size: 36, notchSize: 12,
                                fallbackChild: FallbackProfilePicture(flow: flow)
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  padding: EdgeInsets.zero,
                                  enabled: false,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      // TODO: open member profile editing screen
                                    },
                                    leading: Icon(Mdi.accountEditOutline),
                                    title: Text("flow.editme".tr()),
                                  )
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Config.cache.userFlow.name),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ]
                  ),
                )
              ]
            )
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
            position: MediaQuery.of(context).size.width > 328*2
            ? (context.findRenderObject() as RenderBox?)?.localToGlobal(const Offset(0,0))
            : const Offset(16, 16),  
            offset: MediaQuery.of(context).size.width > 328*2 ? Offset(-328, 8) : Offset(0, 0)
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