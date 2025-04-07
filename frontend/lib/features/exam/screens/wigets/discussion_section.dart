import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'dart:developer';

class DiscussionSection extends StatefulWidget {
  final List<dynamic> comments;
  final Future<void> Function(String) onAddComment;

  const DiscussionSection({
    super.key,
    required this.comments,
    required this.onAddComment,
  });

  @override
  State<DiscussionSection> createState() => _DiscussionSectionState();
}

class _DiscussionSectionState extends State<DiscussionSection> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleAddComment() async {
    try {
      await widget.onAddComment(controller.text);
      if (mounted) {
        controller.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bình luận',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Chia sẻ cảm nghĩ của bạn ...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _handleAddComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Gửi', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
            _buildCommentList(widget.comments),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList(List<dynamic> comments) {
    return Column(
      children: [
        ...comments.map((comment) => _buildComment(
              comment['User']['username'],
              comment['createdAt'].substring(0, 10),
              comment['content'],
              comment['User']['avatarUrl'],
            )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Xem thêm', style: TextStyle(color: Colors.blue)),
          ),
        ),
      ],
    );
  }

  Widget _buildComment(
      String username, String date, String content, String? avatarUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                backgroundImage: avatarUrl != null
                    ? NetworkImage(
                        ApiConstants.getUrl(avatarUrl),
                        headers: ApiConstants.getHeaders(isImage: true),
                      )
                    : const AssetImage(TImages.user),
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: (error, stackTrace) {
                  log('Error loading avatar: $error');
                },
              ),
              Text(username),
              Text(date, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
          TextButton(onPressed: () {}, child: const Text('Trả lời')),
          const Divider(),
        ],
      ),
    );
  }
}
