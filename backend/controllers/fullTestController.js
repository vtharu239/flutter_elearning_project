const { Test, TestPart, Question, UserTestAttempt } = require('../models');
const { formatTimeToString } = require('../controllers/userTestAttemptController');

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
          questions: part.Questions.map(q => ({
            id: q.id,
            content: q.content,
            options: q.options,
            imageUrl: q.imageUrl,
            // audioUrl is included but will be ignored in Full Test mode on the frontend
            audioUrl: q.audioUrl,
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
      const { attemptId, answers, testId, startTime, completionTime, duration } = req.body;
      const userId = req.user.userId;
  
      const test = await Test.findByPk(testId, {
        include: [{ model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions' }] }],
      });
      if (!test) return res.status(404).json({ message: 'Không tìm thấy bài test!' });
  
      const startTimeDate = startTime ? new Date(startTime) : new Date();
      const submitTime = new Date();
  
      const questions = test.Parts.flatMap(part => part.Questions);
      let correctCount = 0, skippedCount = 0, wrongCount = 0;
  
      questions.forEach(q => {
        const userAnswer = answers[q.id];
        if (userAnswer === undefined || userAnswer === null) skippedCount++;
        else if (userAnswer === q.answer) correctCount++;
        else wrongCount++;
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
        wrongCount,
        scaledScore,
        completionTime: formatTimeToString(completionTime || Math.floor((submitTime - startTimeDate) / 1000)), // Convert to HH:mm:ss
        isFullTest: true,
        duration: duration || test.duration || 0,
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
        include: [
          {
            model: Test,
            as: 'Test',
            attributes: ['id', 'title', 'examType', 'fullAudioUrl'],
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
  
      const parts = attempt.Test.Parts;
      const questions = parts.flatMap(part => part.Questions);
      const totalQuestions = questions.length;
      const accuracy = (attempt.correctCount / totalQuestions) * 100;
  
      const result = {
        testTitle: attempt.Test.title,
        examType: attempt.Test.examType,
        isFullTest: attempt.isFullTest,
        fullAudioUrl: attempt.Test.fullAudioUrl,
        parts: parts.map(part => ({
          id: part.id,
          title: part.title,
          Questions: part.Questions,
        })),
        date: attempt.submitTime,
        totalQuestions,
        correctCount: attempt.correctCount,
        wrongCount: attempt.wrongCount,
        skippedCount: attempt.skippedCount,
        accuracy: accuracy.toFixed(2),
        completionTime: attempt.completionTime,
        scaledScore: attempt.scaledScore,
        answers: attempt.answers,
        questions: questions.map(q => ({
          id: q.id,
          content: q.content,
          options: q.options,
          userAnswer: attempt.answers[q.id.toString()] || null,
          correctAnswer: q.answer,
          transcript: q.transcript,
          explanation: q.explanation,
          tag: q.tag,
          imageUrl: q.imageUrl,
          audioUrl: q.audioUrl,
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