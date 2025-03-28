
const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');

router.get('/getAllCategories', categoryController.getAllCategories);
router.get('/getCategory/:id', categoryController.getCategory);
router.post('/createCategory', categoryController.createCategory);
router.put('/updateCategory/:id', categoryController.updateCategory);
router.delete('/deleteCategory/:id', categoryController.deleteCategory);

module.exports = router;