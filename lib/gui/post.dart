import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../backends/manager.dart'; // セッションとCSRFトークンをロードするためのカスタムモジュール
import 'timeline.dart'; // 投稿後に表示する画面

class PostMenu extends StatefulWidget {
  const PostMenu();

  @override
  _PostMenu createState() => _PostMenu();
}

class _PostMenu extends State<PostMenu> {
  final TextEditingController _postController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _postPost() async {
    final String postContent = _postController.text;
    if (postContent.isNotEmpty) {
      try {
        // 非同期関数の呼び出しには await を使用
        String? session = await Manager.loadSessionToken();
        String? csrf = await Manager.loadCsrfToken();

        var request = http.MultipartRequest(
            'POST', Uri.parse('https://fiicen.jp/circle/create/'));
        request.headers['User-Agent'] =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';
        request.headers['Cookie'] = 'sessionid=${session}; csrftoken=${csrf};';
        request.headers['X-Csrftoken'] = '${csrf}';

        request.fields['contents'] = postContent;
				if (_selectedImage != null) {
	        request.files.add(await http.MultipartFile.fromPath(
	          'attached_image',
	          _selectedImage!.path,
	          contentType: MediaType('image', 'jpeg'),
	        ));
				}

        var response = await request.send();

        if (response.statusCode == 200) {
          // 投稿が成功した場合、タイムライン画面に遷移
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post posted!')),
          );
          _postController.clear();
          setState(() {
            _selectedImage = null;
          });
        } else {
          // 投稿が失敗した場合のエラーメッセージを表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to post: ${response.statusCode}')),
          );
        }
      } catch (e) {
        // エラーハンドリング
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('本文は空欄であってはいけません。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('サークルをポスト'),
        actions: [
          TextButton(
            onPressed: _postPost,
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _postController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: '今、何が起きてる？',
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('画像を選択'),
            ),
            SizedBox(height: 20),
            _selectedImage == null
                ? Text('No image selected.')
                : Image.file(_selectedImage!),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: PostMenu(),
    ));
