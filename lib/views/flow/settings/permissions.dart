import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart" hide Flow;
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/flow.dart';

class FlowPermissionsPage extends StatefulWidget {
  final Flow flow;
  const FlowPermissionsPage({ Key? key, required this.flow }) : super(key: key);


  @override
  State<FlowPermissionsPage> createState() => _FlowPermissionsPageState();
}

class _FlowPermissionsPageState extends State<FlowPermissionsPage> {
  final ScrollController scrollController = ScrollController();
  int currentTab = 0;
  late FlowPermissions publicPermissions;
  late FlowPermissions joinedPermissions;

  @override
  void initState() {
    publicPermissions = widget.flow.publicPermissions;
    joinedPermissions = widget.flow.joinedPermissions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    final optimistic = () => {"updateFlow": {"public_permissions": publicPermissions, "joined_permissions": joinedPermissions}};
    return ListView(
      controller: scrollController,
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTab(context, child: Text("flow.update.permission.tabs.public".tr()), tab: 0),
                _buildTab(context, child: Text("flow.update.permission.tabs.joined".tr()), tab: 1),
                //_buildTab(context, child: Text("flow.update.permission.tabs.overrides".tr()), tab: 2),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("flow.update.permission.sections.flow".tr()),
        ),
        Mutation( // Join
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic(),
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.join.title".tr()),
              enabled: currentTab == 0,
              subtitle: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("flow.update.permission.join.description".tr()),
                  if (_result.join == AllowDeny.request) ...[
                    SizedBox(height: 4),
                    Text("flow.update.permission.join.request_description".tr())
                  ]
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.join,
                    enabled: result?.isLoading != true && currentTab == 0,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).join ?? AllowDeny.deny,
                    onChange: (newValue) {
                      publicPermissions = publicPermissions.copyWith(join: newValue);
                      runMutation({"id": widget.flow.snowflake, "data": {"public_permissions": {"join": newValue?.name}}});
                    },
                    extraStates: const [PermissionSwitchState(
                      icon: Icon(Mdi.accountQuestion), 
                      label: "flow.update.permission.join.request",
                      activeColor: Colors.amber,
                      value: AllowDeny.request
                    )],
                  ),
                ],
              ),
            );
          },
        ),
        Mutation( // Update
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic()
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.update.title".tr()),
              subtitle: Text("flow.update.permission.update.description".tr()),
              enabled: currentTab != 0,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.update,
                    enabled: result?.isLoading != true && currentTab != 0,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).update ?? AllowDeny.deny,
                    onChange: (newValue) {
                      joinedPermissions = joinedPermissions.copyWith(update: newValue);
                      runMutation({"id": widget.flow.snowflake, "data": {"joined_permissions": {"update": newValue?.name}}});
                    }
                  ),
                ],
              ),
            );
          },
        ),
        Mutation( // View
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic()
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.view.title".tr()),
              subtitle: Text("flow.update.permission.view.description".tr()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.view,
                    enabled: result?.isLoading != true,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).view ?? AllowDeny.deny,
                    onChange: (newValue) {
                      if (currentTab == 0) {
                        publicPermissions = publicPermissions.copyWith(view: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"public_permissions": {"view": newValue?.name}}});
                      } else if (currentTab == 1) {
                        joinedPermissions = joinedPermissions.copyWith(view: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"joined_permissions": {"view": newValue?.name}}});
                      }
                    }
                  ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("flow.update.permission.sections.content".tr()),
        ),
        Mutation( // Read
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic()
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.read.title".tr()),
              subtitle: Text("flow.update.permission.read.description".tr()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.read,
                    enabled: result?.isLoading != true,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).read ?? AllowDeny.deny,
                    onChange: (newValue) {
                      if (currentTab == 0) {
                        publicPermissions = publicPermissions.copyWith(read: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"public_permissions": {"read": newValue?.name}}});
                      } else if (currentTab == 1) {
                        joinedPermissions = joinedPermissions.copyWith(read: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"joined_permissions": {"read": newValue?.name}}});
                      }
                    }
                  ),
                ],
              ),
            );
          },
        ),
        Mutation( // Post
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic()
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.post.title".tr()),
              subtitle: Text("flow.update.permission.post.description".tr()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.post,
                    enabled: result?.isLoading != true,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).post ?? AllowDeny.deny,
                    onChange: (newValue) {
                      if (currentTab == 0) {
                        publicPermissions = publicPermissions.copyWith(post: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"public_permissions": {"post": newValue?.name}}});
                      } else if (currentTab == 1) {
                        joinedPermissions = joinedPermissions.copyWith(post: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"joined_permissions": {"post": newValue?.name}}});
                      }
                    }
                  ),
                ],
              ),
            );
          },
        ),
        Mutation( // Delete
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic()
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.delete.title".tr()),
              subtitle: Text("flow.update.permission.delete.description".tr()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.delete,
                    enabled: result?.isLoading != true,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).delete ?? AllowDeny.deny,
                    onChange: (newValue) {
                      if (currentTab == 0) {
                        publicPermissions = publicPermissions.copyWith(delete: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"public_permissions": {"delete": newValue?.name}}});
                      } else if (currentTab == 1) {
                        joinedPermissions = joinedPermissions.copyWith(delete: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"joined_permissions": {"delete": newValue?.name}}});
                      }
                    }
                  ),
                ],
              ),
            );
          },
        ),
        Mutation( // Anonymous
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic()
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.anonymous.title".tr()),
              subtitle: Text("flow.update.permission.anonymous.description".tr()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.anonymous,
                    enabled: result?.isLoading != true,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).anonymous ?? AllowDeny.deny,
                    onChange: (newValue) {
                      if (currentTab == 0) {
                        publicPermissions = publicPermissions.copyWith(anonymous: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"public_permissions": {"anonymous": newValue?.name}}});
                      } else if (currentTab == 1) {
                        joinedPermissions = joinedPermissions.copyWith(anonymous: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"joined_permissions": {"anonymous": newValue?.name}}});
                      }
                    },
                    extraStates: const [PermissionSwitchState(
                      icon: Icon(Mdi.gavel), 
                      label: "flow.update.permission.anonymous.force",
                      activeColor: Colors.orange,
                      value: AllowDeny.force
                    )],
                  ),
                ],
              ),
            );
          },
        ),
        Mutation( // Pin
          options: MutationOptions(
            document: gql(FlowAPI.updateFlowPermissions),
            optimisticResult: optimistic()
          ),
          builder: (runMutation, result) {
            final _result = getResult(result, widget.flow, currentTab == 0);
            return ListTile(
              title: Text("flow.update.permission.pin.title".tr()),
              subtitle: Text("flow.update.permission.pin.description".tr()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(context, result),
                  PermissionSwitch(
                    selected: _result.pin,
                    enabled: result?.isLoading != true,
                    useNeutralState: false,
                    defaultValue: (currentTab == 0 ? FlowPermissions.publicFallbacks : FlowPermissions.joinedFallbacks).pin ?? AllowDeny.deny,
                    onChange: (newValue) {
                      if (currentTab == 0) {
                        publicPermissions = publicPermissions.copyWith(pin: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"public_permissions": {"pin": newValue?.name}}});
                      } else if (currentTab == 1) {
                        joinedPermissions = joinedPermissions.copyWith(pin: newValue);
                        runMutation({"id": widget.flow.snowflake, "data": {"joined_permissions": {"pin": newValue?.name}}});
                      }
                    }
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  static FlowPermissions getResult(QueryResult? result, Flow fallback, bool public) {
    if (result?.data != null) {
      return FlowPermissions.fromJson(result!.data!["updateFlow"][public ? "publicPermissions" : "joinedPermissions"]);
    } else {
      return public ? fallback.publicPermissions : fallback.joinedPermissions;
    }
  }

  Widget _buildSpinner(BuildContext context, QueryResult? result) {
    return result?.hasException == true ? Tooltip(
      message: result?.exception?.linkException?.toString()
        ?? result?.exception?.graphqlErrors.first.message
        ?? "No exception",  
      child: Icon(Mdi.alert, color: Colors.red),
    ) : AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: result?.isLoading??false ? 1 : 0,
      child: SizedBox(child: CircularProgressIndicator(), height: 24, width: 24),
    );
  }

  Widget _buildTab(BuildContext context, {required Widget child, required int tab}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: currentTab == tab ? context.theme().colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),  
          onTap: () => setState(() => currentTab = tab),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Theme(
              data: context.theme().copyWith(iconTheme: IconThemeData(color: currentTab == tab ? context.theme().colorScheme.onPrimary : context.theme().colorScheme.primary)),
              child: DefaultTextStyle(
                style: context.textTheme().subtitle1!.copyWith(color: currentTab == tab ? context.theme().colorScheme.onPrimary : context.theme().colorScheme.primary),
                child: child
              )
            ),
          ),
        ),
      ),
    );
  }
}

