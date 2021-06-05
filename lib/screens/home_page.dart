import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_guardian/controller/commons.dart';
import 'package:the_guardian/controller/constants.dart';
import 'package:the_guardian/screens/complaints/complaints.dart';
import 'package:the_guardian/screens/components/stats_tile.dart';

class HomePage extends StatefulWidget {
  static const String id = 'home_page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QueryDocumentSnapshot user;
  List<QueryDocumentSnapshot> allComplaints;

  int lowCount,
      moderateCount,
      highCount,
      resolvedCount,
      totalCount,
      messageCount;
  double lowPercent, moderatePercent, highPercent, resolvedPercent;

  Stream collectionStream = FirebaseFirestore.instance
      .collection('complaints')
      .orderBy('createdAt', descending: true)
      .snapshots();

  final List<String> imgList = [
    'https://wishesmessages.com/wp-content/uploads/2014/02/I-need-help-inspirational-quote-about-life.jpg',
    'https://www.wishesmsg.com/wp-content/uploads/motivational-quotes-for-students-studying.jpg',
    'https://www.wishesmsg.com/wp-content/uploads/encouraging-words-for-students-from-teachers.jpg',
    'https://www.wishesmsg.com/wp-content/uploads/motivational-quotes-for-students-success.jpg',
    'https://pbs.twimg.com/media/Evl-v5dXEAILHpk?format=jpg&name=large',
    'https://images.unsplash.com/photo-1494883759339-0b042055a4ee?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1567&q=80'
  ];

  @override
  void initState() {
    Commons.getMessageCount().then((value) {
      messageCount = value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    TextTheme textTheme = Theme.of(context).textTheme;

    Map args = ModalRoute.of(context).settings.arguments;

    user = args['user'];

    final List<Widget> imageSliders = imgList
        .map((item) => Container(
              child: Container(
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    child: Stack(
                      children: <Widget>[
                        Image.network(
                          item,
                          fit: BoxFit.cover,
                          width: deviceWidth,
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
                        ),
                      ],
                    )),
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('The Guide'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                messageCount != 0
                    ? Positioned(
                        right: 0,
                        top: 5,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.redAccent),
                        ),
                      )
                    : SizedBox.shrink()
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                user.data()['role'] != 'counsellor'
                    ? ResolvedComplaints.id
                    : AllComplaints.id,
                arguments: {'user': user},
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: deviceHeight * 0.01),
            Text(
              'Hello,',
              style: textTheme.subtitle1,
            ),
            SizedBox(height: deviceHeight * 0.01),
            Text(
              '${user != null ? user.data()['name'] : ''}',
              style: textTheme.headline4.copyWith(
                color: Color(0xff3a3a3a),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: deviceHeight * 0.03),
            AspectRatio(
                aspectRatio: 1.6,
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                  ),
                  items: imageSliders,
                )),
//
            SizedBox(height: deviceHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Whispers Stats',
                  style: textTheme.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OutlineButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      user.data()['role'] == 'counsellor'
                          ? AllComplaints.id
                          : ResolvedComplaints.id,
                      arguments: {'userData': user},
                    );
                  },
                  child: Text(
                    (user.data()['role'] == 'counsellor')
                        ? 'More Details >>'
                        : 'See Resolved',
                    style: TextStyle(color: kPrimaryColor),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  borderSide: BorderSide(color: kPrimaryColor, width: 1),
                ),
              ],
            ),
            SizedBox(height: deviceHeight * 0.03),

            StreamBuilder<QuerySnapshot>(
              stream: collectionStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return AspectRatio(
                    aspectRatio: 2,
                    child: Center(
                        child: Text(
                      'Something went wrong... Please Try Again',
                    )),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AspectRatio(
                      aspectRatio: 2,
                      child: Text("Preparing your data... Please Wait"));
                }

                allComplaints = snapshot.data.docs;
                getStats();

                if (allComplaints.isNotEmpty)
                  return Wrap(
                    runSpacing: deviceWidth * 0.04,
                    spacing: deviceWidth * 0.04,
                    direction: Axis.horizontal,
                    children: [
                      StatsTile(
                        priority: 'Low',
                        count: lowCount,
                        percentage: lowPercent,
                      ),
                      StatsTile(
                        priority: 'Moderate',
                        count: moderateCount,
                        percentage: moderatePercent,
                      ),
                      StatsTile(
                        priority: 'High',
                        count: highCount,
                        percentage: highPercent,
                      ),
                      StatsTile(
                        priority: 'Resolved',
                        count: resolvedCount,
                        percentage: resolvedPercent,
                        total: totalCount,
                        isAccent: true,
                      ),
                    ],
                  );
                else
                  AspectRatio(
                    aspectRatio: 2,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text('You have no complaints'),
                    ),
                  );

                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  getStats() {
    totalCount = allComplaints.length;

    lowCount = allComplaints
        .where((element) =>
            element.data()['priority'] == 'Low' &&
            element.data()['status'] == 'Pending')
        .toList()
        .length;
    lowPercent = lowCount / allComplaints.length;

    moderateCount = allComplaints
        .where((element) =>
            element.data()['priority'] == 'Moderate' &&
            element.data()['status'] == 'Pending')
        .toList()
        .length;
    moderatePercent = moderateCount / allComplaints.length;

    highCount = allComplaints
        .where((element) =>
            element.data()['priority'] == 'High' &&
            element.data()['status'] == 'Pending')
        .toList()
        .length;
    highPercent = highCount / allComplaints.length;

    resolvedCount = allComplaints
        .where((element) => element.data()['status'] == 'Resolved')
        .toList()
        .length;
    resolvedPercent = resolvedCount / allComplaints.length;
  }
}
