import 'package:flutter/material.dart';
import '../backends/circle.dart'; // Import file providing Circle class
import '../backends/textagent.dart';
import '../backends/circle_gui_helper.dart';
import 'profile.dart';
import 'footer.dart';

class CircleDetailPage extends StatefulWidget {
  final Circle circle;

  const CircleDetailPage({Key? key, required this.circle}) : super(key: key);

  @override
  _CircleDetailPageState createState() => _CircleDetailPageState();
}

class _CircleDetailPageState extends State<CircleDetailPage> {
  final TextEditingController replyTextFieldController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<Circle?> replySourceFuture;

  @override
  void initState() {
    super.initState();
    getReplySource();
  }

  Future<void> getReplySource() async {
    try {
      replySourceFuture = widget.circle.getReplySource();
      await replySourceFuture;
      setState(() {}); // Update UI when replySourceFuture completes
    } catch (e) {
      // Handle error
      print('Error fetching reply source: $e');
    }
  }

  @override
  void dispose() {
    replyTextFieldController.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  Widget _buildCircleAvatar(BuildContext context, Circle circle) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(user: circle.user)),
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage(circle.user.avatarUrl),
      ),
    );
  }

  Widget _buildUserInfo(Circle circle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          circle.user.userName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          circle.user.userHandle,
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildActions(Circle circle) {
    return FutureBuilder(
      future: Future.wait([
        circle.getReplysCount(),
        circle.getReflyUsersCount(),
        circle.getLikedUsersCount()
      ]),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Row(
            children: [
              CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {},
              ),
              const Text("Error"),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.repeat),
                onPressed: () {},
              ),
              const Text("Error"),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {},
              ),
              const Text("Error"),
            ],
          );
        } else {
          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.comment_outlined),
                onPressed: () {},
              ),
              Text(snapshot.data![0].toString()),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.repeat),
                color: circle.reflown ? Colors.green : null,
                onPressed: () async {
                  bool reflown = await circle.refly();
                  if (reflown) {
                    setState(() {});
                  }
                },
              ),
              Text(snapshot.data![1].toString()),
              const SizedBox(width: 16),
              IconButton(
                color: circle.liked ? Colors.pink : null,
                icon: circle.liked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_outline),
                onPressed: () async {
                  bool liked = await circle.like();
                  if (liked) {
                    setState(() {});
                  }
                },
              ),
              Text(snapshot.data![2].toString()),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('サークル'),
        centerTitle: true,
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display reply source circle if available
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: FutureBuilder<Circle?>(
                        future: replySourceFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data == null) {
                            return const SizedBox();
                          } else {
                            final replySourceCircle = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                                  minVerticalPadding: 8.0 * 0.2,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _buildCircleAvatar(context, replySourceCircle),
                                          const SizedBox(width: 8),
                                          _buildUserInfo(replySourceCircle),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text.rich(TextAgent.generate(replySourceCircle.content, context)),
                                      _buildActions(replySourceCircle),
                                      const Divider(
                                        color: Colors.black,
                                        thickness: 1,
                                        height: 2,
                                      ),
                                    ],
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CircleDetailPage(circle: replySourceCircle),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                    // Main circle details
                    Row(
                      children: [
                        _buildCircleAvatar(context, widget.circle),
                        const SizedBox(width: 8),
                        _buildUserInfo(widget.circle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text.rich(TextAgent.generate(widget.circle.content, context)),
                    widget.circle.imageUrl != null
                        ? GestureDetector(
                            onTap: () {
                              CircleGuiHelper.showPreviewImage(context, image: widget.circle.imageUrl);
                            },
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.network('${widget.circle.imageUrl}'),
                            )
                        )
                        : const SizedBox(),
                    widget.circle.videoPoster != null
                        ? FittedBox(
                            fit: BoxFit.contain,
                            child: Image.network('${widget.circle.videoPoster}'),
                          )
                        : const SizedBox(),
                    _buildActions(widget.circle),
                    Text("サークルID: ${widget.circle.id}"),
                    Text("リフライ先: ${widget.circle.reflew_name}"),
                    Text("リプライ先: ${widget.circle.replyed_to}"),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 2,
                    ),
                    TextField(
                      controller: replyTextFieldController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "返信をポスト",
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (replyTextFieldController.text.isNotEmpty) {
                          String text = replyTextFieldController.text;
                          replyTextFieldController.text = "";
                          bool isPosted = await widget.circle.reply(text);
                          if (isPosted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('返信がポストされました。')),
                            );
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('返信できませんでした。')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('本文は空欄であってはいけません。')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'ポスト',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 2,
                    ),
                    // List of replies
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: FutureBuilder<List<Circle>>(
                        future: widget.circle.getReplys(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const SizedBox();
                          } else {
                            final circles = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: circles.length,
                              itemBuilder: (context, index) {
                                final c = circles[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                                  minVerticalPadding: 8.0 * 0.2,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _buildCircleAvatar(context, c),
                                          const SizedBox(width: 8),
                                          _buildUserInfo(c),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text.rich(TextAgent.generate(c.content, context)),
                                      _buildActions(c),
                                      const Divider(
                                        color: Colors.black,
                                        thickness: 1,
                                        height: 2,
                                      ),
                                    ],
                                  ),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CircleDetailPage(circle: c),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
