import 'package:flutter/material.dart';
import 'package:check_bike/config/color.dart';
import 'package:check_bike/main.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? func;
  final Color textColor;
  final Color backgroundColor;
  final int buttonCount;
  final int width;
  final int height;

  const CustomButton({
    required this.width,
    required this.height,
    required this.text,
    this.func, // Make this nullable
    this.textColor = Colors.white,
    this.backgroundColor = CheckBikeColor.mainBlue,
    required this.buttonCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isButtonDisabled = func == null;

    return InkWell(
      onTap: isButtonDisabled ? null : func,
      child: buttonCount == 1
          ? Container(
        width: ratio.width * width,
        height: ratio.height * height,
        decoration: BoxDecoration(
          color: isButtonDisabled
              ? Colors.grey.withOpacity(0.6)
              : backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: isButtonDisabled
                  ? Colors.grey[300]
                  : textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )
          : Row(
        children: [
          Expanded(
            child: Container(
              width: ratio.width * width,
              height: ratio.height * height,
              decoration: BoxDecoration(
                color: isButtonDisabled
                    ? Colors.grey.withOpacity(0.6)
                    : CheckBikeColor.mainBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "등록",
                  style: TextStyle(
                    fontSize: 20,
                    color: isButtonDisabled
                        ? Colors.grey[300]
                        : textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ratio.width * 25),
          Expanded(
            child: Container(
              width: ratio.width * width,
              height: ratio.height * height,
              decoration: BoxDecoration(
                color: isButtonDisabled
                    ? Colors.grey.withOpacity(0.6)
                    : CheckBikeColor.subBlue2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "삭제",
                  style: TextStyle(
                    fontSize: 20,
                    color: isButtonDisabled
                        ? Colors.grey[300]
                        : CheckBikeColor.mainBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
