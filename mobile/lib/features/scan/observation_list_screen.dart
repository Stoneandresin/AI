import 'package:flutter/material.dart';
import '../../data/models/observation.dart';

/// A screen that displays a list of observations.
class ObservationListScreen extends StatelessWidget {
  final List<Observation> observations;

  const ObservationListScreen({Key? key, required this.observations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Observations'),
      ),
      body: ListView.builder(
        itemCount: observations.length,
        itemBuilder: (context, index) {
          final obs = observations[index];
          return ListTile(
            title: Text('Item: ${obs.itemId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${obs.quantity}'),
                Text('Time: ${obs.timestamp}'),
                Text('User: ${obs.userId}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
