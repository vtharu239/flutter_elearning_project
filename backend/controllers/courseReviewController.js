
const { CourseReview } = require('../models');

const courseReviewController = {
  createReview: async (req, res) => {
    try {
      const { courseId, name, info, comment } = req.body;
      const newReview = await CourseReview.create({ courseId, name, info, comment });
      res.status(201).json(newReview);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
  getReviewsByCourseId: async (req, res) => {
    try {
      const { courseId } = req.params;
      const reviews = await CourseReview.findAll({
        where: { courseId },
        order: [['createdAt', 'DESC']] // Most recent first
      });
      
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
  }
};

module.exports = courseReviewController;