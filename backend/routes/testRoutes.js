const express = require('express');
const router = express.Router();
const { testController, upload: testUpload } = require('../controllers/testController');
const { testPartController} = require('../controllers/testPartController');
const { testQuestionController, upload: testQuestionUpload } = require('../controllers/testQuestionController');
const { testCommentController } = require('../controllers/testCommentController');
const { practiceController } = require('../controllers/practiceController');
const { fullTestController } = require('../controllers/fullTestController');
const { examTypeTagsController } = require('../controllers/examTypeTagsController');
const { userTestAttemptController } = require('../controllers/userTestAttemptController');
const authMiddleware = require('../middleware/auth');

router.get('/getAllTests', testController.getAllTests);
router.get('/getTest/:id', testController.getTestById);
router.get('/getTestDetail/:id', testController.getTestDetail);

// Test CRUD
router.post('/createTest', authMiddleware, testUpload, testController.createTest);
router.put('/updateTest/:id', authMiddleware, testUpload, testController.updateTest);
router.delete('/deleteTest/:id', authMiddleware, testController.deleteTest);

// TestPart CRUD
router.post('/createTestPart', authMiddleware, testPartController.createTestPart);
router.put('/updateTestPart/:id', authMiddleware, testPartController.updateTestPart);
router.delete('/deleteTestPart/:id', authMiddleware, testPartController.deleteTestPart);

// Question CRUD
router.post('/createQuestion', authMiddleware, testQuestionUpload, testQuestionController.createQuestion);
router.put('/updateQuestion/:id', authMiddleware, testQuestionUpload, testQuestionController.updateQuestion);
router.delete('/deleteQuestion/:id', authMiddleware, testQuestionController.deleteQuestion);

// Các route khác giữ nguyên
router.post('/addComment', authMiddleware, testCommentController.addComment);
router.put('/updateComment/:id', authMiddleware, testCommentController.updateComment);
router.delete('/deleteComment/:id', authMiddleware, testCommentController.deleteComment);

router.post('/startPractice', authMiddleware, practiceController.startPractice);
router.post('/submitPractice', authMiddleware, practiceController.submitPractice);
router.get('/getPracticeResult/:attemptId', authMiddleware, practiceController.getPracticeResult);
router.get('/restorePractice/:testId', authMiddleware, practiceController.restorePractice);
router.post('/savePractice', authMiddleware, practiceController.savePractice);

router.post('/startFullTest', authMiddleware, fullTestController.startFullTest);
router.post('/submitFullTest', authMiddleware, fullTestController.submitFullTest);
router.get('/getFullTestResult/:attemptId', authMiddleware, fullTestController.getFullTestResult);

router.post('/createExamTypeTags', authMiddleware, examTypeTagsController.createExamTypeTags);
router.get('/getExamTypeTags/:examType', authMiddleware, examTypeTagsController.getExamTypeTags);
router.delete('/deleteExamTypeTags/:examType', authMiddleware, examTypeTagsController.deleteExamTypeTags);

router.get('/getUserTestAttempts/:testId', authMiddleware, userTestAttemptController.getUserTestAttempts);
router.get('/getAllUserTestAttempts', authMiddleware, userTestAttemptController.getAllUserTestAttempts);
router.get('/getTestStatistics', authMiddleware, userTestAttemptController.getTestStatistics);
router.get('/getAllExamTypes', authMiddleware, examTypeTagsController.getAllExamTypes);

module.exports = router;