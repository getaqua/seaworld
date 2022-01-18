import 'package:file_selector/file_selector.dart';
import "package:flutter/material.dart" hide Flow;
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/widgets/inappnotif.dart';
import 'package:seaworld/widgets/pfp.dart';

class EditFlowProfilePage extends StatefulWidget {
  final Flow flow;
  const EditFlowProfilePage({ Key? key, required this.flow }) : super(key: key);

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
            direction: MediaQuery.of(context).size.width >= 640 ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: -1,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Tooltip(
                                message: "flow.update.banner".tr,
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hoveringBanner = true),
                                  onExit: (_) => setState(() => _hoveringBanner = false),
                                  child: GestureDetector(
                                    onTap: () async {
                                      var file = await API.uploadFile(file: await openFile());
                                      if (file?.isOk ?? false) {
                                        var resp = await API.updateFlow(
                                          id: widget.flow.snowflake,
                                          bannerUrl: file?.body["url"],
                                        );
                                        if (resp.isOk && resp.body["updateFlow"] != null) {
                                          // Success
                                          InAppNotification.showOverlayIn(context, InAppNotification(
                                            icon: Icon(Mdi.check, color: Colors.green),
                                            title: Text("upload.success.banner.title".tr),
                                            corner: Corner.bottomStart,
                                          ));
                                        }
                                      } else {
                                        // Failure!
                                        InAppNotification.showOverlayIn(context, InAppNotification(
                                          icon: Icon(Mdi.uploadOff, color: Colors.red),
                                          title: Text("upload.failed.title".tr),
                                          text: Text("upload.failed.generic".tr),
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
                                onPressed: () async {
                                  var resp = await API.updateFlow(
                                    id: widget.flow.snowflake,
                                    bannerUrl: null,
                                  );
                                  if (resp.isOk && resp.body["updateFlow"] != null) {
                                    // Success
                                    InAppNotification.showOverlayIn(context, InAppNotification(
                                      icon: Icon(Mdi.check, color: Colors.green),
                                      title: Text("flow.update.success".tr),
                                      corner: Corner.bottomStart,
                                    ));
                                  } else {
                                    // Failure!
                                    InAppNotification.showOverlayIn(context, InAppNotification(
                                      icon: Icon(Mdi.alertCircle, color: Colors.red),
                                      title: Text("flow.update.failed".tr),
                                      corner: Corner.bottomStart,
                                    ));
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text("flow.update.banner.remove".tr),
                                )
                              ),
                            )
                          ],
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(72),
                              child: Tooltip(
                                message: "flow.update.avatar".tr,
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hoveringAvatar = true),
                                  onExit: (_) => setState(() => _hoveringAvatar = false),
                                  child: GestureDetector(
                                    onTap: () async {
                                      var file = await API.uploadFile(file: await openFile());
                                      if (file?.isOk ?? false) {
                                        var resp = await API.updateFlow(
                                          id: widget.flow.snowflake,
                                          avatarUrl: file?.body["url"],
                                        );
                                        if (resp.isOk && resp.body["updateFlow"] != null) {
                                          // Success
                                          InAppNotification.showOverlayIn(context, InAppNotification(
                                            icon: Icon(Mdi.check, color: Colors.green),
                                            title: Text("upload.success.avatar.title".tr),
                                            corner: Corner.bottomStart,
                                          ));
                                        }
                                      } else {
                                        // Failure!
                                        InAppNotification.showOverlayIn(context, InAppNotification(
                                          icon: Icon(Mdi.uploadOff, color: Colors.red),
                                          title: Text("upload.failed.title".tr),
                                          text: Text("upload.failed.generic".tr),
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
                                onPressed: () async {
                                  var resp = await API.updateFlow(
                                    id: widget.flow.snowflake,
                                    avatarUrl: null,
                                  );
                                  if (resp.isOk && resp.body["updateFlow"] != null) {
                                    // Success
                                    InAppNotification.showOverlayIn(context, InAppNotification(
                                      icon: Icon(Mdi.check, color: Colors.green),
                                      title: Text("flow.update.success".tr),
                                      corner: Corner.bottomStart,
                                    ));
                                  } else {
                                    // Failure!
                                    InAppNotification.showOverlayIn(context, InAppNotification(
                                      icon: Icon(Mdi.alertCircle, color: Colors.red),
                                      title: Text("flow.update.failed".tr),
                                      corner: Corner.bottomStart,
                                    ));
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text("flow.update.avatar.remove".tr),
                                )
                              ),
                            )
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: nameController,
                      onSubmitted: (value) async {
                        var resp = await API.updateFlow(
                          id: widget.flow.snowflake,
                          name: value,
                        );
                        if (resp.isOk && resp.body["updateFlow"] != null) {
                          // Success
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.check, color: Colors.green),
                            title: Text("upload.success.avatar.title".tr),
                            corner: Corner.bottomStart,
                          ));
                        } else {
                          // Failure!
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.alertCircle, color: Colors.red),
                            title: Text("flow.update.failed".tr),
                            corner: Corner.bottomStart,
                          ));
                        }
                      },
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: IconButton(onPressed: () async {
                            var resp = await API.updateFlow(
                              id: widget.flow.snowflake,
                              name: nameController.value.text,
                            );
                            if (resp.isOk && resp.body["updateFlow"] != null) {
                              // Success
                              InAppNotification.showOverlayIn(context, InAppNotification(
                                icon: Icon(Mdi.check, color: Colors.green),
                                title: Text("upload.success.avatar.title".tr),
                                corner: Corner.bottomStart,
                              ));
                            } else {
                              // Failure!
                              InAppNotification.showOverlayIn(context, InAppNotification(
                                icon: Icon(Mdi.alertCircle, color: Colors.red),
                                title: Text("flow.update.failed".tr),
                                corner: Corner.bottomStart,
                              ));
                            }
                          }, icon: Icon(Mdi.check)),
                        ),
                        labelText: "flow.update.name".tr
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: descriptionController,
                      onSubmitted: (value) async {
                        var resp = await API.updateFlow(
                          id: widget.flow.snowflake,
                          description: value,
                        );
                        if (resp.isOk && resp.body["updateFlow"] != null) {
                          // Success
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.check, color: Colors.green),
                            title: Text("upload.success.avatar.title".tr),
                            corner: Corner.bottomStart,
                          ));
                        } else {
                          // Failure!
                          InAppNotification.showOverlayIn(context, InAppNotification(
                            icon: Icon(Mdi.alertCircle, color: Colors.red),
                            title: Text("flow.update.failed".tr),
                            corner: Corner.bottomStart,
                          ));
                        }
                      },
                      maxLines: null,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: IconButton(onPressed: () async {
                            var resp = await API.updateFlow(
                              id: widget.flow.snowflake,
                              description: descriptionController.value.text,
                            );
                            if (resp.isOk && resp.body["updateFlow"] != null) {
                              // Success
                              InAppNotification.showOverlayIn(context, InAppNotification(
                                icon: Icon(Mdi.check, color: Colors.green),
                                title: Text("upload.success.avatar.title".tr),
                                corner: Corner.bottomStart,
                              ));
                            } else {
                              // Failure!
                              InAppNotification.showOverlayIn(context, InAppNotification(
                                icon: Icon(Mdi.alertCircle, color: Colors.red),
                                title: Text("flow.update.failed".tr),
                                corner: Corner.bottomStart,
                              ));
                            }
                          }, icon: Icon(Mdi.check)),
                        ),
                        labelText: "flow.update.description".tr
                      ),
                    ),
                  )
                ],
              ))
            ],
          )
        )
      )
    );
  }
}