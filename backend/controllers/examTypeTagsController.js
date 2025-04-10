const { ExamTypeTags } = require('../models');

const examTypeTagsController = {
  createExamTypeTags: async (req, res) => {
    try {
      const { examType, tags } = req.body;
      if (!examType || !Array.isArray(tags)) return res.status(400).json({ message: 'examType và tags (mảng) là bắt buộc!' });

      const [record, created] = await ExamTypeTags.findOrCreate({ where: { examType }, defaults: { tags } });
      if (!created) await record.update({ tags });
      res.status(201).json(record);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo/cập nhật tags!', error: error.message });
    }
  },

  getExamTypeTags: async (req, res) => {
    try {
      const { examType } = req.params;
      const record = await ExamTypeTags.findOne({ where: { examType } });
      if (!record) return res.status(404).json({ message: 'Không tìm thấy tags cho examType này!' });
      res.json(record);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lấy tags!', error: error.message });
    }
  },

  deleteExamTypeTags: async (req, res) => {
    try {
      const { examType } = req.params;
      const record = await ExamTypeTags.findOne({ where: { examType } });
      if (!record) return res.status(404).json({ message: 'Không tìm thấy tags để xóa!' });
      await record.destroy();
      res.json({ message: 'Xóa tags thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa tags!', error: error.message });
    }
  },

  getAllExamTypes: async (req, res) => {
    try {
      const examTypes = await ExamTypeTags.findAll({
        attributes: ['examType'],
        order: [['id', 'ASC']], // Sắp xếp theo ID tăng dần
      });
      res.json(examTypes);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi lấy danh sách examTypes!', error: error.message });
    }
  },
};

module.exports = { examTypeTagsController };