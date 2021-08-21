import "package:flutter/material.dart";
import 'package:get/get.dart';

class NormalEmptyState extends StatelessWidget {
  const NormalEmptyState({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset("assets/img/emptystate-normal.png", fit: BoxFit.contain),
          Text("error.emptycontent.title".tr, style: Get.textTheme.headline6),
          // TODO: change the below depending on if theree's a Flow specified
          Text("error.emptycontent.encouragement".tr, style: Get.textTheme.bodyText2),
        ],
      ),
    );
  }
}