import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Dashboard Tab',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
