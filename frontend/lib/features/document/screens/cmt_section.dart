import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/cmt_model.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [
    Comment(
      username: "hanhphuong44",
      date: "Tháng 2. 17, 2025",
      content: "Tìm partner luyện nói hàng ngày chăm chỉ",
      replies: [
        Comment(
          username: "hanhphuong44",
          date: "Tháng 2. 17, 2025",
          content:
              "Band 5.5=60 cần lên 6.5, tháng sau thi rồi cần luyện hàng ngày",
        ),
        Comment(
          username: "luongsuong61",
          date: "Tháng 2. 25, 2025",
          content:
              "Bạn ơi bạn tìm được chưa nếu chưa liên hệ mình nha, mình cũng tháng sau thi :<",
        ),
      ],
    ),
    Comment(
      username: "ngocd2584",
      date: "Tháng 2. 21, 2025",
      content: "Bạn ơi bạn tìm được partner chưa ạ?",
    ),
    Comment(
      username: "nguyenhuong.2007vng",
      date: "Tháng 3. 02, 2025",
      content:
          "Mình thi 15/03 mình cần tìm partner ạ, mình học 12 sdt 0941042079 nhé",
    ),
    Comment(
      username: "ducanhhhh",
      date: "Tháng 3. 02, 2025",
      content: "T thi 16/3 nè, ông cùng t không",
    ),
  ];

  void _addComment(String text) {
    if (text.isNotEmpty) {
      setState(() {
        comments.insert(
            0, Comment(username: "Bạn", date: "Hôm nay", content: text));
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Bình luận",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        // Ô nhập bình luận
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Chia sẻ cảm nghĩ của bạn...",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

        // Danh sách bình luận
        ListView.builder(
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
      padding: EdgeInsets.only(left: level * 20.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                child: Text(comment.username[0].toUpperCase()),
              ),
              const SizedBox(width: 8),
              Text(
                comment.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                comment.date,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),

          // Nếu có trả lời thì hiển thị danh sách trả lời
          if (comment.replies.isNotEmpty)
            Column(
              children: comment.replies.map((reply) {
                return _buildComment(reply, level: level + 1);
              }).toList(),
            ),
        ],
      ),
    );
  }
}