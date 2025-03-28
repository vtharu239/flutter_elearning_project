const express = require('express');
const router = express.Router();
const courseObjectiveController = require('../controllers/courseObjectiveController');

router.post('/course-objectives', courseObjectiveController.createObjective);

router.get('/objectives/:courseId', courseObjectiveController.getObjectivesByCourseId);

module.exports = router;