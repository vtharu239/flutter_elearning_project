const { CourseCurriculum, LessonSubItem, VocabularyWord } = require('../models');

const courseCurriculumController = {
  createCurriculum: async (req, res) => {
    try {
      const { courseId, section, lesson, subItems } = req.body;

      if (!courseId || !section || !lesson) {
        return res.status(400).json({ message: 'Missing required fields: courseId, section, and lesson are required.' });
      }

      const curriculum = await CourseCurriculum.create({ courseId, section, lesson });

      if (subItems && subItems.length > 0) {
        const subItemPromises = subItems.map(async (subItemData) => {
          const subItem = await LessonSubItem.create({
            curriculumId: curriculum.id,
            subItem: subItemData.name,
          });

          if (subItemData.vocabularyWords && subItemData.vocabularyWords.length > 0) {
            const wordPromises = subItemData.vocabularyWords.map(word =>
              VocabularyWord.create({
                subItemId: subItem.id,
                word: word.word,
                pronunciationUK: word.pronunciationUK,
                pronunciationUS: word.pronunciationUS,
                definition: word.definition,
                explanation: word.explanation,
                examples: word.examples,
              })
            );
            await Promise.all(wordPromises);
          }
        });
        await Promise.all(subItemPromises);
      }

      res.status(201).json(await CourseCurriculum.findByPk(curriculum.id, {
        include: [
          {
            model: LessonSubItem,
            as: 'SubItems',
            include: [{ model: VocabularyWord, as: 'VocabularyWords' }],
          },
        ],
      }));
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  getCurriculumByCourseId: async (req, res) => {
    try {
      const { courseId } = req.params;
      const curriculumItems = await CourseCurriculum.findAll({
        where: { courseId },
        include: [
          {
            model: LessonSubItem,
            as: 'SubItems',
            include: [{ model: VocabularyWord, as: 'VocabularyWords' }],
          },
        ],
        order: [['id', 'ASC']],
      });

      const groupedItems = curriculumItems.reduce((acc, item) => {
        const section = item.section;
        if (!acc[section]) {
          acc[section] = [];
        }
        acc[section].push({
          id: item.id,
          lesson: item.lesson,
          subItems: item.SubItems.map(sub => ({
            name: sub.subItem,
            vocabularyWords: sub.VocabularyWords.map(word => ({
              word: word.word,
              pronunciationUK: word.pronunciationUK,
              pronunciationUS: word.pronunciationUS,
              definition: word.definition,
              explanation: word.explanation,
              examples: word.examples,
            })),
          })),
        });
        return acc;
      }, {});

      const formattedItems = Object.keys(groupedItems).map(section => ({
        section,
        lessons: groupedItems[section],
        lessonCount: groupedItems[section].length,
      }));

      res.status(200).json(formattedItems);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
};

module.exports = courseCurriculumController;