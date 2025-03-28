const { TestPart } = require('../models');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Tạo thư mục nếu chưa tồn tại
const ensureDirectoryExists = (dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

// Cấu hình multer để upload file
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = 'uploads/audio/';
    ensureDirectoryExists(dir);
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    console.log('File received:', {
      fieldname: file.fieldname,
      originalname: file.originalname,
      mimetype: file.mimetype
    });

    const allowedExtnames = /mp3|wav/;
    const allowedMimetypes = ['audio/mpeg', 'audio/wav'];

    const extname = allowedExtnames.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedMimetypes.includes(file.mimetype.toLowerCase());

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      console.error('Invalid file type:', {
        extname: path.extname(file.originalname).toLowerCase(),
        mimetype: file.mimetype
      });
      cb(new Error('Chỉ hỗ trợ file audio (mp3, wav)!'));
    }
  }
}).single('audio'); // Chỉ nhận field 'audio'

const testPartController = {
  createTestPart: async (req, res) => {
    try {
      const { testId, title, questionCount, partType } = req.body;
      const audioUrl = req.file ? `/uploads/audio/${req.file.filename}` : null;
      if (!testId || !title || !partType) {
        return res.status(400).json({ message: 'Thiếu các trường bắt buộc!' });
      }
      const testPart = await TestPart.create({ testId, title, questionCount, partType, tags: [], audioUrl });
      res.status(201).json(testPart);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo test part!', error: error.message });
    }
  },

  updateTestPart: async (req, res) => {
    try {
      const { id } = req.params;
      const { title, questionCount, partType } = req.body;
      const audioUrl = req.file ? `/uploads/audio/${req.file.filename}` : undefined;
      const testPart = await TestPart.findByPk(id);
      if (!testPart) return res.status(404).json({ message: 'Không tìm thấy test part!' });
      await testPart.update({ 
        title: title || testPart.title, 
        questionCount: questionCount || testPart.questionCount, 
        partType: partType || testPart.partType,
        audioUrl: audioUrl !== undefined ? audioUrl : testPart.audioUrl
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

module.exports = { testPartController, upload };