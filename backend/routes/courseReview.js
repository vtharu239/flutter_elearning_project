const express = require('express');
const router = express.Router();
const courseReviewController = require('../controllers/courseReviewController');
const authMiddleware = require('../middleware/auth');
router.post('/course-reviews', authMiddleware, courseReviewController.createReview);
router.get('/reviews/:courseId', courseReviewController.getReviewsByCourseId);
module.exports = router;