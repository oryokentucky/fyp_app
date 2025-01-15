import 'package:flutter/material.dart';

class OrderManagementTab extends StatelessWidget {
  const OrderManagementTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Order Management Tab',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