class PermissionSwitch extends StatelessWidget {
  /// Places these states furthest from the neutral state on the Deny side.
  final List<PermissionSwitchState> extraStates;
  final bool useDefaultStates;
  /// Only useful if [useDefaultStates] is set to true
  final bool useNeutralState;
  final bool enabled;
  /// Only useful if [useNeutralState] is set to false
  final AllowDeny? defaultValue;
  final AllowDeny? selected;
  final Function(AllowDeny?)? onChange;
  const PermissionSwitch({ 
    Key? key,
    this.selected,
    this.onChange,
    this.enabled = true,
    this.useDefaultStates = true,
    this.useNeutralState = true,
    this.defaultValue,
    this.extraStates = const [],
  }) : assert(useNeutralState || defaultValue != null, "If the neutral state is not in use, a default must be set."), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final state in [
          ...extraStates,
          if (useDefaultStates) PermissionSwitchState.deny,
          if (useDefaultStates && useNeutralState) PermissionSwitchState.neutral,
          if (useDefaultStates) PermissionSwitchState.allow,
        ]) InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? () => onChange?.call(state.value) : null,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: 
                state.value == selected ? state.activeColor 
                : state.value == defaultValue && selected == null ? PermissionSwitchState.neutral.activeColor
                : null,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Tooltip(
                message: state.label.tr(),
                child: IconTheme(
                  data: IconThemeData(color: 
                  state.value == selected ? state.foregroundColor
                  : state.value == defaultValue && selected == null ? PermissionSwitchState.neutral.foregroundColor
                  : context.textTheme().bodyText2?.color),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: state.icon,
                  )
                )
              ),
            ),
          ),
        )
      ],
    );
  }
}

class PermissionSwitchState {
  static final deny = PermissionSwitchState(
    icon: Icon(Mdi.cancel),
    label: "flow.update.permission.states.deny",
    activeColor: Colors.red,
    value: AllowDeny.deny
  );
  static final neutral = PermissionSwitchState(
    icon: Icon(Mdi.tilde),
    label: "flow.update.permission.states.default",
    activeColor: Colors.grey,
    value: null
  );
  static final allow = PermissionSwitchState(
    icon: Icon(Mdi.check),
    label: "flow.update.permission.states.allow",
    activeColor: Colors.green,
    value: AllowDeny.allow
  );
  final Widget icon;
  final String label;
  final Color activeColor;
  final Color foregroundColor;
  final AllowDeny? value;
  const PermissionSwitchState({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.value,
    this.foregroundColor = Colors.white
  });
}