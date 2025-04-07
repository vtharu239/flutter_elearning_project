import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/cmt_model.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:get/get.dart';

class CommentSection extends StatefulWidget {
  final int documentId;
  const CommentSection({super.key, required this.documentId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  bool isLoading = true;
  int? replyingToCommentId;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final url = Uri.parse(
        "${ApiConstants.baseUrl}/api/document-comments?documentId=${widget.documentId}");

    try {
      final response = await http.get(url, headers: ApiConstants.getHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          comments = data.map((e) => Comment.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        print('Loi khi load comment: ${response.statusCode}');
      }
    } catch (e) {
      print("Loi: $e");
    }
  }

  Future<void> _addComment(String text) async {
    if (text.isEmpty) return;

    final userId = Get.find<AuthController>().user.value?.id;
    if (userId == null) {
      Get.snackbar("Lỗi", "Bạn chưa đăng nhập!");
      return;
    }

    final url = Uri.parse("${ApiConstants.baseUrl}/api/document-comments");
    final body = json.encode({
      'documentId': widget.documentId,
      'userId': userId,
      'content': text,
      if (replyingToCommentId != null) 'parentId': replyingToCommentId,
    });

    try {
      final response =
          await http.post(url, headers: ApiConstants.getHeaders(), body: body);
      if (response.statusCode == 201) {
        _commentController.clear();
        setState(() => replyingToCommentId = null);
        fetchComments();
      } else {
        print("Lỗi gửi comment: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi gửi comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("Bình luận",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: replyingToCommentId != null
                      ? "Trả lời bình luận..."
                      : "Chia sẻ cảm nghĩ của bạn...",
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addComment(_commentController.text),
              child: const Text("Gửi"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : comments.isEmpty
                ? const Text("Chưa có bình luận nào.")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return _buildComment(comments[index]);
                    },
                  ),
      ],
    );
  }

  Widget _buildComment(Comment comment, {int level = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: level * 16.0, top: 12.0, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.purple.shade100,
                  child: Text(
                    comment.username[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        comment.date,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => replyingToCommentId = comment.id),
                  child: const Text("Trả lời", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content, style: const TextStyle(fontSize: 15)),
            if (comment.replies.isNotEmpty)
              Column(
                children: comment.replies
                    .map((reply) => _buildComment(reply, level: level + 1))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
