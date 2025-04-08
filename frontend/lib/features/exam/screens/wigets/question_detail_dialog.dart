import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:get/get.dart';
import '../wigets/audio_player.dart';

class QuestionDetailDialog extends StatefulWidget {
  final Map<String, dynamic> question;
  final String testTitle;
  final int questionNumber;

  const QuestionDetailDialog({
    super.key,
    required this.question,
    required this.testTitle,
    required this.questionNumber,
  });

  @override
  State<QuestionDetailDialog> createState() => _QuestionDetailDialogState();
}

class _QuestionDetailDialogState extends State<QuestionDetailDialog> {
  final GlobalKey<AudioPlayerWidgetState> _audioPlayerKey =
      GlobalKey<AudioPlayerWidgetState>();
  bool _isExplanationExpanded = false;
  bool _isTranscriptExpanded = false;

  @override
  Widget build(BuildContext context) {
    final userAnswer = widget.question['userAnswer'];
    final correctAnswer = widget.question['correctAnswer'] ?? 'Không có đáp án';
    final isCorrect = userAnswer == correctAnswer;
    final isUnanswered = userAnswer == null;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đáp án chi tiết #${widget.questionNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _audioPlayerKey.currentState?.stopAudio();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.testTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.question['content'] != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            widget.question['content'],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (widget.question['audioUrl'] != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AudioPlayerWidget(
                            key: _audioPlayerKey,
                            audioUrl: ApiConstants.getUrl(
                                widget.question['audioUrl']),
                          ),
                        ),
                      if (widget.question['imageUrl'] != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CachedNetworkImage(
                            imageUrl: ApiConstants.getUrl(
                                widget.question['imageUrl']),
                            httpHeaders: ApiConstants.getHeaders(isImage: true),
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      if (widget.question['transcript'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transcript:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isTranscriptExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isTranscriptExpanded =
                                          !_isTranscriptExpanded;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_isTranscriptExpanded)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.question['transcript'],
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                          ],
                        ),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: Text(
                                '${widget.questionNumber}',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...widget.question['options'].entries.map((option) {
                        final isOptionCorrect = option.key == correctAnswer;
                        final isUserChoice = option.key == userAnswer;
                        Color textColor = Colors.black;
                        Color? backgroundColor;

                        if (isUserChoice && isCorrect) {
                          textColor = Colors.green;
                          backgroundColor = Colors.green[50];
                        } else if (isUserChoice && !isCorrect) {
                          textColor = Colors.red;
                          backgroundColor = Colors.red[50];
                        }

                        return Padding(
                          padding: const EdgeInsets.only(left: 12.0, bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${option.key}: ${option.value}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isOptionCorrect && !isUnanswered
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[300]!),
                        ),
                        child: Text(
                          'Đáp án đúng: $correctAnswer',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Giải thích chi tiết đáp án:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isExplanationExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                            ),
                            onPressed: () {
                              setState(() {
                                _isExplanationExpanded =
                                    !_isExplanationExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isExplanationExpanded)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.question['explanation'] ??
                                'Không có giải thích.',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _audioPlayerKey.currentState?.stopAudio();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Đóng',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showQuestionDetailDialog(
    Map<String, dynamic> question, String testTitle, int questionNumber) {
  showDialog(
    context: Get.context!,
    builder: (context) => QuestionDetailDialog(
      question: question,
      testTitle: testTitle,
      questionNumber: questionNumber,
    ),
  );
}
