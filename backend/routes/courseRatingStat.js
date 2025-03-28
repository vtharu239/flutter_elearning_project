const express = require('express');
const router = express.Router();
const courseRatingStatController = require('../controllers/courseRatingStatController');

router.post('/course-rating-stats', courseRatingStatController.createRatingStat);
router.get('/rating-stats/:courseId', courseRatingStatController.getRatingStatsByCourseId);

module.exports = router;