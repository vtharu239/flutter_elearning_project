// controllers/categoryController.js
const { Category, Course } = require('../models');

const categoryController = {
    // GET all categories
    getAllCategories: async (req, res) => {
        try {
            const categories = await Category.findAll({
                include: [{
                    model: Course,
                    as: 'Courses',
                    attributes: ['id', 'title']
                }]
            });
            res.json(categories);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server!', error: error.message });
        }
    },

    // GET single category by ID
    getCategory: async (req, res) => {
        try {
            const category = await Category.findByPk(req.params.id, {
                include: [{
                    model: Course,
                    as: 'Courses',
                    attributes: ['id', 'title']
                }]
            });
            if (!category) {
                return res.status(404).json({ message: 'Không tìm thấy danh mục' });
            }
            res.json(category);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server!', error: error.message });
        }
    },

    // POST create category
    createCategory: async (req, res) => {
        try {
            const { name } = req.body;
            const category = await Category.create({ name });
            res.status(201).json(category);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server!', error: error.message });
        }
    },

    // PUT update category
    updateCategory: async (req, res) => {
        try {
            const { name } = req.body;
            const category = await Category.findByPk(req.params.id);
            if (!category) {
                return res.status(404).json({ message: 'Không tìm thấy danh mục' });
            }
            await category.update({ name });
            res.json(category);
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server!', error: error.message });
        }
    },

    // DELETE category
    deleteCategory: async (req, res) => {
        try {
            const category = await Category.findByPk(req.params.id);
            if (!category) {
                return res.status(404).json({ message: 'Không tìm thấy danh mục' });
            }
            await category.destroy();
            res.json({ message: 'Xóa danh mục thành công' });
        } catch (error) {
            res.status(500).json({ message: 'Lỗi server!', error: error.message });
        }
    }
};

module.exports = categoryController;