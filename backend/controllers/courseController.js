// controllers/courseController.js
const { Course, Category } = require('../models');

const courseController = {
  // GET all courses (đã có trước đó)
  getCourses: async (req, res) => {
    try {
      const { categoryId } = req.query;
      const courses = await Course.findAll({
        where: categoryId ? { categoryId } : {},
        include: [{ model: Category, as: 'Category', attributes: ['id', 'name'] }],
        order: [['createdAt', 'DESC']],
      });
      res.json(courses);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  // GET course by ID
  getCourseById: async (req, res) => {
    try {
      const course = await Course.findByPk(req.params.id, {
        include: [
          { model: Category, as: 'Category' },
          { model: CourseObjective, as: 'Objectives' },
          { model: CourseTeacher, as: 'Teachers' },
          {
            model: CourseCurriculum,
            as: 'Curriculum',
            include: [{ model: CurriculumFeature, as: 'Features' }],
          },
          { model: CourseReview, as: 'Reviews' },
          { model: CourseRatingStat, as: 'RatingStats' },
        ],
      });
      if (!course) return res.status(404).json({ message: 'Không tìm thấy khóa học' });
      res.json(course);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },

  // POST create course
createCourse: async (req, res) => {
  try {
    const {
      title, description, rating, ratingCount, studentCount, originalPrice,
      discountPercentage, discountedPrice, categoryId, topics, lessons,
      exercises, validity, imageUrl // Thêm imageUrl vào đây
    } = req.body;

    const course = await Course.create({
      title, description, rating, ratingCount, studentCount, originalPrice,
      discountPercentage, discountedPrice, categoryId, topics, lessons,
      exercises, validity, imageUrl // Lưu imageUrl từ req.body
    });
    res.status(201).json(course);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!', error: error.message });
  }
},
  // PUT update course=
updateCourse: async (req, res) => {
  try {
    const course = await Course.findByPk(req.params.id);
    if (!course) return res.status(404).json({ message: 'Không tìm thấy khóa học' });

    // Cập nhật dữ liệu, bao gồm imageUrl nếu được gửi từ req.body
    await course.update(req.body);

    res.json(course);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!', error: error.message });
  }
},

  // DELETE course
  deleteCourse: async (req, res) => {
    try {
      const course = await Course.findByPk(req.params.id);
      if (!course) return res.status(404).json({ message: 'Không tìm thấy khóa học' });
      await course.destroy();
      res.json({ message: 'Xóa khóa học thành công' });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
};

module.exports = courseController;