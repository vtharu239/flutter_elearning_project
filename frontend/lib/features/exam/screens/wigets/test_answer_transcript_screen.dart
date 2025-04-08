import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';

class TestAnswerTranscriptScreen extends StatefulWidget {
  final Map<String, dynamic> test;

  const TestAnswerTranscriptScreen({super.key, required this.test});

  @override
  TestAnswerTranscriptScreenState createState() =>
      TestAnswerTranscriptScreenState();
}

class TestAnswerTranscriptScreenState
    extends State<TestAnswerTranscriptScreen> {
  int currentPartIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};
  final Map<String, bool> _transcriptExpandedStates = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int getQuestionNumber(int partIndex, int questionIndex) {
    int questionNumber = 0;
    for (int i = 0; i < partIndex; i++) {
      questionNumber += (widget.test['Parts'][i]['Questions'].length as int);
    }
    return questionNumber + questionIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    final parts = List<Map<String, dynamic>>.from(widget.test['Parts']);
    final currentPart = parts[currentPartIndex];
    final questions = List<Map<String, dynamic>>.from(currentPart['Questions']);
    final isListeningPart =
        currentPart['partType']?.toLowerCase().contains('listening') ?? false;

    _questionKeys.clear();
    for (int i = 0; i < questions.length; i++) {
      _questionKeys[i] = GlobalKey();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đáp án/Transcript: ${widget.test['title']}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 8.0),
              child: Row(
                children: parts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final part = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        part['title'],
                        style: TextStyle(
                          color: currentPartIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      selected: currentPartIndex == index,
                      selectedColor: const Color(0xFF00A2FF),
                      backgroundColor: Colors.grey[200],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            currentPartIndex = index;
                            _scrollController.jumpTo(0);
                          });
                        }
                      },
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionId = question['id'].toString();
                final questionNumber =
                    getQuestionNumber(currentPartIndex, index);
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
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  question['transcript'],
                                  style: const TextStyle(fontSize: 15),
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
                    builder: (context) => TestAnswerReviewScreen(
                      allParts: parts,
                    ),
                  ),
                ).then((result) {
                  if (result != null) {
                    setState(() {
                      currentPartIndex = result['partIndex'];
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

// Review Screen cho TestAnswerTranscriptScreen
class TestAnswerReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allParts;

  const TestAnswerReviewScreen({super.key, required this.allParts});

  int getQuestionNumber(int partIndex, int questionIndex) {
    int questionNumber = 0;
    for (int i = 0; i < partIndex; i++) {
      questionNumber += (allParts[i]['Questions'].length as int);
    }
    return questionNumber + questionIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review câu hỏi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: allParts.length,
        itemBuilder: (context, partIndex) {
          final part = allParts[partIndex];
          final questions = List<Map<String, dynamic>>.from(part['Questions']);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${part['title']} (${questions.length} câu)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding:
                    const EdgeInsets.only(right: 12.0, top: 12.0, bottom: 12.0),
                itemCount: questions.length,
                itemBuilder: (context, questionIndex) {
                  final questionNumber =
                      getQuestionNumber(partIndex, questionIndex);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'partIndex': partIndex,
                        'questionIndex': questionIndex,
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
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
            ],
          );
        },
      ),
    );
  }
}
