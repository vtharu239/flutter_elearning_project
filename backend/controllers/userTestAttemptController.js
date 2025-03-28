const { UserTestAttempt, Test, TestPart } = require('../models');

const userTestAttemptController = {
    getUserTestAttempts: async (req, res) => {
      try {
        const userId = req.user.userId; // Lấy từ middleware auth
        const { testId } = req.params; // Lấy testId từ params
  
        // Kiểm tra testId hợp lệ
        if (!testId || isNaN(testId)) {
          return res.status(400).json({ message: 'testId không hợp lệ!' });
        }
  
        const attempts = await UserTestAttempt.findAll({
          where: { userId, testId: parseInt(testId) },
          include: [{ model: Test, as: 'Test', include: [{ model: TestPart, as: 'Parts' }] }],
        });
  
        const formattedAttempts = await Promise.all(
          attempts.map(async (attempt) => {
            let totalQuestions;
            if (attempt.isFullTest) {
              // Full Test: Tổng số câu hỏi từ test.totalQuestions
              totalQuestions = attempt.Test.totalQuestions;
            } else {
              // Practice Mode: Tổng số câu hỏi từ các Part được chọn
              const selectedParts = attempt.selectedParts
                ? JSON.parse(attempt.selectedParts)
                : attempt.Test.Parts.map((part) => part.id); // Nếu không lưu selectedParts, lấy tất cả
              const parts = await TestPart.findAll({
                where: { id: selectedParts, testId: attempt.testId },
              });
              totalQuestions = parts.reduce((sum, part) => sum + part.questionCount, 0);
            }
  
            // Tính completionTime (tính bằng giây)
            const completionTime = attempt.submitTime && attempt.startTime
              ? Math.floor((new Date(attempt.submitTime) - new Date(attempt.startTime)) / 1000)
              : 0;
  
            return {
              id: attempt.id,
              date: attempt.startTime.toISOString().split('T')[0],
              correctCount: attempt.correctCount,
              wrongCount: totalQuestions - attempt.correctCount - attempt.skippedCount,
              skippedCount: attempt.skippedCount,
              scaledScore: attempt.scaledScore,
              completionTime: completionTime, // Thời gian hoàn thành (giây)
              totalQuestions: totalQuestions, // Tổng số câu hỏi
              isFullTest: attempt.isFullTest || false,
              selectedParts: attempt.selectedParts
            };
          })
        );
  
        res.json({ attempts: formattedAttempts });
      } catch (error) {
        res.status(500).json({ message: 'Lỗi khi lấy kết quả bài làm!', error: error.message });
      }
    },

};

module.exports = { userTestAttemptController };