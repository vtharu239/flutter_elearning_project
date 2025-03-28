// documentController.js
const { Document } = require('../models');

// Lấy danh sách tài liệu
exports.getDocuments = async (req, res) => {
  try {
    const documents = await Document.findAll();
    res.json(documents);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Thêm mới tài liệu
exports.createDocument = async (req, res) => {
  try {
    const newDoc = await Document.create(req.body);
    res.status(201).json(newDoc);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Cập nhật tài liệu
exports.updateDocument = async (req, res) => {
  try {
    const { id } = req.params;
    await Document.update(req.body, { where: { id } });
    res.json({ message: 'Cập nhật thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Xóa tài liệu
exports.deleteDocument = async (req, res) => {
  try {
    const { id } = req.params;
    await Document.destroy({ where: { id } });
    res.json({ message: 'Xóa thành công' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};