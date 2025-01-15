import 'package:flutter/material.dart';

class ProfileManagementTab extends StatelessWidget {
  const ProfileManagementTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile Management Tab',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
