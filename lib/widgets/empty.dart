import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:seaworld/models/flow.dart';

class NormalEmptyState extends StatelessWidget {
  final PartialFlow? flow;
  const NormalEmptyState({ 
    Key? key,
    this.flow
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset("assets/img/emptystate-normal.png", fit: BoxFit.contain),
          Text("error.emptycontent.title".tr, style: Get.textTheme.headline6),
          // TODO: change the below depending on if theree's a Flow specified
          if (flow != null) Text("error.emptycontent.flow".trParams({"name": flow!.name}), style: Get.textTheme.bodyText2)
          else Text("error.emptycontent.encouragement".tr, style: Get.textTheme.bodyText2),
        ],
      ),
    );
  }
}