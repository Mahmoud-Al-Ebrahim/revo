import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({
    Key? key,
    required this.name,
  }) : super(key: key);

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/edit-community/',queryParameters: {"name"  : name});
  }

  void navigateToAddMods(BuildContext context) {
    Routemaster.of(context).push('/add-mods/',queryParameters: {"name"  : name});
  }

  void navigateToMembers(BuildContext context) {
    Routemaster.of(context).push('/members-screen/',queryParameters: {"name"  : name});
  }

  void navigateToBlockedMembers(BuildContext context) {
    Routemaster.of(context).push('/blocked-screen/',queryParameters: {"name"  : name});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod Tools'),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SvgPicture.asset('assets/svg/team.svg', fit: BoxFit.fitHeight,height: 300,),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_moderator),
                title: const Text('Add Moderators'),
                onTap: () => navigateToAddMods(context),
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Community Members'),
                onTap: () => navigateToMembers(context),
              ),
              ListTile(
                leading: const Icon(Icons.not_accessible),
                title: const Text('Blocked Members'),
                onTap: () => navigateToBlockedMembers(context),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Community'),
                onTap: () => navigateToModTools(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
