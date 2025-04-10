const { TestPart, Test, Question, ExamTypeTags } = require('../models');
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
      const dir = 'uploads/test_images/';
      ensureDirectoryExists(dir);
      cb(null, dir);
    } else if (file.fieldname === 'audio') {
      const dir = 'uploads/test_audio/question/';
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
    const allowedMimetypes = ['image/jpeg', 'image/png', 'audio/mpeg', 'audio/wav'];

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
  { name: 'audio', maxCount: 1 }
]);

const testQuestionController = {
  createQuestion: async (req, res) => {
    try {
      const { testPartId, content, options, answer, transcript, explanation, tag } = req.body;
      const imageUrl = req.files && req.files['image'] ? `/uploads/test_images/${req.files['image'][0].filename}` : null;
      const audioUrl = req.files && req.files['audio'] ? `/uploads/test_audio/question/${req.files['audio'][0].filename}` : null;

      if (!testPartId || !options || !answer) {
        return res.status(400).json({ message: 'Thiếu các trường bắt buộc!' });
      }

      let parsedOptions;
      try {
        parsedOptions = JSON.parse(options);
        if (typeof parsedOptions !== 'object' || Object.keys(parsedOptions).length === 0) {
          return res.status(400).json({ message: 'options phải là một object JSON hợp lệ và không rỗng!' });
        }
      } catch (error) {
        return res.status(400).json({ message: 'options phải là một chuỗi JSON hợp lệ!' });
      }

      if (!Object.keys(parsedOptions).includes(answer)) {
        return res.status(400).json({ message: 'answer phải là một lựa chọn trong options!' });
      }

      const testPart = await TestPart.findByPk(testPartId, { include: [{ model: Test, as: 'Test' }] });
      if (!testPart) return res.status(404).json({ message: 'Không tìm thấy TestPart!' });

      if (tag && !(await isValidTagForExamType(tag, testPart.testId))) {
        const validTags = (await ExamTypeTags.findOne({ where: { examType: testPart.Test.examType } })).tags;
        return res.status(400).json({ 
          message: `Tag "${tag}" không hợp lệ với examType "${testPart.Test.examType}"! Tags hợp lệ: ${validTags.join(', ')}`
        });
      }

      const question = await Question.create({ testPartId, content, options: parsedOptions, answer, transcript, explanation, tag, imageUrl, audioUrl });
      await testPart.increment('questionCount');
      await Test.increment('totalQuestions', { where: { id: testPart.testId } });
      await updateTestPartTags(testPartId);
      res.status(201).json(question);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo question!', error: error.message });
    }
  },

  updateQuestion: async (req, res) => {
    try {
      const { id } = req.params;
      const { testPartId, content, options, answer, transcript, explanation, tag } = req.body;
      const imageUrl = req.files && req.files['image'] ? `/uploads/test_images/${req.files['image'][0].filename}` : undefined;
      const audioUrl = req.files && req.files['audio'] ? `/uploads/test_audio/question/${req.files['audio'][0].filename}` : undefined;

      const question = await Question.findByPk(id);
      if (!question) return res.status(404).json({ message: 'Không tìm thấy question!' });

      let parsedOptions = question.options;
      if (options) {
        try {
          parsedOptions = JSON.parse(options);
          if (typeof parsedOptions !== 'object' || Object.keys(parsedOptions).length === 0) {
            return res.status(400).json({ message: 'options phải là một object JSON hợp lệ và không rỗng!' });
          }
        } catch (error) {
          return res.status(400).json({ message: 'options phải là một chuỗi JSON hợp lệ!' });
        }
      }

      if (answer && (!parsedOptions || !Object.keys(parsedOptions).includes(answer))) {
        return res.status(400).json({ message: 'answer phải là một lựa chọn trong options!' });
      }

      const oldTestPartId = question.testPartId;
      const newTestPartId = testPartId || oldTestPartId;
      const testPart = await TestPart.findByPk(newTestPartId, { include: [{ model: Test, as: 'Test' }] });

      if (tag !== undefined && !(await isValidTagForExamType(tag, testPart.testId))) {
        const validTags = (await ExamTypeTags.findOne({ where: { examType: testPart.Test.examType } })).tags;
        return res.status(400).json({ 
          message: `Tag "${tag}" không hợp lệ với examType "${testPart.Test.examType}"! Tags hợp lệ: ${validTags.join(', ')}`
        });
      }

      if (testPartId && testPartId !== oldTestPartId) {
        const oldTestPart = await TestPart.findByPk(oldTestPartId);
        const newTestPart = await TestPart.findByPk(testPartId);
        await oldTestPart.decrement('questionCount');
        await newTestPart.increment('questionCount');
      }

      await question.update({ 
        testPartId: testPartId || question.testPartId, 
        content: content || question.content, 
        options: parsedOptions,
        answer: answer || question.answer, 
        transcript: transcript !== undefined ? transcript : question.transcript,
        explanation: explanation !== undefined ? explanation : question.explanation, 
        tag: tag !== undefined ? tag : question.tag,
        imageUrl: imageUrl !== undefined ? imageUrl : question.imageUrl,
        audioUrl: audioUrl !== undefined ? audioUrl : question.audioUrl
      });

      if (testPartId && testPartId !== oldTestPartId) {
        await updateTestPartTags(oldTestPartId);
        await updateTestPartTags(testPartId);
      } else if (tag !== undefined) {
        await updateTestPartTags(newTestPartId);
      }
      res.json(question);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi cập nhật question!', error: error.message });
    }
  },

  deleteQuestion: async (req, res) => {
    try {
      const { id } = req.params;
      const question = await Question.findByPk(id);
      if (!question) return res.status(404).json({ message: 'Không tìm thấy question!' });

      const testPart = await TestPart.findByPk(question.testPartId);
      await testPart.decrement('questionCount');
      await Test.decrement('totalQuestions', { where: { id: testPart.testId } });
      await question.destroy();
      res.json({ message: 'Xóa question thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa question!', error: error.message });
    }
  }
};

// Hàm helper
const isValidTagForExamType = async (tag, testId) => {
    const test = await Test.findByPk(testId);
    if (!test) return false;
    const tagsData = await ExamTypeTags.findOne({ where: { examType: test.examType } });
    const validTags = tagsData ? tagsData.tags : [];
    return tag ? validTags.includes(tag) : true;
  };
  
  const updateTestPartTags = async (testPartId) => {
    const testPart = await TestPart.findByPk(testPartId, { include: [{ model: Question, as: 'Questions' }, { model: Test, as: 'Test' }] });
    if (!testPart) return;
  
    const questionTags = [...new Set(testPart.Questions.map(q => q.tag).filter(tag => tag))];
    const tagsData = await ExamTypeTags.findOne({ where: { examType: testPart.Test.examType } });
    const validTags = tagsData ? tagsData.tags : [];
    const filteredTags = questionTags.filter(tag => validTags.includes(tag));
    const tags = filteredTags.map(tag => `[${testPart.title}] ${tag}`);
    await testPart.update({ tags });
  };

module.exports = { testQuestionController, upload };