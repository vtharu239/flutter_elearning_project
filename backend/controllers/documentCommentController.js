const { DocumentComment, User } = require('../models');

const addDocumentComment = async (req, res) => {
  try {
    const { documentId, userId, content, parentId = null } = req.body;

    if (!documentId || !userId || !content) {
      return res.status(400).json({ message: "Thiếu dữ liệu!" });
    }

    const comment = await DocumentComment.create({
      documentId,
      userId,
      content,
      parentId, // để hỗ trợ reply
      date: new Date().toISOString(),
    });

    res.status(201).json(comment);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!', error: error.message });
  }
};

const getDocumentComments = async (req, res) => {
  try {
    const { documentId } = req.query;

    const allComments = await DocumentComment.findAll({
      where: { documentId },
      include: [{
        model: User,
        as: 'User',
        attributes: ['id', 'username', 'fullName']
      }],
      order: [['date', 'ASC']],
    });

    const parents = allComments.filter(c => !c.parentId);
    const replies = allComments.filter(c => c.parentId);

    // Helper: Gắn replies vào parent
    const buildReplies = (parent) => {
      const children = replies.filter(r => r.parentId === parent.id).map(r => ({
        id: r.id,
        content: r.content,
        date: r.date,
        userId: r.userId,
        username: r.User?.username || 'Ẩn danh',
        fullName: r.User?.fullName || 'Ẩn danh',
        replies: [], // nếu cần đệ quy sâu hơn
      }));
      return {
        id: parent.id,
        content: parent.content,
        date: parent.date,
        userId: parent.userId,
        username: parent.User?.username || 'Ẩn danh',
        fullName: parent.User?.fullName || 'Ẩn danh',
        replies: children,
      };
    };

    const structured = parents.map(buildReplies);
    res.json(structured);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy bình luận', error: error.message });
  }
};

module.exports = {
  addDocumentComment,
  getDocumentComments,
};
