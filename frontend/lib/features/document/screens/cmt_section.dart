import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/features/document/model/cmt_model.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:get/get.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:intl/intl.dart';

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
  Map<int, int> visibleDepth = {}; // Độ sâu hiển thị cho mỗi comment parent
  int visibleParentCount = 5; // Số comment parent hiển thị ban đầu

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
          for (var comment in comments.where((c) => c.parentId == null)) {
            visibleDepth[comment.id] = 2; // Hiển thị đến cấp 2 ban đầu
          }
        });
      } else {
        log('Loi khi load comment: ${response.statusCode}');
      }
    } catch (e) {
      log("Loi: $e");
    }
  }

  Future<void> _addComment(String text, {int? parentId}) async {
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
      if (parentId != null) 'parentId': parentId,
    });

    try {
      final response =
          await http.post(url, headers: ApiConstants.getHeaders(), body: body);
      if (response.statusCode == 201) {
        _commentController.clear();
        setState(() => replyingToCommentId = null);
        fetchComments();
      } else {
        log("Lỗi gửi comment: ${response.statusCode}");
      }
    } catch (e) {
      log("Lỗi gửi comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalParentComments =
        comments.where((c) => c.parentId == null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const TSectionHeading(
          title: 'Bình luận',
          showActionButton: false,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: "Chia sẻ cảm nghĩ của bạn...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () => _addComment(_commentController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Gửi', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (comments.isEmpty)
          const Text("Chưa có bình luận nào.")
        else ...[
          // Hiển thị comment parent
          ...comments
              .where((c) => c.parentId == null)
              .take(visibleParentCount)
              .map((comment) => _buildComment(comment)),
          // Nút "Xem thêm" hoặc "Thu gọn" cho comment parent
          if (totalParentComments > 5) // Chỉ hiển thị nút nếu có hơn 5 comment
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (visibleParentCount >= totalParentComments) {
                      // Thu gọn về 5 comment nếu đã hiển thị hết
                      visibleParentCount = 5;
                    } else {
                      // Mở rộng thêm 5 comment, không vượt quá tổng số
                      visibleParentCount = (visibleParentCount + 5)
                          .clamp(5, totalParentComments);
                    }
                  });
                },
                child: Text(
                  visibleParentCount >= totalParentComments
                      ? 'Thu gọn bình luận'
                      : 'Xem thêm bình luận',
                  style: const TextStyle(color: Color(0xFF00A2FF)),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildComment(Comment comment, {int level = 0}) {
    final replyController = TextEditingController();
    const maxReplies = 5;
    const maxDepthLimit = 5; // Giới hạn độ sâu tối đa

    final utcDate = DateTime.parse(comment.date); // Parse từ UTC
    final vietnamDate =
        utcDate.add(const Duration(hours: 7)); // Chuyển sang UTC+7
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final formattedDate = dateFormat.format(vietnamDate);

    // Tính độ sâu tối đa của replies
    int getMaxDepth(List<Comment> replies, int currentDepth) {
      if (replies.isEmpty) return currentDepth;
      return replies
          .map((r) => getMaxDepth(r.replies, currentDepth + 1))
          .reduce((a, b) => a > b ? a : b);
    }

    // Lọc replies theo độ sâu hiển thị
    List<Comment> filterRepliesByDepth(List<Comment> replies, int maxDepth) {
      return replies.map((reply) {
        if (level + 1 >= maxDepth) {
          return Comment(
            id: reply.id,
            userId: reply.userId,
            username: reply.username,
            fullName: reply.fullName,
            content: reply.content,
            date: reply.date,
            avatarUrl: reply.avatarUrl,
            parentId: reply.parentId,
            replies: [],
          );
        }
        return Comment(
          id: reply.id,
          userId: reply.userId,
          username: reply.username,
          fullName: reply.fullName,
          content: reply.content,
          date: reply.date,
          avatarUrl: reply.avatarUrl,
          parentId: reply.parentId,
          replies: filterRepliesByDepth(reply.replies, maxDepth),
        );
      }).toList();
    }

    final currentDepth = visibleDepth[comment.id] ?? 2;
    final visibleReplies =
        filterRepliesByDepth(comment.replies, currentDepth + level + 1);
    final maxDepth = getMaxDepth(comment.replies, 0);

    return Container(
      margin: EdgeInsets.only(left: level * 15.0, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: comment.avatarUrl != null
                    ? NetworkImage(
                        ApiConstants.getUrl(comment.avatarUrl!),
                        headers: ApiConstants.getHeaders(isImage: true),
                      )
                    : const AssetImage(TImages.user),
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: (error, stackTrace) {
                  log('Error loading avatar: $error');
                },
              ),
              Text(comment.username),
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content),
          if (level < maxDepthLimit - 1 && comment.replies.length < maxReplies)
            TextButton(
              onPressed: () => setState(() {
                replyingToCommentId =
                    replyingToCommentId == comment.id ? null : comment.id;
              }),
              child: Text(
                replyingToCommentId == comment.id ? 'Hủy' : 'Trả lời',
                style: const TextStyle(color: Color(0xFF00A2FF)),
              ),
            )
          else if (level >= maxDepthLimit - 1)
            const Text(
              'Đã đạt độ sâu tối đa',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )
          else
            const Text(
              'Đã đạt tối đa 5 trả lời',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          if (replyingToCommentId == comment.id)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - (level * 15.0 + 32),
                height: 120,
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: InputDecoration(
                          hintText: "Trả lời bình luận...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _addComment(replyController.text,
                            parentId: comment.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text('Gửi',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (visibleReplies.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: visibleReplies
                    .map((reply) => _buildComment(reply, level: level + 1))
                    .toList(),
              ),
            ),
          if (comment.parentId == null &&
              maxDepth >= 3 &&
              currentDepth < maxDepth)
            TextButton(
              onPressed: () {
                setState(() {
                  visibleDepth[comment.id] =
                      (visibleDepth[comment.id] ?? 2) + 2;
                });
              },
              child: const Text(
                'Xem thêm replies sâu hơn',
                style: TextStyle(color: Color(0xFF00A2FF)),
              ),
            ),
          const Divider(),
        ],
      ),
    );
  }
}
