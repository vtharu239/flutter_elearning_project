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
      parentId,
      date: new Date(),
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
        attributes: ['id', 'username', 'fullName', 'avatarUrl']
      }],
      order: [['date', 'ASC']],
    });

    // Helper: Đệ quy để xây dựng cây replies
    const buildReplies = (commentId) => {
      const replies = allComments
        .filter(r => r.parentId === commentId)
        .map(r => ({
          id: r.id,
          content: r.content,
          date: r.date, 
          userId: r.userId,
          username: r.User?.username || 'Ẩn danh',
          fullName: r.User?.fullName || 'Ẩn danh',
          avatarUrl: r.User?.avatarUrl || null,
          parentId: r.parentId,
          replies: buildReplies(r.id), // Đệ quy để lấy replies của reply
        }));
      return replies;
    };

    // Lấy các comment cha (parentId = null) và gắn replies
    const structured = allComments
      .filter(c => !c.parentId)
      .map(parent => ({
        id: parent.id,
        content: parent.content,
        date: parent.date,
        userId: parent.userId,
        username: parent.User?.username || 'Ẩn danh',
        fullName: parent.User?.fullName || 'Ẩn danh',
        avatarUrl: parent.User?.avatarUrl || null,
        parentId: parent.parentId,
        replies: buildReplies(parent.id),
      }));

    res.json(structured);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi khi lấy bình luận', error: error.message });
  }
};

module.exports = {
  addDocumentComment,
  getDocumentComments,
};
