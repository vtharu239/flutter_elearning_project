const { UserTestAttempt, Test, TestPart } = require('../models');

const userTestAttemptController = {
  getUserTestAttempts: async (req, res) => {
    try {
      const { testId } = req.params;
      const userId = req.user.userId;

      const attempts = await UserTestAttempt.findAll({
        where: {
          userId,
          testId,
          isSubmitted: true, // Only fetch submitted attempts
        },
        include: [
          {
            model: Test,
            as: 'Test',
            attributes: ['id', 'title', 'duration', 'totalQuestions'],
          },
        ],
        order: [['submitTime', 'DESC']], // Sort by submission time, most recent first
      });

      const formattedAttempts = await Promise.all(
        attempts.map(async (attempt) => {
          const test = attempt.Test;
          let totalQuestions = test.totalQuestions;

          if (!attempt.isFullTest) {
            // For practice tests, calculate total questions based on selected parts
            const selectedParts = attempt.selectedParts ? JSON.parse(attempt.selectedParts) : [];
            const testParts = await TestPart.findAll({
              where: { id: selectedParts, testId },
              attributes: ['questionCount'],
            });
            totalQuestions = testParts.reduce((sum, part) => sum + part.questionCount, 0);
          }

          return {
            id: attempt.id,
            date: attempt.submitTime ? attempt.submitTime.toISOString().substring(0, 10) : 'N/A',
            correctCount: attempt.correctCount,
            wrongCount: attempt.wrongCount,
            skippedCount: attempt.skippedCount,
            totalQuestions,
            scaledScore: attempt.scaledScore,
            completionTime: attempt.completionTime, // Now in HH:mm:ss format
            isFullTest: attempt.isFullTest,
            selectedParts: attempt.selectedParts,
          };
        })
      );

      res.json({ attempts: formattedAttempts });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lấy danh sách bài làm!', error: error.message });
    }
  },
};

// helpers/timeHelper.js
const formatTimeToString = (seconds) => {
  const hours = Math.floor(seconds / 3600).toString().padLeft(2, '0');
  const minutes = Math.floor((seconds % 3600) / 60).toString().padLeft(2, '0');
  const secs = (seconds % 60).toString().padLeft(2, '0');
  return `${hours}:${minutes}:${secs}`;
};

// Add padLeft to String prototype if not already available
if (!String.prototype.padLeft) {
  String.prototype.padLeft = function (length, char = '0') {
    return char.repeat(Math.max(0, length - this.length)) + this;
  };
}

module.exports = { userTestAttemptController, formatTimeToString };