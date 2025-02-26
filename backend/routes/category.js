const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

router.get('/getAllCategory', categoryController.getAllCategories);

module.exports = router;
