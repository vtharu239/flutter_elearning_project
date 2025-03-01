const express = require('express');
const router = express.Router();
const { testController, upload } = require('../controllers/testController');
const authMiddleware = require('../middleware/auth');

router.get('/getAllTests', testController.getAllTests);
router.get('/getTest/:id', testController.getTestById);
router.get('/getTestDetail/:id', testController.getTestDetail);

// Test CRUD với upload ảnh
router.post('/createTest', authMiddleware, upload, testController.createTest);
router.put('/updateTest/:id', authMiddleware, upload, testController.updateTest);
router.delete('/deleteTest/:id', authMiddleware, testController.deleteTest);

// TestPart CRUD
router.post('/createTestPart', authMiddleware, testController.createTestPart);
router.put('/updateTestPart/:id', authMiddleware, testController.updateTestPart);
router.delete('/deleteTestPart/:id', authMiddleware, testController.deleteTestPart);

// Question CRUD
router.post('/createQuestion', authMiddleware, testController.createQuestion);
router.put('/updateQuestion/:id', authMiddleware, testController.updateQuestion);
router.delete('/deleteQuestion/:id', authMiddleware, testController.deleteQuestion);

// Comment CRUD với auth
router.post('/addComment', authMiddleware, testController.addComment);
router.put('/updateComment/:id', authMiddleware, testController.updateComment);
router.delete('/deleteComment/:id', authMiddleware, testController.deleteComment);

module.exports = router;