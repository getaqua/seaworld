import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/main.dart';
import 'package:seaworld/widgets/inappnotif.dart';

class NewFlowModal extends StatefulWidget {
  const NewFlowModal({ Key? key }) : super(key: key);

  @override
  State<NewFlowModal> createState() => _NewFlowModalState();
}

class _NewFlowModalState extends State<NewFlowModal> {
  NewFlowPreset _selectedPreset = NewFlowPreset.channel;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String? _idError;
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("flow.new.title".tr(), style: context.textTheme().headline6),
          ),
          SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                enabled: !_isPosting,
                decoration: InputDecoration(
                  isDense: false,
                  border: OutlineInputBorder(),
                  labelText: "flow.new.name".tr()
                ),
              ),
            ),
          ),
          SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _idController,
                enabled: !_isPosting,
                decoration: InputDecoration(
                  isDense: false,
                  border: OutlineInputBorder(),
                  labelText: "flow.new.id".tr()+" *",
                  prefixText: "//",
                  helperText: "flow.new.validate_id.hint".tr(),
                  helperMaxLines: 2,
                  errorText: _idError,
                  errorMaxLines: 3,
                ),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isNotEmpty && newValue.text.endsWith(" ")) {
                      return newValue.copyWith(text: newValue.text.replaceFirst(" ", "_"));
                    } else {
                      return newValue;
                    }
                  }),
                  FilteringTextInputFormatter(RegExp(r"[a-zA-Z0-9*!#@._\-+=,\/]*"), allow: true)
                ],
                onChanged: (value) {
                  setState(() => _idError = _validateId(value)?.tr());
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 360,
              child: Scrollbar(
                controller: _scrollController,
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      _buildPreset(context, 
                        id: NewFlowPreset.channel,
                        color: Colors.teal,
                        icon: Icon(Mdi.radioTower),
                        title: Text("flow.new.channel.title".tr()),
                        text: Text("flow.new.channel.description".tr()),
                        explanation: Text("flow.new.channel.explanation".tr()),
                      ),
                      _buildPreset(context, 
                        id: NewFlowPreset.community,
                        color: Colors.green,
                        icon: Icon(Mdi.earth),
                        title: Text("flow.new.community.title".tr()),
                        text: Text("flow.new.community.description".tr()),
                        explanation: Text("flow.new.community.explanation".tr()),
                      ),
                      _buildPreset(context, 
                        id: NewFlowPreset.private_group,
                        color: Colors.red,
                        icon: Icon(Mdi.lockOutline),
                        title: Text("flow.new.private_group.title".tr()),
                        text: Text("flow.new.private_group.description".tr()),
                        explanation: Text("flow.new.private_group.explanation".tr()),
                      ),
                      _buildPreset(context, 
                        id: NewFlowPreset.story,
                        color: Colors.pink,
                        icon: Icon(Mdi.cellphone),
                        title: Text("flow.new.story.title".tr()),
                        text: Text("flow.new.story.description".tr()),
                        explanation: Text("flow.new.story.explanation".tr()),
                      ),
                      _buildPreset(context, 
                        id: NewFlowPreset.anonymous_group,
                        color: Colors.orange,
                        icon: Icon(Mdi.incognito),
                        title: Text("flow.new.anonymous_group.title".tr()),
                        text: Text("flow.new.anonymous_group.description".tr()),
                        explanation: Text("flow.new.anonymous_group.explanation".tr()),
                      ),
                      _buildPreset(context, 
                        id: NewFlowPreset.blog,
                        color: Colors.blue,
                        icon: Icon(Mdi.post),
                        title: Text("flow.new.blog.title".tr()),
                        text: Text("flow.new.blog.description".tr()),
                        explanation: Text("flow.new.blog.explanation".tr()),
                      ),
                      _buildPreset(context, 
                        id: NewFlowPreset.collection,
                        color: Colors.brown,
                        icon: Icon(Mdi.pound),
                        title: Text("flow.new.collection.title".tr()),
                        text: Text("flow.new.collection.description".tr()),
                        explanation: Text("flow.new.collection.explanation".tr()),
                      )
                    ]),
                  )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: _isPosting ? null : () => Navigator.pop(context), child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("dialog.cancel".tr()),
                )),
                OutlinedButton(onPressed: _isPosting ? null : () async {
                  setState(() => _idError = _validateId()?.tr()); if (_idError != null) return;
                  setState(() => _isPosting = true);
                  final result = await gqlClient.value.mutate(MutationOptions(
                    document: gql(FlowAPI.createFlow),
                    fetchPolicy: FetchPolicy.networkOnly,
                    variables: {
                      "flow": {
                        "preset": _selectedPreset.name,
                        "name": _nameController.value.text.isEmpty
                          ? _idController.value.text
                          : _nameController.value.text,
                        "id": _idController.value.text
                      },
                      "parentId": Config.cache.userFlow.snowflake
                    }
                  ));
                  if (result.hasException) {
                    setState(() => _isPosting = false);
                    if (result.exception!.graphqlErrors.isNotEmpty && result.exception!.graphqlErrors.first.message.toLowerCase().contains(" id ")) {
                      setState(() {
                        _idError = result.exception!.graphqlErrors.first.message;
                      });
                    } else {
                      InAppNotification.showOverlayIn(context, InAppNotification(
                        icon: Icon(Mdi.alertCircle, color: Colors.red),
                        title: Text("flow.create.failed".tr()),
                        text: Text(
                          result.exception?.linkException?.toString()
                          ?? result.exception?.graphqlErrors.first.message
                          ?? "No exception"
                        ),
                        corner: Corner.bottomStart,
                      ));
                    }
                  } else {
                    Navigator.pop<String>(context, result.data!["createFlow"]["snowflake"]);
                  }
                }, child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text("flow.new.create".tr()),
                ))
              ],
            ),
          )
        ],
      ),
    );
  }

  static final _usernameRequirements = RegExp(r"^[a-zA-Z0-9*!#@._\-+=,\/]{3,}$");
  String? _validateId([String? invalue]) {
    final value = invalue ?? _idController.value.text;
    if (!_usernameRequirements.hasMatch(value)) return "flow.new.validate_id.invalid";
    if (value.contains("//")) return "flow.new.validate_id.double_slashes";
    if (value.contains("/#/")) return "flow.new.validate_id.private_sequence";
    if (value.contains("/+/")) return "flow.new.validate_id.private_sequence";
  }

  Widget _buildPreset(BuildContext context, {
    required NewFlowPreset id,
    bool enabled = true,
    MaterialColor color = Colors.grey,
    Widget title = const Text("flow.new.undefined.title"),
    Widget text = const Text("flow.new.undefined.description"),
    Widget? explanation,
    Widget icon = const Icon(Icons.e_mobiledata)
  }) {
    return Container(
      width: 128,
      padding: EdgeInsets.all(4.0),
      foregroundDecoration: _selectedPreset == id ? BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.shade400, width: 4)
      ) : null,
      child: Material(
        color: context.theme().brightness == Brightness.light ? color.shade100 : color.shade900,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: enabled ? () => setState(() => _selectedPreset = id) : null,
          onLongPress: () => showDialog(context: context, builder: (_) => AlertDialog(
            title: title,
            content: explanation ?? text,
            actions: [TextButton(onPressed: _isPosting ? null : () => Navigator.pop(context), child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("dialog.cancel".tr()),
            ))],
          )),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconTheme(data: IconThemeData(color: color.shade500), child: icon),
                  ),
                  DefaultTextStyle(
                    style: context.textTheme().bodyText2!.copyWith(fontWeight: FontWeight.bold, color: color.shade500),
                    softWrap: true,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    child: title
                  ),
                  DefaultTextStyle(
                    style: context.textTheme().bodyText2!.copyWith(color: color.shade500),
                    softWrap: true,
                    maxLines: null,
                    textAlign: TextAlign.center,
                    child: text
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum NewFlowPreset {
  community,
  // ignore: constant_identifier_names
  private_group,
  story,
  channel,
  // ignore: constant_identifier_names
  anonymous_group,
  blog,
  collection
}