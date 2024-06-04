import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../backends/manager.dart'; // セッションとCSRFトークンをロードするためのカスタムモジュール
import 'timeline.dart'; // 投稿後に表示する画面
import 'profile.dart';

class PostMenu extends StatefulWidget {
  const PostMenu();

  @override
  _PostMenu createState() => _PostMenu();
}

class _PostMenu extends State<PostMenu> {
  final TextEditingController _postController = TextEditingController();
  final ValueNotifier<bool> _isPostButtonEnabled = ValueNotifier(false);
  File? _selectedImage;
  File? _selectedVideo;

  @override
  void initState() {
    super.initState();
    _postController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _postController.removeListener(_onTextChanged);
    _postController.dispose();
    _isPostButtonEnabled.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _isPostButtonEnabled.value = _postController.text.isNotEmpty;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _pickVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
      });
    }
  }

  void _clearVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  Future<void> _postPost() async {
    final String postContent = _postController.text;
    if (postContent.isNotEmpty) {
      try {
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

        if (_selectedVideo != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'attached_video',
            _selectedVideo!.path,
            contentType: MediaType('video', 'mp4'),
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
          title: const Text('サークルをポスト'),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: _isPostButtonEnabled,
              builder: (context, isEnabled, child) {
                return ElevatedButton(
                  onPressed: isEnabled ? _postPost : null,
                  child: Text(
                    'Post',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled ? Colors.blue : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        body: Scrollbar(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: '今、何が起きてる？',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('画像を選択'),
                ),
                const SizedBox(height: 20),
                _selectedImage == null
                    ? SizedBox()
                    : Column(
                        children: [
                          Image.file(_selectedImage!),
                          TextButton(
                            onPressed: _clearImage,
                            child: Text(
                              '画像を解除',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: Text('動画'),
                ),
                const SizedBox(height: 20),
                _selectedVideo == null
                    ? SizedBox()
                    : Column(
                        children: [
                          Text('${_selectedVideo?.path}'),
                          TextButton(
                            onPressed: _clearVideo,
                            child: Text(
                              '動画を解除',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ));
  }
}

void main() => runApp(const MaterialApp(
      home: PostMenu(),
    ));
