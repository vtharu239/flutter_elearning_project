
const { CourseReview } = require('../models');

const courseReviewController = {

  getReviewsByCourseId: async (req, res) => {
    try {
      const { courseId } = req.params;
      const reviews = await CourseReview.findAll({
        where: { courseId },
        order: [['createdAt', 'DESC']] // Most recent first
      });
      // Kiểm tra dữ liệu trả về
      if (!reviews || reviews.length === 0) {
        return res.status(200).json([]); // Trả về mảng rỗng nếu không có review
      }
      // Format the response to match what the frontend expects
      const formattedReviews = reviews.map(review => {
        return {
          id: review.id,
          userName: review.userName,
          userInfo: review.userInfo,
          comment: review.comment,
          rating: review.rating,
          createdAt: review.createdAt,
        };
      });
      
      res.status(200).json(formattedReviews);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
 createReview: async (req, res) => {
    try {
      const { courseId, userName, userInfo, comment, rating } = req.body;
      const userId = req.user.userId; // Lấy userId từ req.user
      console.log('Creating review with data:', { courseId, userName, userInfo, comment, rating, userId });
  
      const newReview = await CourseReview.create({
        courseId,
        userId, // Lưu userId vào bảng
        userName: userName || `User_${userId}`,
        userInfo,
        comment,
        rating,
      });
      res.status(201).json(newReview);
    } catch (error) {
      console.error('Error in createReview:', error);
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }}
};

module.exports = courseReviewController;