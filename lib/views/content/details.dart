import 'package:duration/duration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import "package:flutter/material.dart" hide Flow;
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/content.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/main.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/views/crash.dart';
import 'package:seaworld/views/flow/frame.dart';
import 'package:seaworld/views/richeditor.dart';
import 'package:seaworld/widgets/content.dart';
import 'package:seaworld/widgets/empty.dart';
import 'package:seaworld/widgets/flowpreview.dart';
import 'package:seaworld/widgets/inappnotif.dart';
import 'package:seaworld/widgets/pfp.dart';
import 'package:seaworld/widgets/semitransparent.dart';
import 'package:super_scaffold/super_scaffold.dart';

class ContentDetailView extends StatefulWidget {
  final Content content;
  const ContentDetailView({ Key? key, required this.content }) : super(key: key);

  @override
  _ContentDetailViewState createState() => _ContentDetailViewState();
}

class _ContentDetailViewState extends State<ContentDetailView> {
  bool _viewProfilePrompt = false;
  
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(FlowAPI.getFlow),
        variables: {"id": widget.content.inFlowId},
        fetchPolicy: FetchPolicy.cacheFirst
      ),
      builder: (result, {fetchMore, refetch}) => result.isConcrete ? FlowView(
        flow: Flow.fromJSON(result.data!["getFlow"]),
        builder: (result, flow, refetch) => Expanded(
          child: Container(
            //constraints: const BoxConstraints(maxWidth: 720),
            width: 720,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _build(context),
              ],
              body: ListView(),
            ),
          ),
        )
      ) : result.hasException ? Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CrashedView(
          title: "crash.notfound.title".tr(),
          helptext: "crash.notfound.generic".tr(),
          isRenderError: true,
        )
      ) : result.isLoading ? Material(
        color: Colors.black54, 
        child: Center(child: CircularProgressIndicator(value: null)),
      ) : CrashedView(
        title: "crash.notfound.title".tr(),
        helptext: "crash.notfound.generic".tr(),
        retryBack: true,
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(ContentAPI.getContent),
        fetchPolicy: FetchPolicy.cacheFirst,
        optimisticResult: {"getContent": widget.content.toJSON()}
      ),
      builder: (result, {fetchMore, refetch}) {
        // TODO: handle errors
        final Content content = Content.fromJSON(result.data!["getContent"]);
        return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).orientation == Orientation.portrait) Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tooltip(
                        message: "general.back".tr(),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Mdi.arrowLeft)
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Tooltip(
                        message: "flow.menu".tr(),
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: Icon(Mdi.menu)
                        ),
                      ),
                    ),
                  ],
                ),
                Container( // Profile
                  padding: EdgeInsets.only(right: 16.0),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.zero),
                  //   color: context.theme().colorScheme.primaryVariant,
                  // ),
                  child: Row(
                    children: [
                      Tooltip(
                        message: "flow.showpreview".tr(),
                        child: Container(
                          height: 48,
                          width: 48,
                          margin: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Material(
                            borderRadius: BorderRadius.circular(64),
                            color: Colors.transparent,
                            child: Builder(
                              builder: (context) {
                                return InkWell(
                                  onTap: () {},
                                  onTapDown: (details) => FlowPreviewPopupMenu().show(
                                    context: context,
                                    flow: content.author.member,
                                    position: (context.findRenderObject() as RenderBox).localToGlobal(Offset(16, 16))
                                  ),
                                  borderRadius: BorderRadius.circular(64),
                                  onHover: (nv) => setState(() => _viewProfilePrompt = nv),
                                  child: Stack(children: [
                                    Positioned.fill(
                                      child: ProfilePicture(
                                        child: content.author.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+content.author.avatarUrl!) : null,
                                        size: 48, notchSize: 16,
                                        fallbackChild: FallbackProfilePicture(flow: content.author.member)
                                      ),
                                    ),
                                    if (_viewProfilePrompt) ...[
                                      Container(decoration:BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(64))),
                                      Center(child: Icon(Mdi.accountBox, color: Colors.white)),
                                    ],
                                  ])
                                );
                              }
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Tooltip(
                          message: "flow.open".tr(namedArgs: {"id": content.author.member.id}),
                          child: InkWell(
                            onTap: () => context.go("/flow/"+content.author.member.snowflake),
                            child: Padding(
                              padding: EdgeInsets.only(left: 9.0, top: 16.0, bottom: 16.0, right: 16.0),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    Text(content.author.name, style: context.textTheme().subtitle1),
                                    // TODO: badges
                                  ],
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          if (content.yours) PopupMenuItem(
                            child: Text("content.delete".tr(), style: TextStyle(color: Colors.red)),
                            value: "delete"
                          ),
                          if (content.yours) PopupMenuItem(
                            child: Text("content.edit".tr()),
                            value: "edit"
                          )
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case "delete": 
                              (() async {
                                final bool? _result = await showDialog(context: context, builder: (context) => AlertDialog(
                                  title: Text("content.confirmdelete.title".tr()),
                                  content: ContentWidget(content, embedded: true),
                                  actions: [
                                    TextButton(onPressed: () {
                                      Navigator.pop(context, true);
                                      //Navigator.pop(context);
                                    }, child: Text("dialog.yes".tr())),
                                    TextButton(onPressed: () {
                                      Navigator.pop(context, false);
                                      //Navigator.pop(context);
                                    }, child: Text("dialog.no".tr())),
                                  ],
                                ));
                                if (_result != true) return;
                                try {
                                  final _response = await gqlClient.value.mutate(MutationOptions(
                                    document: gql(ContentAPI.deleteContent), 
                                    variables: {"id": content.snowflake}
                                  ));
                                  if (_response.exception?.graphqlErrors.isNotEmpty ?? false || _response.data?["deleteContent"] != true) {
                                    InAppNotification.showOverlayIn(context, InAppNotification(
                                      title: Text("content.deletefailed.title".tr()),
                                      text: Text("content.deletefailed.message".tr()),
                                      icon: Icon(Mdi.alertCircleOutline, color: Colors.red),
                                      corner: Corner.bottomStart
                                    ));
                                  } else {
                                    InAppNotification.showOverlayIn(context, InAppNotification(
                                      title: Text("content.deletesuccess.title".tr()),
                                      icon: Icon(Mdi.check, color: Colors.green),
                                      corner: Corner.bottomStart
                                    ));
                                    context.pop();
                                  }
                                } catch(e) {
                                  InAppNotification.showOverlayIn(context, InAppNotification(
                                    title: Text("crash.connectionerror.title".tr()),
                                    text: Text("content.deletefailed.title".tr()),
                                    icon: Icon(Mdi.lightningBolt, color: Colors.red),
                                    corner: Corner.bottomStart
                                  ));
                                }
                                //Navigator.pop(context);x  x
                              })();
                              return;
                            case "edit":
                              //spawn the edit screen, prefill it, set it to an edit mode
                              (() async {
                                await Navigator.push(context, SemiTransparentPageRoute(builder: (context) => Container(
                                  alignment: Alignment.topCenter,
                                  width: 720,
                                  child: RichEditorPage(content: content, isEditing: true))
                                ));
                              })();
                              
                              return;
                            default:
                              return;
                          }
                        }
                      )
                    ]
                  ),
                ),
                if (content.text?.isNotEmpty == true) Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(content.text!),
                ),
                Builder(
                  builder: (context) {
                    var dtF = DateFormat.yMd(context.locale.toStringWithSeparator());
                    if (MediaQuery.of(context).alwaysUse24HourFormat) {
                      dtF = dtF.add_Hm();
                    } else {
                      dtF = dtF.add_jm();
                    }
                    return _buildDetailRow(
                      icon: Tooltip(
                        child: Icon(Mdi.clockOutline),
                        message: "content.titles.timestamp".tr(),
                      ),
                      text: Text(dtF.format(content.timestamp.toLocal()))
                    );
                  }
                ),
                if (content.isEdited) Builder(
                  builder: (context) {
                    var dtF = DateFormat.yMd(context.locale.toStringWithSeparator());
                    if (MediaQuery.of(context).alwaysUse24HourFormat) {
                      dtF = dtF.add_Hm();
                    } else {
                      dtF = dtF.add_jm();
                    }
                    return _buildDetailRow(
                      icon: Tooltip(
                        child: Icon(Mdi.pencilCircleOutline),
                        message: "content.titles.edited".tr(),
                      ),
                      text: Text(dtF.format(content.editedTimestamp!.toLocal()))
                    );
                  }
                ),
              ],
            )
        );
      }
    );
  }

  Widget _buildDetailRow({required Widget icon, required Widget text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconTheme(
          data: IconThemeData(color: Theme.of(context).disabledColor),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: icon,
          ),
        ),
        DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Theme.of(context).disabledColor),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: text,
          ),
        ),
      ],
    );
  }
}