import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogComplaints extends StatefulWidget {
  static const String id = 'log_complaints';

  @override
  _LogComplaintsState createState() => _LogComplaintsState();
}

class _LogComplaintsState extends State<LogComplaints> {
  CollectionReference complaints =
      FirebaseFirestore.instance.collection('complaints');

  String selectedCategory;
  bool isWaiting = true;
  String bodyText = '';
  String subjectText = '';
  List<String> priorityList = ['Low', 'Moderate', 'High'];

  final _formKey = GlobalKey<FormState>();

  final FocusNode fnOne = FocusNode();
  final FocusNode fnTwo = FocusNode();

  DropdownButtonFormField<String> androidDropdown() {
    List<DropdownMenuItem<String>> dropDownItems = [];

    for (String category in priorityList) {
      var newItem = DropdownMenuItem(
        child: Text(category),
        value: category,
      );

      dropDownItems.add(newItem);
    }

    return DropdownButtonFormField<String>(
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 42,
        isExpanded: true,
        value: selectedCategory,
        items: dropDownItems,
        hint: Text('Select Priority'),
        validator: (value) {
          if (value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            selectedCategory = value;
            //  getData();
          });
        });
  }

  CupertinoPicker iOSPicker() {
    List<Text> pickerItems = [];

    for (String category in priorityList) {
      pickerItems.add(Text(category));
    }

    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        selectedCategory = priorityList[selectedIndex];
      },
      children: pickerItems,
    );
  }

  final button = Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          offset: Offset(14, 5),
          blurRadius: 20,
          color: Color(0xffaaaaaa).withOpacity(0.15),
        )
      ],
    ),
    //
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Submit',
          style: TextStyle(color: Colors.blue),
        ),
        Icon(
          Icons.send_outlined,
          color: Colors.blue,
          size: 15,
        ),
      ],
    ),
  );

  Future<void> addComplaint(String uid) async {
    return complaints.add({
      'subject': subjectText,
      'priority': selectedCategory,
      'message': bodyText,
      'createdAt': DateTime.now(),
      'uid': uid,
    }).then((value) {
      print("Complaint Added well well");
      Navigator.pop(context);
    }).catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    Map args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: FittedBox(
          child: Text(
            'Talk to us',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          InkWell(
            child: button,
            onTap: () {
              if (_formKey.currentState.validate()) {
                addComplaint(args['uid']);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: deviceHeight * 0.28,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/take_complaint.gif'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Container(
              width: deviceWidth,
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Platform.isMacOS ? iOSPicker() : androidDropdown(),
            ),
            SizedBox(height: deviceHeight * 0.02),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                      focusNode: fnOne,
                      onFieldSubmitted: (term) {
                        fnOne.unfocus();
                        FocusScope.of(context).requestFocus(fnTwo);
                      },
                      minLines: 1,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter Subject',
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => subjectText = v,
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8)),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                      focusNode: fnTwo,
                      textInputAction: TextInputAction.done,
                      minLines: 10,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'Enter your complaint',
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => bodyText = v,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: deviceHeight * 0.02),
          ],
        ),
      ),
    );
  }
}

class ShowAlert extends StatelessWidget {
  final String title;
  final String content;

  ShowAlert({this.title, this.content});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid)
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      );
    else
      return CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
      );
  }
}
