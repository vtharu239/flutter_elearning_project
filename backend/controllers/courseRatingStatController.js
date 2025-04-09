const { Sequelize } = require('sequelize'); // Thêm dòng này
const { CourseRatingStat, CourseReview } = require('../models');

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
      console.log(`Fetching rating stats for courseId: ${courseId}`);

      // Get all rating stats for this course
      const ratingStats = await CourseRatingStat.findAll({
        where: { courseId },
        order: [['stars', 'DESC']],
      });
      console.log(`Rating stats found: ${ratingStats.length} records`);

      // Count total reviews
      const totalReviews = await CourseReview.count({
        where: { courseId },
      });
      console.log(`Total reviews: ${totalReviews}`);

      // Calculate average rating with protection against division by zero
      const avgRatingResult = await CourseRatingStat.findOne({
        attributes: [
          [Sequelize.literal('SUM(stars * count) / NULLIF(SUM(count), 0)'), 'avgRating'],
        ],
        where: { courseId },
      });
      console.log(`Raw avgRatingResult:`, avgRatingResult);
      const avgRating = avgRatingResult && avgRatingResult.getDataValue('avgRating')
        ? parseFloat(avgRatingResult.getDataValue('avgRating'))
        : 0;
      console.log(`Average rating calculated: ${avgRating}`);

      // Format response
      const response = {
        averageRating: avgRating,
        totalReviews: totalReviews || 0,
        totalStudents: 0, // Cần lấy từ bảng Order nếu có
        ratingDistribution: ratingStats && ratingStats.length > 0
          ? ratingStats.map(stat => ({
              stars: stat.stars,
              count: stat.count,
              percentage: stat.percentage,
            }))
          : [],
      };
      console.log(`Response prepared:`, response);

      res.status(200).json(response);
    } catch (error) {
      console.error('Error in getRatingStatsByCourseId:', error);
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
};

module.exports = courseRatingStatController;