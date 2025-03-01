const { Test, TestPart, Question, Comment, Category, User } = require('../models');
const multer = require('multer');
const path = require('path');

// Cấu hình multer để upload file
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // Tạo tên file duy nhất
  }
});
const upload = multer({ storage });

const testController = {
  // Lấy tất cả bài test với lọc theo category
  getAllTests: async (req, res) => {
    try {
      const { categoryName, sort, filters } = req.query;
      
      let where = {};
      if (categoryName && categoryName !== 'all') {
        const category = await Category.findOne({ where: { name: categoryName } });
        if (category) {
          where.categoryId = category.id;
        }
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
        include: [{
          model: Category,
          as: 'Category',
          attributes: ['id', 'name']
        }]
      });

      res.json(tests);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  // Lấy chi tiết bài test
  getTestById: async (req, res) => {
    try {
      const { id } = req.params;
      const test = await Test.findByPk(id, {
        include: [{
          model: Category,
          as: 'Category',
          attributes: ['id', 'name']
        }]
      });

      if (!test) {
        return res.status(404).json({ message: 'Không tìm thấy bài test!' });
      }

      res.json(test);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  // Lấy chi tiết bài thi bao gồm parts và comments
  getTestDetail: async (req, res) => {
    try {
      const { id } = req.params;
      const test = await Test.findByPk(id, {
        include: [
          {
            model: Category,
            as: 'Category',
            attributes: ['id', 'name']
          },
          {
            model: TestPart,
            as: 'Parts',
            include: [{
              model: Question,
              as: 'Questions',
              attributes: ['id', 'content', 'answer']
            }]
          },
          {
            model: Comment,
            as: 'Comments',
            include: [{
              model: User,
              as: 'User',
              attributes: ['id', 'username', 'avatarUrl'] // Thêm avatarUrl
            }]
          }
        ]
      });

      if (!test) {
        return res.status(404).json({ message: 'Không tìm thấy bài test!' });
      }

      res.json(test);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  // ---------------------------- Test CRUD --------------------------

  // Tạo Test với upload hình ảnh
  createTest: async (req, res) => {
    try {
      const { title, categoryId, duration, parts, difficulty } = req.body;
      const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;

      const test = await Test.create({
        title,
        categoryId,
        duration,
        parts,
        difficulty,
        testCount: 0,
        commentCount: 0,
        imageUrl
      });
      res.status(201).json(test);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo test!', error: error.message });
    }
  },

  // Cập nhật Test với upload hình ảnh
  updateTest: async (req, res) => {
    try {
      const { id } = req.params;
      const { title, categoryId, duration, parts, difficulty } = req.body;
      const imageUrl = req.file ? `/uploads/${req.file.filename}` : undefined;

      const test = await Test.findByPk(id);
      if (!test) {
        return res.status(404).json({ message: 'Không tìm thấy test!' });
      }
      await test.update({ 
        title, 
        categoryId, 
        duration, 
        parts, 
        difficulty, 
        imageUrl: imageUrl || test.imageUrl // Giữ ảnh cũ nếu không upload mới
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
      if (!test) {
        return res.status(404).json({ message: 'Không tìm thấy test!' });
      }
      await test.destroy();
      res.json({ message: 'Xóa test thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa test!', error: error.message });
    }
  },

  // --- TestPart CRUD ---
  createTestPart: async (req, res) => {
    try {
      const { testId, title, questionCount, tags } = req.body;
      const testPart = await TestPart.create({
        testId,
        title,
        questionCount,
        tags // Lưu dưới dạng JSON
      });
      res.status(201).json(testPart);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo test part!', error: error.message });
    }
  },

  updateTestPart: async (req, res) => {
    try {
      const { id } = req.params;
      const { title, questionCount, tags } = req.body;
      const testPart = await TestPart.findByPk(id);
      if (!testPart) {
        return res.status(404).json({ message: 'Không tìm thấy test part!' });
      }
      await testPart.update({ title, questionCount, tags });
      res.json(testPart);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi cập nhật test part!', error: error.message });
    }
  },

  deleteTestPart: async (req, res) => {
    try {
      const { id } = req.params;
      const testPart = await TestPart.findByPk(id);
      if (!testPart) {
        return res.status(404).json({ message: 'Không tìm thấy test part!' });
      }
      await testPart.destroy();
      res.json({ message: 'Xóa test part thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa test part!', error: error.message });
    }
  },

  // --- Question CRUD ---
  createQuestion: async (req, res) => {
    try {
      const { testPartId, content, answer } = req.body;
      const question = await Question.create({
        testPartId,
        content,
        answer
      });
      res.status(201).json(question);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi tạo question!', error: error.message });
    }
  },

  updateQuestion: async (req, res) => {
    try {
      const { id } = req.params;
      const { content, answer } = req.body;
      const question = await Question.findByPk(id);
      if (!question) {
        return res.status(404).json({ message: 'Không tìm thấy question!' });
      }
      await question.update({ content, answer });
      res.json(question);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi cập nhật question!', error: error.message });
    }
  },

  deleteQuestion: async (req, res) => {
    try {
      const { id } = req.params;
      const question = await Question.findByPk(id);
      if (!question) {
        return res.status(404).json({ message: 'Không tìm thấy question!' });
      }
      await question.destroy();
      res.json({ message: 'Xóa question thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa question!', error: error.message });
    }
  },

  // --------------------- Comment CRUD -------------------------

  // Thêm bình luận (yêu cầu đăng nhập)
  addComment: async (req, res) => {
    try {
      const { testId, content } = req.body;
      console.log('req.user:', req.user); // Debug để kiểm tra req.user
      if (!req.user || !req.user.userId) {
        return res.status(401).json({ message: 'Không tìm thấy thông tin người dùng!' });
      }
      
      const userId = req.user.userId; // Lấy userId từ token (được gán trong authController.login)

      const comment = await Comment.create({
        testId,
        userId,
        content
      });

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
      if (!comment) {
        return res.status(404).json({ message: 'Không tìm thấy comment!' });
      }
      // Optional: Kiểm tra xem user có quyền sửa comment này không
      // if (comment.userId !== req.user.id) return res.status(403).json({ message: 'Không có quyền!' });
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
      if (!comment) {
        return res.status(404).json({ message: 'Không tìm thấy comment!' });
      }
      // Optional: Kiểm tra quyền
      // if (comment.userId !== req.user.id) return res.status(403).json({ message: 'Không có quyền!' });
      await comment.destroy();
      res.json({ message: 'Xóa comment thành công!' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi xóa comment!', error: error.message });
    }
  }
};

module.exports = {
  testController,
  upload: upload.single('image') // 'image' là tên field trong form-data
};