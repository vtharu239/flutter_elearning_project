class CourseCurriculumItem {
  final String section;
  final List<Lesson> lessons;
  final int lessonCount;

  CourseCurriculumItem({
    required this.section,
    required this.lessons,
    required this.lessonCount,
  });

  factory CourseCurriculumItem.fromJson(Map<String, dynamic> json) {
    return CourseCurriculumItem(
      section: json['section'],
      lessons: (json['lessons'] as List)
          .map((lesson) => Lesson.fromJson(lesson))
          .toList(),
      lessonCount: json['lessonCount'],
    );
  }
}

class Lesson {
  final int id;
  final String lesson;
  final String? description; // Add this
  final List<SubItem> subItems;

  Lesson({
    required this.id,
    required this.lesson,
    this.description, // Add this
    required this.subItems,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      lesson: json['lesson'],
      description: json['description'], // Add this
      subItems: (json['subItems'] as List)
          .map((subItem) => SubItem.fromJson(subItem))
          .toList(),
    );
  }
}

class SubItem {
  final String name;
  final List<VocabularyWord> vocabularyWords;

  SubItem({
    required this.name,
    required this.vocabularyWords,
  });

  factory SubItem.fromJson(Map<String, dynamic> json) {
    return SubItem(
      name: json['name'],
      vocabularyWords: (json['vocabularyWords'] as List)
          .map((word) => VocabularyWord.fromJson(word))
          .toList(),
    );
  }
}

class VocabularyWord {
  final String word;
  final String? pronunciationUK;
  final String? pronunciationUS;
  final String definition;
  final String? explanation;
  final List<Example> examples;

  VocabularyWord({
    required this.word,
    this.pronunciationUK,
    this.pronunciationUS,
    required this.definition,
    this.explanation,
    required this.examples,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      word: json['word'],
      pronunciationUK: json['pronunciationUK'],
      pronunciationUS: json['pronunciationUS'],
      definition: json['definition'],
      explanation: json['explanation'],
      examples: (json['examples'] as List)
          .map((example) => Example.fromJson(example))
          .toList(),
    );
  }
}

class Example {
  final String sentence;
  final String translation;

  Example({
    required this.sentence,
    required this.translation,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      sentence: json['sentence'],
      translation: json['translation'],
    );
  }
}
