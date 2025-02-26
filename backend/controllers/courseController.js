const { Course, Category } = require('../models');

const getCourses = async (req, res) => {
  try {
    const { categoryId } = req.query; // Lấy categoryId từ query params (hoặc có thể lấy từ req.params nếu dùng route động)

    let courses;
    if (categoryId) {
      // Nếu có categoryId, lấy các khóa học thuộc danh mục đó
      courses = await Course.findAll({
        where: { categoryId },
        include: [{
          model: Category,
          as: 'Category',
          attributes: ['id', 'name']
        }],
        order: [['createdAt', 'DESC']]
      });
    } else {
      // Nếu không có categoryId, lấy tất cả khóa học
      courses = await Course.findAll({
        order: [['createdAt', 'DESC']]
      });
    }

    res.json(courses);
  } catch (error) {
    console.error("Lỗi khi lấy danh sách khóa học:", error);
    res.status(500).json({ message: 'Lỗi server!', error: error.message });
  }
};

module.exports = { getCourses };
