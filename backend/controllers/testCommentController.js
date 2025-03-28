const { Comment, Test } = require('../models');

const testCommentController = {
  addComment: async (req, res) => {
    try {
      const { testId, content } = req.body;
      if (!req.user || !req.user.userId) return res.status(401).json({ message: 'Không tìm thấy thông tin người dùng!' });
      const userId = req.user.userId;

      const comment = await Comment.create({ testId, userId, content });
      await Test.increment('commentCount', { where: { id: testId } });
      res.status(201).json(comment);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  updateComment: async (req, res) => {
    try {
      const { id } = req.params;
      const { content } = req.body;
      const comment = await Comment.findByPk(id);
      if (!comment) return res.status(404).json({ message: 'Không tìm thấy comment!' });
      await comment.update({ content });
      res.json(comment);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi cập nhật comment!', error: error.message });
    }
  },

  deleteComment: async (req, res) => {
    try {
      const { id } = req.params;
      const comment = await Comment.findByPk(id);
      if (!comment) return res.status(404).json({ message: 'Không tìm thấy comment!' });
      await comment.destroy();
      res.json({ message: 'Xóa comment thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa comment!', error: error.message });
    }
  }
};

module.exports = { testCommentController };