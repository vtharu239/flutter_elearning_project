const express = require('express');
const router = express.Router();
const courseReviewController = require('../controllers/courseReviewController');

router.post('/course-reviews', courseReviewController.createReview);
router.get('/reviews/:courseId', courseReviewController.getReviewsByCourseId);
module.exports = router;