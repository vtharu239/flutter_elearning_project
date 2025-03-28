
const express = require('express');
const router = express.Router();
const courseController = require('../controllers/courseController');

router.get('/getAllCourses', courseController.getCourses);
router.get('/getCourseById/:id', courseController.getCourseById);
router.post('/createCourse', courseController.createCourse);
router.put('/updateCourse/:id', courseController.updateCourse);
router.delete('/deleteCourse/:id', courseController.deleteCourse);

module.exports = router;
