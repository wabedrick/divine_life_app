import 'package:flutter/material.dart';

class MCDetailScreen extends StatelessWidget {
  final Map<String, dynamic> mc;

  final String mcNameWord = 'MC';
  late final String mcName;
  late final String mcLeaderName;
  late final String mcLocation;

  MCDetailScreen({super.key, required this.mc}) {
    mcName = mc['mc_name'];
    mcLeaderName = mc['leader'];
    mcLocation = mc['mc_location'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${mcName[0].toUpperCase()}${mcName.substring(1)} $mcNameWord',
          textAlign: TextAlign.center,
          style: TextStyle(),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leader: ${mcLeaderName[0].toUpperCase()}${mcLeaderName.substring(1)}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'Phone Number: ${mc['leader_phoneNumber'] ?? 'No phone'}',
              style: TextStyle(fontSize: 14.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Location: ${mcLocation[0].toUpperCase()}${mcLocation.substring(1)}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Members:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: mc['members'].length,
            //     itemBuilder: (context, index) {
            //       final member = mc['members'][index];
            //       return Card(
            //         margin: EdgeInsets.only(bottom: 8.0),
            //         child: ListTile(
            //           title: Text(member['username']),
            //           subtitle: Text(
            //             'Contact: ${member['phone'] ?? 'No phone'}',
            //           ),
            //           // onTap: () {
            //           //   // Navigate to the member detail screen
            //           //   Navigator.push(
            //           //     context,
            //           //     MaterialPageRoute(
            //           //       builder: (context) => MemberDetailScreen(member: member),
            //           //     ),
            //           //   );
            //           // },
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
