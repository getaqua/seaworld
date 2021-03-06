import 'package:easy_localization/easy_localization.dart';
import 'package:file_selector/file_selector.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/content.dart';
import "package:seaworld/helpers/extensions.dart";
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/views/richeditor.dart';
import 'package:seaworld/widgets/inappnotif.dart';
import 'package:seaworld/widgets/pfp.dart';
import 'package:seaworld/widgets/semitransparent.dart';

class NewContentCard extends StatefulWidget {
  final PartialFlow? flow;
  final void Function()? refreshContent;

  const NewContentCard({
    Key? key,
    this.flow,
    this.refreshContent
  }) : super(key: key);

  @override
  State<NewContentCard> createState() => _NewContentCardState();
}

class _NewContentCardState extends State<NewContentCard> {
  final TextEditingController _controller = TextEditingController();

  bool _posting = false;

  @override
  Widget build(BuildContext context) {
    final _cobs = _controller;
    return Card(
      child: Column(
        children: [
          Container( // Profile
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (widget.flow?.myPermissions.anonymous == AllowDeny.force) Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ProfilePicture(
                    child: widget.flow!.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+widget.flow!.avatarUrl!) : null,
                    size: 48, notchSize: 12,
                    fallbackChild: FallbackProfilePicture(flow: widget.flow)
                  ),
                ) else Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ProfilePicture(
                    child: Config.cache.userFlow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+Config.cache.userFlow.avatarUrl!) : null,
                    size: 48, notchSize: 12,
                    fallbackChild: FallbackProfilePicture(flow: Config.cache.userFlow)
                  ),
                ),
                Column(
                  children: [
                    if (widget.flow?.myPermissions.anonymous == AllowDeny.force) Text(widget.flow!.name, style: context.textTheme().subtitle1)
                    else Text(Config.cache.userFlow.name, style: context.textTheme().subtitle1),
                    if (widget.flow == null || widget.flow!.snowflake == Config.cache.userFlow.snowflake) 
                      Text(Config.cache.userFlow.id + " ??? " + "post.target.profile".tr(), style: context.textTheme().caption)
                    else if (widget.flow?.myPermissions.anonymous == AllowDeny.force) Text(widget.flow!.id + " ??? " + "post.target.flow_anonymous".tr(), style: context.textTheme().caption)
                    else Text(Config.cache.userFlow.id + " ??? " + "post.target.flow".tr(namedArgs: {"flow": widget.flow!.name}), style: context.textTheme().caption)
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
                Expanded(child: Container()),
                if (widget.flow == null) Tooltip(
                  message: "flow.update.yours".tr(),
                  child: IconButton(onPressed: () => context.push("/flow/${Config.cache.userFlow.snowflake}/settings", extra: Config.cache.userFlow), icon: Icon(Mdi.accountEdit)),
                )
              ]
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.topLeft,
            child: TextField(
              decoration: InputDecoration(
                hintText: "post.newtext".tr(),
                border: InputBorder.none
              ),
              controller: _controller,
              maxLines: null,
              enabled: !_posting,
              //onChanged: (_) => ((_) => _controller),
            )
          ),
          Divider(),
          Mutation(
            options: MutationOptions(
              document: gql(ContentAPI.postContent),
              onCompleted: (_) {
                _posting = false;
                _controller.clear();
                // The following hack calls refreshContent if it exists,
                // and otherwise calls a void function.
                setState(() {});
                (widget.refreshContent ?? (() => {}))();
              },
              onError: (error) {
                setState(() => _posting = false);
                InAppNotification.showOverlayIn(context, InAppNotification(
                  icon: Icon(Mdi.uploadOff, color: Colors.red),
                  title: Text("content.post.failed".tr()),
                  corner: Corner.bottomStart,
                ));
              }
            ),
            builder: (runMutation, result) => Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: "post.newimage".tr(),
                    child: IconButton(onPressed: () async {
                      if (_posting) return;
                      setState(() => _posting = true);
                      var file = await API.uploadFile(file: await openFile(acceptedTypeGroups: [XTypeGroup(
                        extensions: [".png", ".jpg", ".jpeg", ".tiff", ".bmp", ".gif"],
                        label: "Images",
                        mimeTypes: ["image/png", "image/jpeg", "image/gif"],
                        webWildCards: ["image/*"]
                      )]));
                      if (file?.isOk ?? false) {
                        runMutation({
                          "id": widget.flow?.snowflake ?? Config.cache.userId,
                          "data": {
                            "attachments": [file?.data["url"]],
                            if (_controller.value.text.isNotEmpty) "text": _controller.value.text
                          }
                        });
                      } else {
                        // Failure!
                        setState(() => _posting = false);
                        InAppNotification.showOverlayIn(context, InAppNotification(
                          icon: Icon(Mdi.uploadOff, color: Colors.red),
                          title: Text("upload.failed.title".tr()),
                          text: Text("upload.failed.generic".tr()),
                          corner: Corner.bottomStart,
                        ));
                      }
                    }, icon: Icon(Mdi.image), color: Colors.amber)
                  ),
                  Tooltip(
                    message: "post.newpoll".tr(),
                    child: IconButton(onPressed: null, icon: Icon(Mdi.pollBox))
                  ),
                  Tooltip(
                    message: "post.uploadfile".tr(),
                    child: IconButton(onPressed: () async {
                      if (_posting) return;
                      setState(() => _posting = true);
                      var file = await API.uploadFile(file: await openFile());
                      if (file?.isOk ?? false) {
                        runMutation({
                          "id": widget.flow?.snowflake ?? Config.cache.userId,
                          "data": {
                            "attachments": [file?.data["url"]],
                            if (_controller.value.text.isNotEmpty) "text": _controller.value.text
                          }
                        });
                      } else {
                        // Failure!
                        setState(() => _posting = false);
                        InAppNotification.showOverlayIn(context, InAppNotification(
                          icon: Icon(Mdi.uploadOff, color: Colors.red),
                          title: Text("upload.failed.title".tr()),
                          text: Text("upload.failed.generic".tr()),
                          corner: Corner.bottomStart,
                        ));
                      }
                    }, icon: Icon(Mdi.file), color: Colors.pink)
                  ),
                  Tooltip(
                    message: "post.newevent".tr(),
                    child: IconButton(onPressed: null, icon: Icon(Mdi.calendar))
                  ),
                  _posting ? CircularProgressIndicator(value: null)
                  : AnimatedBuilder(animation: _controller, builder: (context, _) => 
                    _cobs.value.text == "" ? Tooltip(
                      message: "post.expand".tr(),
                      child: IconButton(onPressed: () async {
                        await Navigator.push(context, SemiTransparentPageRoute(builder: (context) => Container(
                          alignment: Alignment.topCenter,
                          width: 720,
                          child: RichEditorPage(flow: widget.flow?.snowflake, permissions: widget.flow?.myPermissions))
                        ));
                        (widget.refreshContent ?? (() => {}))();
                      }, icon: Icon(Mdi.cardBulleted), color: context.theme().colorScheme.primary)
                    ) : Tooltip(
                      message: "post.send".tr(),
                      child: IconButton(
                        onPressed: !_posting ? () async {
                          setState(() => _posting = true);
                          runMutation({
                            "id": widget.flow?.snowflake ?? Config.cache.userId,
                            "data": {
                              "text": _controller.value.text
                            }
                          });
                        } : null,
                        icon: Icon(Mdi.send),
                        color: context.theme().colorScheme.primary,
                      )
                    )
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}