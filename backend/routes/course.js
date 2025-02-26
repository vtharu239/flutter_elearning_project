const express = require('express');
const router = express.Router();
const courseController = require('../controllers/courseController');

router.get('/getAllCourse', courseController.getCourses);
//https://clear-tomcat-informally.ngrok-free.app/getAllCourse
//
module.exports = router;
