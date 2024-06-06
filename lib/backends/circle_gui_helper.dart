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
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FittedBox(
                        child: Image.network(
                          image ?? '',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 20.0,
              right: 20.0,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}