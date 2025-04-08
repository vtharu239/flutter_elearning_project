const { Test, TestPart, Question, UserTestAttempt } = require('../models');
const { formatTimeToString } = require('../controllers/userTestAttemptController');

const practiceController = {
  startPractice: async (req, res) => {
    try {
      const { testId, partIds, duration } = req.body;
      const userId = req.user.userId;

      const test = await Test.findByPk(testId);
      if (!test) return res.status(404).json({ message: 'Không tìm thấy bài test!' });

      const testParts = await TestPart.findAll({
        where: { id: partIds, testId },
        include: [{ model: Question, as: 'Questions' }],
      });
      if (testParts.length === 0) return res.status(400).json({ message: 'Không có phần nào được chọn!' });

      const attemptId = `temp-${Date.now()}-${userId}`;

      res.status(201).json({
        attemptId: attemptId,
        testParts: testParts.map(part => ({
          id: part.id,
          title: part.title,
          partType: part.partType,
          questions: part.Questions.map(q => ({
            id: q.id,
            content: q.content,
            options: q.options,
            imageUrl: q.imageUrl,
            audioUrl: q.audioUrl,
          })),
        })),
        duration: duration || null,
      });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi bắt đầu luyện tập!', error: error.message });
    }
  },

  submitPractice: async (req, res) => {
    try {
      const { attemptId, answers, testId, partIds, startTime, completionTime, duration } = req.body;
      const userId = req.user.userId;
  
      if (!testId) return res.status(400).json({ message: 'Thiếu testId!' });
  
      const test = await Test.findByPk(testId, {
        include: [{ model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions' }] }],
      });
      if (!test) return res.status(404).json({ message: 'Không tìm thấy bài test!' });
  
      const startTimeDate = startTime ? new Date(startTime) : new Date();
      const submitTime = new Date();
  
      const questions = test.Parts.flatMap(part => part.Questions);
      const totalQuestions = questions.length;
      let correctCount = 0, skippedCount = 0, wrongCount = 0;
  
      questions.forEach(q => {
        const userAnswer = answers[q.id];
        if (userAnswer === undefined || userAnswer === null) skippedCount++;
        else if (userAnswer === q.answer) correctCount++;
        else wrongCount++;
      });
  
      const attempt = await UserTestAttempt.create({
        userId,
        testId,
        answers,
        startTime: startTimeDate,
        submitTime,
        isSubmitted: true,
        correctCount,
        skippedCount,
        wrongCount,
        completionTime: formatTimeToString(completionTime || Math.floor((submitTime - startTimeDate) / 1000)), // Convert to HH:mm:ss
        isFullTest: false,
        selectedParts: JSON.stringify(partIds || []),
        duration: duration || 0,
      });
  
      await Test.increment('testCount', { where: { id: testId } });
      res.json({ message: 'Nộp bài thành công!', attemptId: attempt.id });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi nộp bài!', error: error.message });
    }
  },

  getPracticeResult: async (req, res) => {
    try {
      const { attemptId } = req.params;
      const attempt = await UserTestAttempt.findByPk(attemptId, {
        include: [
          {
            model: Test,
            as: 'Test',
            attributes: ['id', 'title', 'examType'],
            include: [
              {
                model: TestPart,
                as: 'Parts',
                include: [{ model: Question, as: 'Questions' }],
              },
            ],
          },
        ],
      });
      if (!attempt) return res.status(404).json({ message: 'Không tìm thấy bài làm!' });
  
      const selectedPartIds = attempt.selectedParts ? JSON.parse(attempt.selectedParts) : [];
      let parts = attempt.Test.Parts || [];
      let questions = parts.flatMap(part => part.Questions || []);
  
      if (!attempt.isFullTest && selectedPartIds.length > 0) {
        parts = parts.filter(part => selectedPartIds.includes(part.id));
        questions = parts.flatMap(part => part.Questions || []);
      }
  
      const totalQuestions = questions.length;
      const answers = attempt.answers || {};
      let correctCount = 0;
      let wrongCount = 0;
      let skippedCount = 0;
  
      questions.forEach(q => {
        const userAnswer = answers[q.id.toString()];
        if (userAnswer === undefined || userAnswer === null) {
          skippedCount++;
        } else if (userAnswer === q.answer) {
          correctCount++;
        } else {
          wrongCount++;
        }
      });
  
      const accuracy = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;
  
      const result = {
        testTitle: attempt.Test.title,
        examType: attempt.Test.examType,
        isFullTest: attempt.isFullTest,
        parts: parts.map(part => ({
          id: part.id,
          title: part.title,
          Questions: part.Questions || [],
        })),
        date: attempt.submitTime,
        totalQuestions,
        correctCount,
        wrongCount,
        skippedCount,
        accuracy: accuracy.toFixed(2),
        completionTime: attempt.completionTime,
        answers,
        questions: questions.map(q => ({
          id: q.id,
          content: q.content,
          options: q.options,
          userAnswer: answers[q.id.toString()] || null,
          correctAnswer: q.answer,
          transcript: q.transcript,
          explanation: q.explanation,
          tag: q.tag,
          audioUrl: q.audioUrl,
          imageUrl: q.imageUrl,
        })),
      };
      res.json(result);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lấy kết quả!', error: error.message });
    }
  },

  restorePractice: async (req, res) => {
    try {
      const { testId } = req.params;
      const userId = req.user.userId;
      const attempt = await UserTestAttempt.findOne({
        where: { userId, testId, isSubmitted: false },
        include: [{ model: Test, as: 'Test', include: [{ model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions' }] }] }],
      });
      if (!attempt) return res.status(404).json({ message: 'Không tìm thấy bài làm chưa hoàn thành!' });
  
      res.json({
        attemptId: attempt.id,
        testParts: attempt.Test.Parts.map(part => ({
          id: part.id,
          title: part.title,
          partType: part.partType,
          questions: part.Questions.map(q => ({
            id: q.id,
            content: q.content,
            options: q.options,
            userAnswer: attempt.answers[q.id] || null,
            imageUrl: q.imageUrl
          })),
        })),
        startTime: attempt.startTime,
      });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi khôi phục bài làm!', error: error.message });
    }
  },

  savePractice: async (req, res) => {
    try {
      const { attemptId, answers } = req.body;
      const attempt = await UserTestAttempt.findByPk(attemptId);
      if (!attempt || attempt.isSubmitted) return res.status(400).json({ message: 'Bài làm không tồn tại hoặc đã nộp!' });
      await attempt.update({ answers });
      res.json({ message: 'Lưu bài làm thành công!', attemptId });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lưu bài làm!', error: error.message });
    }
  }
};

module.exports = { practiceController };