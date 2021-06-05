import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_guardian/screens/complaints/components/components.dart';

class ResolvedComplaints extends StatefulWidget {
  static const String id = 'resolved_complaints';

  @override
  _ResolvedComplaintsState createState() => _ResolvedComplaintsState();
}

class _ResolvedComplaintsState extends State<ResolvedComplaints> {
  List<QueryDocumentSnapshot> allComplaints;
  QueryDocumentSnapshot user;
  bool isUpdated = false;

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;

    user = user['user'];

    Stream collectionStream = FirebaseFirestore.instance
        .collection('complaints')
        .orderBy('updatedAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Resolved Complaints'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(
              'Something went wrong... Please Try Again',
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Preparing your data... Please Wait");
          }

          List<QueryDocumentSnapshot> allComplaints;
          allComplaints = snapshot.data.docs;

          List<QueryDocumentSnapshot> resolvedComplaints = allComplaints
              .where((element) => element.data()['status'] == 'Resolved')
              .toList();
          return Container(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: resolvedComplaints.length,
              itemBuilder: (context, index) {
                return ComplaintTile(
                  data: resolvedComplaints[index],
                  userData: user,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
