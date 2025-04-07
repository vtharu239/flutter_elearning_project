const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/docCategoryController');

router.get('/categories', categoryController.getCategories);
router.post('/categories', categoryController.createCategory);

module.exports = router;
