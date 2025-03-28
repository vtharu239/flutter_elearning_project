const { User, Category, ExamTypeTags, Test, TestPart, Question, Comment } = require('../models');
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
    if (file.fieldname === 'image') {
      const dir = 'uploads/images/';
      ensureDirectoryExists(dir);
      cb(null, dir);
    } else if (file.fieldname === 'audio') {
      const dir = 'uploads/audio/';
      ensureDirectoryExists(dir);
      cb(null, dir);
    } else if (file.fieldname === 'fullAudio') {
      const dir = 'uploads/audio/full/';
      ensureDirectoryExists(dir);
      cb(null, dir);
    }
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

    const allowedExtnames = /jpeg|jpg|png|mp3|wav/;
    const allowedMimetypes = ['audio/mpeg', 'audio/wav', 'image/jpeg', 'image/png'];

    const extname = allowedExtnames.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedMimetypes.includes(file.mimetype.toLowerCase());

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      console.error('Invalid file type:', {
        extname: path.extname(file.originalname).toLowerCase(),
        mimetype: file.mimetype
      });
      cb(new Error('Chỉ hỗ trợ file ảnh (jpeg, jpg, png) hoặc audio (mp3, wav)!'));
    }
  }
}).fields([
  { name: 'image', maxCount: 1 },
  { name: 'audio', maxCount: 1 },
  { name: 'fullAudio', maxCount: 1 }
]);

const testController = {
  getAllTests: async (req, res) => {
    try {
      const { categoryName, sort, filters } = req.query;
      let where = {};
      if (categoryName && categoryName !== 'all') {
        const category = await Category.findOne({ where: { name: categoryName } });
        if (category) where.categoryId = category.id;
      }
      if (filters) {
        const filterArray = filters.split(',');
        // Logic lọc thêm nếu cần
      }

      let order = [];
      switch (sort) {
        case 'newest': order = [['createdAt', 'DESC']]; break;
        case 'popular': order = [['testCount', 'DESC']]; break;
        case 'difficulty': order = [['difficulty', 'ASC']]; break;
        default: order = [['createdAt', 'DESC']];
      }

      const tests = await Test.findAll({
        where,
        order,
        include: [{ model: Category, as: 'Category', attributes: ['id', 'name'] }]
      });
      res.json(tests);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  getTestById: async (req, res) => {
    try {
      const { id } = req.params;
      const test = await Test.findByPk(id, {
        include: [{ model: Category, as: 'Category', attributes: ['id', 'name'] }]
      });
      if (!test) return res.status(404).json({ message: 'Không tìm thấy bài test!' });
      res.json(test);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  getTestDetail: async (req, res) => {
    try {
      const { id } = req.params;
      const test = await Test.findByPk(id, {
        include: [
          { model: Category, as: 'Category', attributes: ['id', 'name'] },
          { model: TestPart, as: 'Parts', include: [{ model: Question, as: 'Questions', attributes: ['id', 'content', 'answer'] }] },
          { model: Comment, as: 'Comments', include: [{ model: User, as: 'User', attributes: ['id', 'username', 'avatarUrl'] }] }
        ]
      });
      if (!test) return res.status(404).json({ message: 'Không tìm thấy bài test!' });
      res.json(test);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  createTest: async (req, res) => {
    try {
      const { title, categoryId, duration, parts, difficulty, totalQuestions, scaledScoreMax, examType } = req.body;
      const imageUrl = req.files && req.files['image'] ? `/uploads/images/${req.files['image'][0].filename}` : null;
      const fullAudioUrl = req.files && req.files['fullAudio'] ? `/uploads/audio/full/${req.files['fullAudio'][0].filename}` : null;

      if (!title || !categoryId || !duration || !parts || !difficulty || !examType) {
        return res.status(400).json({ message: 'Thiếu các trường bắt buộc!' });
      }

      const tagsData = await ExamTypeTags.findOne({ where: { examType } });
      if (!tagsData) return res.status(400).json({ message: `examType "${examType}" chưa được định nghĩa tags!` });

      const test = await Test.create({
        title, categoryId, duration, parts, difficulty, totalQuestions, scaledScoreMax: scaledScoreMax || null,
        examType, testCount: 0, commentCount: 0, imageUrl, fullAudioUrl
      });
      res.status(201).json(test);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo test!', error: error.message });
    }
  },

  updateTest: async (req, res) => {
    try {
      const { id } = req.params;
      const { title, categoryId, duration, parts, difficulty, totalQuestions, scaledScoreMax, examType } = req.body;
      const imageUrl = req.files && req.files['image'] ? `/uploads/images/${req.files['image'][0].filename}` : undefined;
      const fullAudioUrl = req.files && req.files['fullAudio'] ? `/uploads/audio/full/${req.files['fullAudio'][0].filename}` : undefined;

      const test = await Test.findByPk(id);
      if (!test) return res.status(404).json({ message: 'Không tìm thấy test!' });

      if (examType) {
        const tagsData = await ExamTypeTags.findOne({ where: { examType } });
        if (!tagsData) return res.status(400).json({ message: `examType "${examType}" chưa được định nghĩa tags!` });
      }

      await test.update({
        title: title || test.title, categoryId: categoryId || test.categoryId, duration: duration || test.duration,
        parts: parts || test.parts, difficulty: difficulty || test.difficulty, totalQuestions: totalQuestions || test.totalQuestions,
        scaledScoreMax: scaledScoreMax !== undefined ? scaledScoreMax : test.scaledScoreMax, examType: examType || test.examType,
        imageUrl: imageUrl !== undefined ? imageUrl : test.imageUrl,
        fullAudioUrl: fullAudioUrl !== undefined ? fullAudioUrl : test.fullAudioUrl
      });
      res.json(test);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi cập nhật test!', error: error.message });
    }
  },

  deleteTest: async (req, res) => {
    try {
      const { id } = req.params;
      const test = await Test.findByPk(id);
      if (!test) return res.status(404).json({ message: 'Không tìm thấy test!' });
      await test.destroy();
      res.json({ message: 'Xóa test thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa test!', error: error.message });
    }
  }
};

module.exports = {
  testController,
  upload
};