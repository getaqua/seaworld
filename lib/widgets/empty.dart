import 'package:easy_localization/src/public_ext.dart';
import "package:flutter/material.dart";
import 'package:seaworld/helpers/extensions.dart';
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
          Text("error.emptycontent.title".tr(), style: context.textTheme().headline6),
          // TODO: change the below depending on if theree's a Flow specified
          if (flow != null) Text("error.emptycontent.flow".tr(namedArgs: {"name": flow!.name}), style: context.textTheme().bodyText2)
          else Text("error.emptycontent.encouragement".tr(), style: context.textTheme().bodyText2),
        ],
      ),
    );
  }
}