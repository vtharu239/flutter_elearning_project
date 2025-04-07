// controllers/docCategoryController.js
const { DocumentCategory } = require('../models');

exports.getCategories = async (req, res) => {
  try {
    const categories = await DocumentCategory.findAll();
    res.json(categories);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.createCategory = async (req, res) => {
  try {
    console.log("ĐANG GỌI API CREATE CATEGORY");
    const { name } = req.body;

    if (!name) return res.status(400).json({ error: 'Tên danh mục là bắt buộc' });

    const [category, created] = await DocumentCategory.findOrCreate({
      where: { name },
    });

    res.status(created ? 201 : 200).json(category);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
