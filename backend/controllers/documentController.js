const { Document, DocumentCategory, DocumentComment } = require('../models');
const { Op } = require('sequelize');

// Lấy danh sách tài liệu (có thể lọc theo categoryId)
const getDocuments = async (req, res) => {
  try {
    const { categoryId } = req.query;

    const whereClause = {
      ...(categoryId ? { categoryId: { [Op.eq]: categoryId } } : {}),
      status: 'approved', //  Chỉ lấy bài đã duyệt
    };

    const documents = await Document.findAll({
      where: whereClause,
      include: [
        {
          model: DocumentCategory,
          as: 'documentCategory',
          attributes: ['name'],
        },
        {
          model: DocumentComment, // Kết nối bảng comment
          as: 'comments',
          attributes: ['id'],
        },
      ],
    });

    const result = documents.map(doc => ({
      id: doc.id,
      title: doc.title,
      description: doc.description,
      imageUrl: doc.imageUrl,
      commentCount: doc.comments?.length || 0,
      author: doc.author,
      date: doc.createdAt,
      categoryId: doc.categoryId,
      category: doc.documentCategory?.name || null,
    }));

    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Thêm mới tài liệu
const createDocument = async (req, res) => {
  try {
    const { title, description, imageUrl, author, categoryId } = req.body;

    if (!title || !author || !categoryId) {
      return res.status(400).json({ error: 'Thiếu dữ liệu bắt buộc' });
    }

    const newDoc = await Document.create({
      title,
      description,
      imageUrl,
      author,
      categoryId,
    });

    res.status(201).json(newDoc);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Cập nhật tài liệu
const updateDocument = async (req, res) => {
  try {
    const { id } = req.params;
    await Document.update(req.body, { where: { id } });
    res.json({ message: 'Cập nhật thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Xóa tài liệu
const deleteDocument = async (req, res) => {
  try {
    const { id } = req.params;
    await Document.destroy({ where: { id } });
    res.json({ message: 'Xóa thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
const updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    // Kiểm tra hợp lệ
    const validStatuses = ['approved', 'pending', 'rejected'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Trạng thái không hợp lệ' });
    }

    const doc = await Document.findByPk(id);
    if (!doc) return res.status(404).json({ error: 'Không tìm thấy tài liệu' });

    // Cập nhật status
    doc.status = status;
    await doc.save();

    res.status(200).json({ message: 'Cập nhật trạng thái thành công', document: doc });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Lỗi server', details: err.message });
  }
}

//  Export toàn bộ
module.exports = {
  getDocuments,
  createDocument,
  updateDocument,
  deleteDocument,
  updateStatus,
};
