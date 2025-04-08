const { TestPart } = require('../models');

const testPartController = {
  createTestPart: async (req, res) => {
    try {
      const { testId, title, questionCount, partType } = req.body;
      if (!testId || !title || !partType) {
        return res.status(400).json({ message: 'Thiếu các trường bắt buộc!' });
      }
      const testPart = await TestPart.create({ testId, title, questionCount, partType, tags: [] });
      res.status(201).json(testPart);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo test part!', error: error.message });
    }
  },

  updateTestPart: async (req, res) => {
    try {
      const { id } = req.params;
      const { title, questionCount, partType } = req.body;
      const testPart = await TestPart.findByPk(id);
      if (!testPart) return res.status(404).json({ message: 'Không tìm thấy test part!' });
      await testPart.update({ 
        title: title || testPart.title, 
        questionCount: questionCount || testPart.questionCount, 
        partType: partType || testPart.partType
      });
      res.json(testPart);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi cập nhật test part!', error: error.message });
    }
  },

  deleteTestPart: async (req, res) => {
    try {
      const { id } = req.params;
      const testPart = await TestPart.findByPk(id);
      if (!testPart) return res.status(404).json({ message: 'Không tìm thấy test part!' });
      await testPart.destroy();
      res.json({ message: 'Xóa test part thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa test part!', error: error.message });
    }
  }
};

module.exports = { testPartController };