import 'package:flutter/material.dart';
import 'package:team_task_flutter/models/group_model.dart';
import 'package:team_task_flutter/screens/groups/create_edit_group_screen.dart';

class CreateGroupScreen extends StatelessWidget {
  final GroupModel? group;

  const CreateGroupScreen({
    super.key,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    return CreateEditGroupScreen(group: group);
  }
}