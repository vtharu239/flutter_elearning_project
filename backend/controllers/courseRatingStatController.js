
const { CourseRatingStat } = require('../models');

const courseRatingStatController = {
  createRatingStat: async (req, res) => {
    try {
      const { courseId, stars, count, percentage } = req.body;
      const newStat = await CourseRatingStat.create({ courseId, stars, count, percentage });
      res.status(201).json(newStat);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
  getRatingStatsByCourseId: async (req, res) => {
    try {
      const { courseId } = req.params;
      
      // Get all rating stats for this course
      const ratingStats = await CourseRatingStat.findAll({
        where: { courseId },
        order: [['stars', 'DESC']]
      });
      
      // Count total reviews
      const totalReviews = await CourseReview.count({
        where: { courseId }
      });
      
      // Calculate average rating
      const avgRating = await CourseRatingStat.findOne({
        attributes: [
          [Sequelize.literal('SUM(stars * count) / SUM(count)'), 'avgRating']
        ],
        where: { courseId }
      });
      
      // Format into the structure expected by frontend
      const response = {
        averageRating: avgRating ? parseFloat(avgRating.getDataValue('avgRating')) || 0 : 0,
        totalReviews: totalReviews,
        totalStudents: 0, // You might need to get this from elsewhere
        ratingDistribution: ratingStats.map(stat => ({
          stars: stat.stars,
          count: stat.count,
          percentage: stat.percentage
        }))
      };
      
      res.status(200).json(response);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  }
};

module.exports = courseRatingStatController;