import 'package:easy_localization/easy_localization.dart';
import 'package:file_selector/file_selector.dart';
import "package:flutter/material.dart" hide Flow;
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/widgets/inappnotif.dart';
import 'package:seaworld/widgets/pfp.dart';

class EditFlowProfilePage extends StatefulWidget {
  final Flow flow;
  final Function()? refetch;
  const EditFlowProfilePage({ Key? key, required this.flow, this.refetch }) : super(key: key);

  @override
  State<EditFlowProfilePage> createState() => _EditFlowProfilePageState();
}

class _EditFlowProfilePageState extends State<EditFlowProfilePage> {
  bool _hoveringBanner = false;
  bool _hoveringAvatar = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.flow.name;
    descriptionController.text = widget.flow.description ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Flex(
            direction: MediaQuery.of(context).size.width >= 720 ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Mutation( // Banner
                      options: MutationOptions(
                        document: gql(FlowAPI.updateFlow),
                        onCompleted: (_) {
                          widget.refetch?.call();
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.check, color: Colors.green),
                            title: Text("upload.success.banner.title".tr()),
                            corner: Corner.bottomStart,
                          ));
                        },
                        onError: (error) {
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.uploadOff, color: Colors.red),
                            title: Text("flow.update.failed".tr()),
                            corner: Corner.bottomStart,
                          ));
                        }
                      ),
                      builder: (runMutation, result) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Tooltip(
                                message: "flow.update.banner".tr(),
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hoveringBanner = true),
                                  onExit: (_) => setState(() => _hoveringBanner = false),
                                  child: GestureDetector(
                                    onTap: () async {
                                      var file = await API.uploadFile(file: await openFile());
                                      if (RespEx(file)?.isOk ?? false) {
                                        runMutation({
                                          "id": widget.flow.snowflake,
                                          "data": {
                                            "bannerUrl": file!.data["url"]
                                          }
                                        });
                                      } else {
                                        // Failure!
                                        InAppNotification.showOverlayIn(context, InAppNotification(
                                          icon: Icon(Mdi.uploadOff, color: Colors.red),
                                          title: Text("upload.failed.title".tr()),
                                          text: Text("upload.failed.generic".tr()),
                                          corner: Corner.bottomStart,
                                        ));
                                      }
                                    },
                                    child: SizedBox(
                                      height: 128,
                                      width: 256,
                                      child: Stack(children: [
                                        Positioned.fill(child: widget.flow.bannerUrl != null && widget.flow.bannerUrl != "" ? Image.network(
                                          API.get.urlScheme+Config.server+widget.flow.bannerUrl!,
                                          fit: BoxFit.cover
                                        ) : Container(
                                          alignment: Alignment.center,
                                          color: Theme.of(context).colorScheme.surface
                                        )),
                                        if (_hoveringBanner) ...[
                                          Container(decoration:BoxDecoration(color: Colors.black54)),
                                          Center(child: Icon(Mdi.imagePlus, color: Colors.white)),
                                        ],
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () => runMutation({
                                  "id": widget.flow.snowflake,
                                  "data": {
                                    "bannerUrl": null
                                  }
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text("flow.update.remove_banner".tr()),
                                )
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                    Mutation( // Avatar
                      options: MutationOptions(
                        document: gql(FlowAPI.updateFlow),
                        onCompleted: (_) {
                          widget.refetch?.call();
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.check, color: Colors.green),
                            title: Text("upload.success.avatar.title".tr()),
                            corner: Corner.bottomStart,
                          ));
                        },
                        onError: (error) {
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.uploadOff, color: Colors.red),
                            title: Text("flow.update.failed".tr()),
                            corner: Corner.bottomStart,
                          ));
                        }
                      ),
                      builder: (runMutation, result) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(72),
                              child: Tooltip(
                                message: "flow.update.avatar".tr(),
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hoveringAvatar = true),
                                  onExit: (_) => setState(() => _hoveringAvatar = false),
                                  child: GestureDetector(
                                    onTap: () async {
                                      var file = await API.uploadFile(file: await openFile());
                                      if (file?.isOk ?? false) {
                                        runMutation({
                                          "id": widget.flow.snowflake,
                                          "data": {
                                            "avatarUrl": file!.data["url"]
                                          }
                                        });
                                      } else {
                                        // Failure!
                                        InAppNotification.showOverlayIn(context, InAppNotification(
                                          icon: Icon(Mdi.uploadOff, color: Colors.red),
                                          title: Text("upload.failed.title".tr()),
                                          text: Text("upload.failed.generic".tr()),
                                          corner: Corner.bottomStart,
                                        ));
                                      }
                                    },
                                    child: SizedBox(
                                      height: 72,
                                      width: 72,
                                      child: Stack(children: [
                                        Positioned.fill(child: widget.flow.avatarUrl != null && widget.flow.avatarUrl != "" ? Image.network(
                                          API.get.urlScheme+Config.server+widget.flow.avatarUrl!,
                                          fit: BoxFit.cover
                                        ) : FallbackProfilePicture(flow: widget.flow)),
                                        if (_hoveringAvatar) ...[
                                          Container(decoration:BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(64))),
                                          Center(child: Icon(Mdi.imagePlus, color: Colors.white)),
                                        ],
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () => runMutation({
                                  "id": widget.flow.snowflake,
                                  "data": {
                                    "avatarUrl": null
                                  }
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text("flow.update.remove_avatar".tr()),
                                )
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: MediaQuery.of(context).size.width >= 720 ? 1 : 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Mutation(
                        options: MutationOptions(
                          document: gql(FlowAPI.updateFlow),
                          onCompleted: (_) {
                            widget.refetch?.call();
                            InAppNotification.showOverlayIn(context, InAppNotification(
                              icon: Icon(Mdi.check, color: Colors.green),
                              title: Text("flow.update.success".tr()),
                              corner: Corner.bottomStart,
                            ));
                          },
                          onError: (error) {
                            InAppNotification.showOverlayIn(context, InAppNotification(
                              icon: Icon(Mdi.uploadOff, color: Colors.red),
                              title: Text("flow.update.failed".tr()),
                              corner: Corner.bottomStart,
                            ));
                          }
                        ),
                        builder: (runMutation, result) => TextField(
                          controller: nameController,
                          onSubmitted: (value) => runMutation({
                            "id": widget.flow.snowflake,
                            "data": {
                              "name": value
                            }
                          }),
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: IconButton(onPressed: () => runMutation({
                                "id": widget.flow.snowflake,
                                "data": {
                                  "name": nameController.value.text
                                }
                              }), icon: Icon(Mdi.check)),
                            ),
                            labelText: "flow.update.name".tr()
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Mutation(
                        options: MutationOptions(
                          document: gql(FlowAPI.updateFlow),
                          onCompleted: (_) {
                            InAppNotification.showOverlayIn(context, InAppNotification(
                              icon: Icon(Mdi.check, color: Colors.green),
                              title: Text("flow.update.success".tr()),
                              corner: Corner.bottomStart,
                            ));
                          },
                          onError: (error) {
                            InAppNotification.showOverlayIn(context, InAppNotification(
                              icon: Icon(Mdi.uploadOff, color: Colors.red),
                              title: Text("flow.update.failed".tr()),
                              corner: Corner.bottomStart,
                            ));
                          }
                        ),
                        builder: (runMutation, result) => TextField(
                          controller: descriptionController,
                          onSubmitted: (value) => runMutation({
                            "id": widget.flow.snowflake,
                            "data": {
                              "description": value
                            }
                          }),
                          maxLines: null,
                          decoration: InputDecoration(
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: IconButton(
                                onPressed: () => runMutation({
                                  "id": widget.flow.snowflake,
                                  "data": {
                                    "description": descriptionController.value.text
                                  }
                                }), 
                                icon: Icon(Mdi.check)
                              ),
                            ),
                            labelText: "flow.update.description".tr()
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        )
      )
    );
  }
}