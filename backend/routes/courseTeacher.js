const express = require('express');
const router = express.Router();
const courseTeacherController = require('../controllers/courseTeacherController');

router.post('/course-teachers', courseTeacherController.createTeacher);
router.get('/teachers/:courseId', courseTeacherController.getTeachersByCourseId);
module.exports = router;