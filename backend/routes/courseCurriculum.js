const express = require('express');
const router = express.Router();
const courseCurriculumController = require('../controllers/courseCurriculumController');

router.post('/course-curriculum', courseCurriculumController.createCurriculum);
router.get('/curriculum/:courseId', courseCurriculumController.getCurriculumByCourseId);
module.exports = router;