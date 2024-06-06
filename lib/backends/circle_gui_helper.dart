import 'package:flutter/material.dart';

class CircleGuiHelper {
  static showPreviewImage(
    BuildContext context, {
    required String? image,
  }) {
    showDialog(
      barrierDismissible: true,
      barrierLabel: '閉じる',
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.1,
                    maxScale: 5,
                    child: Image.network(
                      '${image}',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}