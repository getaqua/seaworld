import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';

class RichEditorPage extends StatefulWidget {
  final String? flow;

  RichEditorPage({ 
    Key? key,
    this.flow
  }) : super(key: key);

  @override
  _RichEditorPageState createState() => _RichEditorPageState();
}

class _RichEditorPageState extends State<RichEditorPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
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
          label: Text(label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final _cobs = _controller.obs;
    return Material(
      color: Get.theme.backgroundColor, // because I don't know how to use colorScheme
      elevation: 4,
      child: SizedBox(
        width: 720,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text("post.rich.editortitle".tr),
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: !_posting ? () async {
                    if (_posting) return;
                    setState(() {_posting = true;});
                    var resp = await API.postContent(toFlow: Config.cache.userId, text: _controller.value.text);
                    if (resp.isOk && resp.body["postContent"] != null) {
                      _controller.clear();
                      setState(() {_posting = false;});
                      Get.back();
                    }
                  } : null,
                  child: !_posting ? Text("post.rich.submit".tr) : CircularProgressIndicator(value: null)
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
                    labelText: "post.rich.title".tr,
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
                    hintText: "post.rich.text".tr,
                    border: InputBorder.none
                  ),
                  controller: _controller,
                  maxLines: null,
                  enabled: !_posting,
                ),
              ),
              SingleChildScrollView(
                child: Row(children: [
                  // The row of field chips
                  _buildFieldChip(icon: Mdi.formatTitle, label: "post.rich.title".tr, value: "title"),
                  _buildFieldChip(icon: Mdi.text, label: "post.rich.text".tr, value: "text"),
                  Chip(
                    avatar: Icon(Mdi.imageMultiple),
                    label: Text("post.rich.media".tr),
                  ),
                ]),
              )
              // TODO: add image attachments
            ]),
          ),
        ),
      ),
    );
  }
}