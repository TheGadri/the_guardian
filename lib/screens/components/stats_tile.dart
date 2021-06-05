import 'package:flutter/material.dart';
import 'package:the_guardian/controller/constants.dart';

class StatsTile extends StatelessWidget {
  final String priority;
  final int count;
  final int total;
  final double percentage;
  final bool isAccent;

  StatsTile({
    this.priority,
    this.count,
    this.percentage,
    this.total,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      height: deviceWidth * 0.5,
      width: deviceWidth * 0.44,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isAccent ? kPrimaryColor.withOpacity(0.1) : kPrimaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              getImageUrl(priority),
              height: 30,
              width: 30,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                    text: '$count${priority == 'Resolved' ? '/$total' : ''} ',
                    style: textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isAccent ? Color(0xFF3a3a3a) : Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: priority == 'Resolved' ? 'completed' : 'pending',
                        style: textTheme.caption.copyWith(
                          color: isAccent ? Color(0xFF3a3a3a) : Colors.white,
                        ),
                      )
                    ]),
              ),
              SizedBox(height: 5),
              Stack(
                children: [
                  Container(
                    width: deviceWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Container(
                    width: (deviceWidth * 0.44) * percentage,
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isAccent ? kPrimaryColor : Color(0xFFFE9000),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
            ],
          ),
          Text(
            priority,
            style: textTheme.headline6.copyWith(
              fontWeight: FontWeight.bold,
              color: isAccent ? Color(0xFF3a3a3a) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String getImageUrl(String priority) {
    switch (priority) {
      case 'Low':
        return 'assets/images/low_priority.png';
      case 'Moderate':
        return 'assets/images/medium_priority.png';
      case 'High':
        return 'assets/images/high_priority.png';
      case 'Resolved':
      default:
        return 'assets/images/completed.png';
    }
  }
}
