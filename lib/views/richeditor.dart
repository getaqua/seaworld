import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_selector/file_selector.dart';
import "package:flutter/material.dart";
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/content.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/main.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/widgets/inappnotif.dart';

class RichEditorPage extends StatefulWidget {
  final String? flow;
  final Content? content;
  final bool isEditing;

  // ignore: prefer_const_constructors_in_immutables
  RichEditorPage({ 
    Key? key,
    this.flow,
    this.content,
    this.isEditing = false
  }) : assert(isEditing ? content != null : true), super(key: key);

  @override
  _RichEditorPageState createState() => _RichEditorPageState();
}

class _RichEditorPageState extends State<RichEditorPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  List<String> _attachments = [];
  List<Uint8List> _pendingAttachments = [];
  bool _posting = false;
  final List<String> enabledFields = ["text"];

  Widget _buildFieldChip({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) => setState(() => enabledFields.contains(value) ? enabledFields.remove(value) : enabledFields.add(value)),
        child: Chip(
          avatar: enabledFields.contains(value) ? Icon(Mdi.close) : Icon(icon),
          label: Text(label, style: TextStyle(color: enabledFields.contains(value) ? Colors.black : null)),
          backgroundColor: enabledFields.contains(value) ? Colors.lightBlue : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    if (widget.content?.text?.isEmpty == true) enabledFields.remove("text");
    _controller.text = widget.content?.text ?? "";
    if (widget.content?.attachments.isNotEmpty == true) enabledFields.add("media");
    _attachments = widget.content?.attachments.map<String>((e) => e.url).toList() ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final _cobs = _controller.obs;
    return Material(
      color: context.theme().backgroundColor, // because I don't know how to use colorScheme
      elevation: 4,
      child: SizedBox(
        width: 720,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text("post.rich.editortitle".tr()),
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (!widget.isEditing) Mutation(
                options: MutationOptions(
                  document: gql(ContentAPI.postContent),
                  onCompleted: (data) {
                    if (data["postContent"] == null) return;
                    _controller.clear();
                    setState(() {_posting = false;});
                    Navigator.pop(context);
                  },
                  onError: (error) {
                    if (error?.graphqlErrors.indexWhere((element) => element.extensions?["code"] == "PERMISSION_DENIED") != -1) {
                      gqlClient.value.query(QueryOptions(document: gql(FlowAPI.getFlow), fetchPolicy: FetchPolicy.cacheOnly, variables: {"id": widget.flow})).then((value) {
                        InAppNotification.showOverlayIn(context, InAppNotification(
                          icon: Icon(Mdi.lock, color: Colors.red),
                          title: Text("error.permissiondenied.title".tr()),
                          text: value.data?["getFlow"]["name"] 
                          ? Text("error.permissiondenied.specific".tr(args: [value.data?["getFlow"]["name"], "permission.post".tr()]))
                          : Text("error.permissiondenied.generic".tr()),
                        ));
                      });
                    } else {
                      InAppNotification.showOverlayIn(context, InAppNotification(
                        icon: Icon(Mdi.uploadOff, color: Colors.red),
                        title: Text("content.post.failed".tr()),
                      ));
                    }
                    setState(() {_posting = false;});
                  }
                ),
                builder: (runMutation, result) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: !_posting ? () async {
                      if (_posting) return;
                      late final bool? _result;
                      if (_pendingAttachments.isNotEmpty) {
                        _result = await showDialog(context: context, builder: (context) => AlertDialog(
                        title: Text("post.rich.submit.pendingattachments.title".tr()),
                        content: Text("post.rich.submit.pendingattachments.message".tr()),
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
                      } else {_result = true;}
                      if (_result != true) return;
                      setState(() {_posting = true;});
                      runMutation({
                        "toFlow": Config.cache.userId,
                        "data": {
                          "text": _controller.value.text,
                          "attachments": _attachments
                        }
                      });
                    } : null,
                    child: !_posting ? Text("post.rich.submit".tr()) : CircularProgressIndicator(value: null)
                  ),
                ),
              ) else Mutation(
                options: MutationOptions(
                  document: gql(ContentAPI.updateContent),
                  onCompleted: (data) {
                    if (data["updateContent"] == null) return;
                    _controller.clear();
                    setState(() {_posting = false;});
                    Navigator.pop(context);
                  },
                  onError: (error) {
                    if (error?.graphqlErrors.indexWhere((element) => element.extensions?["code"] == "PERMISSION_DENIED") != -1) {
                      InAppNotification.showOverlayIn(context, InAppNotification(
                        icon: Icon(Mdi.lock, color: Colors.red),
                        title: Text("error.permissiondenied.title".tr()),
                        text: Text("error.permissiondenied.generic".tr()),
                      ));
                    } else {
                      InAppNotification.showOverlayIn(context, InAppNotification(
                        icon: Icon(Mdi.uploadOff, color: Colors.red),
                        title: Text("content.post.failed".tr()),
                      ));
                    }
                    setState(() {_posting = false;});
                  }
                ),
                builder: (runMutation, result) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: !_posting ? () async {
                      if (_posting) return;
                      setState(() {_posting = true;});
                      runMutation({
                        "id": widget.content!.snowflake, 
                        "data": {
                          "text": _controller.value.text
                        }
                      });
                    } : null,
                    child: !_posting ? Text("post.rich.submit.edit".tr()) : CircularProgressIndicator(value: null)
                  ),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              if (enabledFields.contains("title")) Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "post.rich.title".tr(),
                    border: InputBorder.none
                  ),
                  controller: _titleController,
                  maxLines: null,
                  enabled: !_posting,
                ),
              ),
              if (enabledFields.contains("text")) Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "post.rich.text".tr(),
                    border: InputBorder.none
                  ),
                  controller: _controller,
                  maxLines: null,
                  enabled: !_posting,
                ),
              ),
              if (enabledFields.contains("media")) SizedBox(
                height: 104,
                child: ListView.builder(
                  //padding: const EdgeInsets.all(8.0),
                  scrollDirection: Axis.horizontal,
                  //buildDefaultDragHandles: false,
                  prototypeItem: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Card(
                        child: Material(color: Colors.amber),
                      ),
                    ),
                  ),
                  itemCount: _attachments.length + _pendingAttachments.length,
                  // onReorder: (a, b) {
                  //   // Reordering pending attachments is not allowed.
                  //   if (b >= _attachments.length || a >= _attachments.length) return;
                  //   if (a < b) {b -= 1;}
                  //   _attachments.insert(b, _attachments.removeAt(a));
                  // },
                  itemBuilder: (context, index) {
                    final isPending = (index >= _attachments.length);
                    final dynamic att = isPending ? _pendingAttachments[index-_attachments.length]
                    : _attachments[index];
                    return Padding(
                      key: ValueKey(att),
                      padding: const EdgeInsets.all(4.0),
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: Card(
                          child: isPending ? Image.memory(att, opacity: AlwaysStoppedAnimation(0.7)) 
                          : Image.network(API.get.urlScheme+Config.server+att),
                        ),
                      ),
                    );
                  }
                ),
              ),
              if (enabledFields.contains("media") && !widget.isEditing) Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  icon: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Mdi.upload),
                  ),
                  label: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("post.rich.media.upload".tr()),
                  ),
                  onPressed: () async {
                    var _file = await openFile(acceptedTypeGroups: [XTypeGroup(
                      extensions: [".png", ".jpg", ".jpeg", ".tiff", ".bmp", ".gif"],
                      label: "Images",
                      mimeTypes: ["image/png", "image/jpeg", "image/gif"],
                      webWildCards: ["image/*"]
                    )]);
                    if (_file == null) return;
                    final _bytes = await _file.readAsBytes();
                    _pendingAttachments.add(_bytes);
                    setState(() {});
                    var file = await API.uploadFile(file: _file);
                    if (file?.isOk ?? false) {
                      // Success!
                      _pendingAttachments.remove(_bytes);
                      _attachments.add(file!.data["url"]);
                    } else {
                      // Failure!
                      _pendingAttachments.remove(_bytes);
                      InAppNotification.showOverlayIn(context, InAppNotification(
                        icon: Icon(Mdi.uploadOff, color: Colors.red),
                        title: Text("upload.failed.title".tr()),
                        text: Text("upload.failed.generic".tr()),
                        corner: Corner.bottomStart,
                      ));
                    }
                  }
                )
              ),
              if (!widget.isEditing) SingleChildScrollView(
                child: Row(children: [
                  // The row of field chips
                  _buildFieldChip(icon: Mdi.formatTitle, label: "post.rich.title".tr(), value: "title"),
                  _buildFieldChip(icon: Mdi.text, label: "post.rich.text".tr(), value: "text"),
                  _buildFieldChip(icon: Mdi.imageMultiple, label: "post.rich.media".tr(), value: "media"),
                ]),
              )
            ]),
          ),
        ),
      ),
    );
  }
}