import 'package:flutter/material.dart';
import '../backends/circle.dart'; // Circle クラスを提供するファイルをインポート

class CircleDetailPage extends StatelessWidget {
  final Circle circle;

  const CircleDetailPage({Key? key, required this.circle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circle Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              circle.content,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Posted by: ${circle.user.userName} (@${circle.user.userHandle})',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              'Actions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () {
                    // Implement comment action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.repeat),
                  onPressed: () {
                    // Implement retweet action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.favorite),
                  onPressed: () {
                    // Implement like action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
