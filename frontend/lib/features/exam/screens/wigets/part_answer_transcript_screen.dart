import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';

class PartAnswerTranscriptScreen extends StatefulWidget {
  final Map<String, dynamic> part;

  const PartAnswerTranscriptScreen({super.key, required this.part});

  @override
  PartAnswerTranscriptScreenState createState() =>
      PartAnswerTranscriptScreenState();
}

class PartAnswerTranscriptScreenState
    extends State<PartAnswerTranscriptScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};
  final Map<String, bool> _transcriptExpandedStates = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    final questions = List<Map<String, dynamic>>.from(widget.part['Questions']);
    final isListeningPart =
        widget.part['partType']?.toLowerCase().contains('listening') ?? false;

    _questionKeys.clear();
    for (int i = 0; i < questions.length; i++) {
      _questionKeys[i] = GlobalKey();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đáp án/Transcript: ${widget.part['title']}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionId = question['id'].toString();
                final questionNumber = index + 1; // Số thứ tự trong Part
                _transcriptExpandedStates[questionId] ??= false;

                return Container(
                  key: _questionKeys[index],
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (question['imageUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl:
                                  ApiConstants.getUrl(question['imageUrl']),
                              httpHeaders:
                                  ApiConstants.getHeaders(isImage: true),
                              height: 200,
                              width: 400,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      if (isListeningPart && question['transcript'] != null)
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
                                    _transcriptExpandedStates[questionId]!
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _transcriptExpandedStates[questionId] =
                                          !_transcriptExpandedStates[
                                              questionId]!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_transcriptExpandedStates[questionId]!)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  question['transcript'],
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: darkMode
                                          ? Colors.black
                                          : Colors.white),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                '$questionNumber',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Đáp án đúng: ${question['answer']}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PartAnswerReviewScreen(
                      part: widget.part,
                    ),
                  ),
                ).then((result) {
                  if (result != null) {
                    setState(() {
                      final questionIndex = result['questionIndex'] as int;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final targetKey = _questionKeys[questionIndex];
                        if (targetKey?.currentContext != null) {
                          final RenderBox renderBox = targetKey!.currentContext!
                              .findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(Offset.zero,
                              ancestor: context.findRenderObject());
                          final offset =
                              position.dy + _scrollController.offset - 100;
                          _scrollController.animateTo(
                            offset,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Review',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Review Screen cho PartAnswerTranscriptScreen
class PartAnswerReviewScreen extends StatelessWidget {
  final Map<String, dynamic> part;

  const PartAnswerReviewScreen({super.key, required this.part});

  @override
  Widget build(BuildContext context) {
    final questions = List<Map<String, dynamic>>.from(part['Questions']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review câu hỏi'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${part['title']} (${questions.length} câu)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: questions.length,
              itemBuilder: (context, questionIndex) {
                final questionNumber = questionIndex + 1;
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, {
                      'questionIndex': questionIndex,
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:  Colors.white,
                      // color: Colors.blue,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '$questionNumber',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
