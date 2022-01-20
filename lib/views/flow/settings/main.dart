import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/views/flow/settings/profile.dart';
import 'package:seaworld/views/settings/main.dart';

class FlowSettingsRoot extends ConsumerWidget {
  final Flow flow;

  const FlowSettingsRoot({Key? key, required this.flow}) : super(key: key);
  // ignore: prefer_final_fields
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var width = MediaQuery.of(context).size.width;
    return Query(
      options: QueryOptions(
        document: gql(FlowAPI.getFlow),
        variables: {"id": flow.snowflake},
        fetchPolicy: FetchPolicy.cacheFirst,
        optimisticResult: flow
      ),
      builder: (result, {fetchMore, refetch}) => Scaffold(
        drawer: width <= 640 ? Drawer(
          child: Builder(builder: (bc) => _sidebarcontent(bc)),
        ) : null,
        appBar: AppBar(
          title: Text("flow.settings.header.full".tr(namedArgs: {"id": flow.id})),
        ),
        body: Row(
          children: [
            if (width > 640) Container(
              //margin: EdgeInsets.only(right: 32),
              width: 280,
              alignment: Alignment.topLeft,
              color: context.theme().colorScheme.primary.withAlpha(16),
              child: Builder(builder: (bc) => _sidebarcontent(bc))
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                child: ref.watch(_tabController) >= 2 ? Center(child: Icon(Mdi.alert)) : 
                [
                  EditFlowProfilePage(flow: flow),
                  Center(child: Icon(Mdi.tuneVariant)),
                  // // GeneralSettingsPage(),
                  // // ThemeSettingsPage()
                  // Center(child: Icon(Mdi.account)),
                  // ThemingSettings(),
                  // Center(child: Icon(Mdi.security)),
                  // Center(child: Icon(Mdi.eye)),
                  // AboutPage()
                ][ref.watch(_tabController)],
              ),
            )
          ],
        )
      ),
    );
  }

  Widget _sidebarcontent(BuildContext context) {
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (MediaQuery.of(context).size.width <= 640) AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => Navigator.of(context)..pop()..pop(),
            ),
            title: Text("flow.settings.header.minimal".tr()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(),
          ),
          // settings page buttons here...
          TabButton(label: "flow.settings.profile".tr(), icon: Mdi.account, index: 0, controller: _tabController),
          TabButton(label: "flow.settings.features".tr(), icon: Mdi.tuneVariant, index: 1, controller: _tabController),
          //TabButton(label: "settings.security".tr(), icon: Mdi.security, index: 2),
          //TabButton(label: "settings.privacy".tr(), icon: Mdi.eye, index: 3),
          // -----------------------------
        ],
      ),
    );
  }
}

final _tabController = StateNotifierProvider<SettingsTabController, int>((ref) => SettingsTabController());