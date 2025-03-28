const { Test, TestPart, Question, UserTestAttempt } = require('../models');

const fullTestController = {
  startFullTest: async (req, res) => {
    try {
      const { testId } = req.body;
      const userId = req.user.userId;

      const test = await Test.findByPk(testId, {
        include: [{ model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions' }] }],
      });
      if (!test) return res.status(404).json({ message: 'Không tìm thấy bài test!' });

      const attemptId = `temp-${Date.now()}-${userId}`;

      res.status(201).json({
        attemptId: attemptId,
        fullAudioUrl: test.fullAudioUrl,
        testParts: test.Parts.map(part => ({
          id: part.id,
          title: part.title,
          partType: part.partType,
          audioUrl: part.audioUrl,
          questions: part.Questions.map(q => ({
            id: q.id,
            content: q.content,
            options: q.options,
            imageUrl: q.imageUrl,
          })),
        })),
        duration: test.duration,
      });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi bắt đầu Full Test!', error: error.message });
    }
  },

  submitFullTest: async (req, res) => {
    try {
      const { attemptId, answers, testId, startTime } = req.body;
      const userId = req.user.userId;

      const test = await Test.findByPk(testId, {
        include: [{ model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions' }] }],
      });
      if (!test) return res.status(404).json({ message: 'Không tìm thấy bài test!' });

      const startTimeDate = startTime ? new Date(startTime) : new Date();
      const submitTime = new Date();
      const completionTime = Math.floor((submitTime - startTimeDate) / 1000);

      const questions = test.Parts.flatMap(part => part.Questions);
      let correctCount = 0, skippedCount = 0;

      questions.forEach(q => {
        const userAnswer = answers[q.id];
        if (userAnswer === undefined || userAnswer === null) skippedCount++;
        else if (userAnswer === q.answer) correctCount++;
      });

      const scaledScore = test.examType === 'TOEIC' ? calculateToeicScaledScore(correctCount) : null;

      const attempt = await UserTestAttempt.create({
        userId,
        testId,
        answers,
        startTime: startTimeDate,
        submitTime,
        isSubmitted: true,
        correctCount,
        skippedCount,
        scaledScore,
        completionTime,
        isFullTest: true,
      });

      await Test.increment('testCount', { where: { id: testId } });
      res.json({ message: 'Nộp bài Full Test thành công!', attemptId: attempt.id });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi nộp bài Full Test!', error: error.message });
    }
  },

  getFullTestResult: async (req, res) => {
    try {
      const { attemptId } = req.params;
      const attempt = await UserTestAttempt.findByPk(attemptId, {
        include: [{ model: Test, as: 'Test', include: [{ model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions' }] }] }],
      });
      if (!attempt) return res.status(404).json({ message: 'Không tìm thấy bài làm!' });

      const questions = attempt.Test.Parts.flatMap(part => part.Questions);
      const totalQuestions = questions.length;
      const accuracy = (attempt.correctCount / totalQuestions) * 100;

      const result = {
        date: attempt.submitTime,
        totalQuestions,
        correctCount: attempt.correctCount,
        wrongCount: totalQuestions - attempt.correctCount - attempt.skippedCount,
        skippedCount: attempt.skippedCount,
        accuracy: accuracy.toFixed(2),
        completionTime: attempt.completionTime,
        scaledScore: attempt.scaledScore,
        questions: questions.map(q => ({
          id: q.id,
          content: q.content,
          options: q.options,
          userAnswer: attempt.answers[q.id] || null,
          correctAnswer: q.answer,
          transcript: q.transcript,
          explanation: q.explanation,
          tag: q.tag,
        })),
      };
      res.json(result);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lấy kết quả Full Test!', error: error.message });
    }
  },
};

const calculateToeicScaledScore = (correctCount) => {
  const listeningCorrect = Math.min(correctCount, 100);
  const readingCorrect = Math.max(0, correctCount - 100);
  const listeningScore = Math.round((listeningCorrect / 100) * 495);
  const readingScore = Math.round((readingCorrect / 100) * 495);
  return Math.min(990, listeningScore + readingScore);
};

module.exports = { fullTestController };