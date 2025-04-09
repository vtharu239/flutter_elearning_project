const { UserTestAttempt, Test, TestPart, Question, sequelize } = require('../models');
const { Op } = require('sequelize');

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

  getAllUserTestAttempts: async (req, res) => {
    try {
      const userId = req.user.userId;
      const { page = 1, limit = 3 } = req.query; // Mặc định 3 bài test khác nhau/trang

      // Lấy danh sách testId duy nhất mà người dùng đã làm
      const distinctTestIds = await UserTestAttempt.findAll({
        attributes: [[sequelize.fn('DISTINCT', sequelize.col('testId')), 'testId']],
        where: { userId, isSubmitted: true },
        order: [['testId', 'ASC']],
        limit: parseInt(limit),
        offset: (page - 1) * parseInt(limit),
      });

      const testIds = distinctTestIds.map((item) => item.testId);
      const totalTests = await UserTestAttempt.count({
        distinct: true,
        col: 'testId',
        where: { userId, isSubmitted: true },
      });
      const totalPages = Math.ceil(totalTests / limit);

      if (testIds.length === 0) {
        return res.json({
          tests: [],
          totalPages,
          currentPage: parseInt(page),
        });
      }

      // Lấy tất cả bài làm của các testId đã chọn
      const attempts = await UserTestAttempt.findAll({
        where: {
          userId,
          testId: testIds,
          isSubmitted: true,
        },
        include: [
          {
            model: Test,
            as: 'Test',
            attributes: ['id', 'title', 'duration', 'totalQuestions'],
          },
        ],
        order: [['submitTime', 'DESC']],
      });

      // Nhóm dữ liệu theo testId
      const testsMap = {};
      for (const attempt of attempts) {
        const testId = attempt.testId;
        if (!testsMap[testId]) {
          testsMap[testId] = {
            testTitle: attempt.Test.title,
            attempts: [],
          };
        }

        let totalQuestions = attempt.Test.totalQuestions;
        if (!attempt.isFullTest) {
          const selectedParts = attempt.selectedParts ? JSON.parse(attempt.selectedParts) : [];
          const testParts = await TestPart.findAll({
            where: { id: selectedParts, testId },
            attributes: ['questionCount'],
          });
          totalQuestions = testParts.reduce((sum, part) => sum + part.questionCount, 0);
        }

        testsMap[testId].attempts.push({
          id: attempt.id,
          testId: attempt.testId,
          date: attempt.submitTime ? attempt.submitTime.toISOString().substring(0, 10) : 'N/A',
          correctCount: attempt.correctCount,
          wrongCount: attempt.wrongCount,
          skippedCount: attempt.skippedCount,
          totalQuestions,
          scaledScore: attempt.scaledScore,
          completionTime: attempt.completionTime,
          isFullTest: attempt.isFullTest,
          selectedParts: attempt.selectedParts,
        });
      }

      const formattedTests = Object.values(testsMap);

      res.json({
        tests: formattedTests,
        totalPages,
        currentPage: parseInt(page),
      });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lấy danh sách tất cả bài làm!', error: error.message });
    }
  },
  
  getTestStatistics: async (req, res) => {
    try {
      const userId = req.user.userId;
      const { examType = 'TOEIC', timeRange = '30 days' } = req.query;
  
      let days;
      switch (timeRange) {
        case '3 ngày': days = 3; break; // Điều chỉnh để khớp với frontend
        case '7 ngày': days = 7; break;
        case '30 ngày': days = 30; break;
        case '60 ngày': days = 60; break;
        case '90 ngày': days = 90; break;
        case '6 tháng': days = 180; break;
        case '1 năm': days = 365; break;
        default: days = null; // All
      }
  
      const startDate = days ? new Date(Date.now() - days * 24 * 60 * 60 * 1000) : null;
  
      const where = {
        userId,
        isSubmitted: true,
        ...(startDate ? { submitTime: { [Op.gte]: startDate } } : {}),
      };
  
      const attempts = await UserTestAttempt.findAll({
        where,
        include: [
          {
            model: Test,
            as: 'Test',
            where: { examType },
            include: [{ model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions' }] }],
          },
        ],
      });
  
      let totalCorrect = 0, totalWrong = 0, totalSkipped = 0, totalQuestions = 0;
      let totalTimeSeconds = 0, totalScaledScore = 0, testCount = 0;
      const partStats = { Listening: {}, Reading: {}, ...(examType === 'IELTS' ? { Writing: {}, Speaking: {} } : {}) };
      const dailyStats = {};
  
      for (const attempt of attempts) {
        testCount++;
        totalCorrect += attempt.correctCount;
        totalWrong += attempt.wrongCount;
        totalSkipped += attempt.skippedCount;
        totalQuestions += attempt.Test.totalQuestions;
        totalScaledScore += attempt.scaledScore || 0;
        
        const [h, m, s] = attempt.completionTime.split(':').map(Number);
        totalTimeSeconds += h * 3600 + m * 60 + s;
  
        const dateKey = attempt.submitTime.toISOString().substring(0, 10);
        if (!dailyStats[dateKey]) {
          dailyStats[dateKey] = { correct: 0, total: 0 };
        }
        dailyStats[dateKey].correct += attempt.correctCount;
        dailyStats[dateKey].total += attempt.Test.totalQuestions;
  
        attempt.Test.Parts.forEach(part => {
          const partType = part.partType.includes('Listening') ? 'Listening' : 
                          part.partType.includes('Reading') ? 'Reading' : 
                          part.partType.includes('Writing') ? 'Writing' : 'Speaking';
          if (!partStats[partType].testCount) {
            partStats[partType] = {
              testCount: 0,
              correct: 0,
              total: 0,
              timeSeconds: 0,
              scores: [],
            };
          }
          partStats[partType].testCount++;
          partStats[partType].correct += attempt.correctCount;
          partStats[partType].total += part.questionCount;
          partStats[partType].timeSeconds += totalTimeSeconds / attempt.Test.Parts.length;
          if (attempt.scaledScore) partStats[partType].scores.push(attempt.scaledScore);
        });
      }
  
      const avgTime = formatTimeToString(Math.round(totalTimeSeconds / (testCount || 1)));
      const avgScaledScore = testCount ? totalScaledScore / testCount : null;
      const avgAccuracy = totalQuestions ? (totalCorrect / totalQuestions) * 100 : 0;
  
      const response = {
        totalCorrect,
        totalWrong,
        totalSkipped,
        totalQuestions,
        avgCompletionTime: avgTime,
        avgScaledScore,
        avgAccuracy,
        testCount,
        partStats: Object.fromEntries(
          Object.entries(partStats).map(([type, stat]) => [
            type,
            {
              testCount: stat.testCount || 0,
              accuracy: stat.total ? (stat.correct / stat.total) * 100 : 0,
              avgTime: formatTimeToString(Math.round(stat.timeSeconds / (stat.testCount || 1))),
              avgScore: stat.scores.length ? stat.scores.reduce((a, b) => a + b, 0) / stat.scores.length : null,
              highestScore: stat.scores.length ? Math.max(...stat.scores) : null,
            }
          ])
        ),
        dailyStats: Object.entries(dailyStats).map(([date, stat]) => ({
          date,
          correct: stat.correct,
          total: stat.total,
        })), // Luôn trả về mảng, dù rỗng
      };
  
      res.json(response);
    } catch (error) {
      res.status(500).json({ message: 'Error fetching test statistics', error: error.message });
    }
  }
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