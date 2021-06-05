import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_guardian/controller/commons.dart';
import 'package:the_guardian/controller/constants.dart';
import 'package:the_guardian/screens/complaints/components/components.dart';

class ComplaintDetail extends StatefulWidget {
  static const String id = 'complaint_detail';

  @override
  _ComplaintDetailState createState() => _ComplaintDetailState();
}

class _ComplaintDetailState extends State<ComplaintDetail> {
  final TextEditingController adviceController = TextEditingController();

  bool isLoading = false;

  List<QueryDocumentSnapshot> admins = [];

  CollectionReference complaints =
      FirebaseFirestore.instance.collection('complaints');

  Future<void> updateComplaint(docId, senderId, senderPhone) {
    return complaints.doc(docId).update({
      'resolveMessage': adviceController.text,
      'status': 'Resolved',
      'updatedAt': DateTime.now(),
      'counsellorId': '$senderId',
      'counsellorPhone': '$senderPhone'
    }).then((value) {
      Commons.showFeedBackCustomDialog(context, false);
    }).catchError((error) {
      Commons.showFeedBackCustomDialog(context, true);
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    TextTheme textTheme = Theme.of(context).textTheme;

    Map args = ModalRoute.of(context).settings.arguments;

    QueryDocumentSnapshot data = args['data'];
    QueryDocumentSnapshot user = args['userData'];

    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Whisper Detail'),
        actions: [
          data.data()['studentPhone'] != ''
              ? IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    Commons.makePhoneCall('tel:${data.data()['studentPhone']}');
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComplaintTile(
              data: data,
              isOnTap: false,
            ),
            SizedBox(height: deviceHeight * 0.03),
            data.data()['status'] == 'Resolved'
                ? ResponseTile(
                    response: data.data()['resolveMessage'] ?? '',
                  )
                : user.data()['role'] == 'counsellor'
                    ? Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: adviceController,
                              maxLines: 10,
                              minLines: 8,
                              decoration: InputDecoration(
                                  hintText: 'Enter your advice',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                            SizedBox(height: deviceHeight * 0.055),
                            SizedBox(
                              width: deviceWidth,
                              child: isLoading
                                  ? Text(
                                      'Loading... Please Wait!',
                                      style: textTheme.headline6,
                                      textAlign: TextAlign.center,
                                    )
                                  : CupertinoButton(
                                      color: kPrimaryColor,
                                      child: Text('Send Advice'),
                                      onPressed: () {
                                        setState(() {
                                          isLoading = !isLoading;
                                        });
                                        updateComplaint(
                                          data.id,
                                          FirebaseAuth.instance.currentUser.uid,
                                          user.data()['phone'],
                                        );

                                        String message =
                                            'Your whisper was heard. Get in here to hear more';

                                        Commons.sendMessage(
                                          data.data()['token'],
                                          message,
                                          '${FirebaseAuth.instance.currentUser.uid}',
                                        );

                                        for (QueryDocumentSnapshot admin
                                            in admins) {
                                          Commons.sendMessage(
                                            admin.data()['token'],
                                            'A student has been counselled',
                                            '${FirebaseAuth.instance.currentUser.uid}',
                                          );
                                        }
                                      }),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
            SizedBox(height: deviceHeight * 0.03),
          ],
        ),
      ),
    );
  }

  fetchData() {
    setState(() {
      FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get()
          .then((admin) {
        admins = admin.docs;
      });
    });
  }
}
