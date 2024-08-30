import 'package:check_bike/config/color.dart';
import 'package:check_bike/main.dart';
import 'package:flutter/material.dart';

class BuildCard extends StatelessWidget {
  final String title;
  final String value;
  final String? content;
  const BuildCard({
    required this.title,
    required this.value,
    required this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.info_outlined,
                        color: CheckBikeColor.mainBlue, size: 20),
                  ),
                  TextSpan(
                      text: ' $title\n',
                      style: TextStyle(
                          fontSize: ratio.height * 16,
                          fontWeight: FontWeight.bold,
                          color: CheckBikeColor.grey3)),
                  WidgetSpan(
                    child: SizedBox(
                      height: ratio.height * 40,
                    ),
                  ),
                  TextSpan(
                      text: value,
                      style: TextStyle(
                          fontSize: ratio.height * 23,
                          fontWeight: FontWeight.bold,
                          color: CheckBikeColor.mainBlue)),
                  if (content != null)
                    TextSpan(
                        text: ' $content',
                        style: TextStyle(
                            fontSize: ratio.height * 23,
                            fontWeight: FontWeight.bold,
                            color: CheckBikeColor.grey3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
