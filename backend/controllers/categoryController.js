
const { Category, Course } = require('../models');
const categories = {
    getAllCategories: async (req, res) => {
        try {
          const categories = await Category.findAll({
            include: [{
              model: Course,
                    as: 'Courses',  // Đảm bảo trùng với alias đã đặt trong models/index.js
                    attributes: ['id', 'title']
            }]
          });
    
          res.json(categories);
        } catch (error) {
          console.error("Lỗi khi lấy danh sách khóa học:", error);
          res.status(500).json({ message: 'Lỗi server!', error: error.message });
        }
      }   
     }
  
      module.exports = categories;