const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CourseReview = sequelize.define('CourseReview', {
  courseId: { type: DataTypes.INTEGER, allowNull: false },
  userName: { type: DataTypes.STRING, allowNull: false },
  userInfo: { type: DataTypes.STRING, allowNull: false },
  comment: { type: DataTypes.TEXT, allowNull: false },
  rating: { type: DataTypes.DECIMAL(2, 1), allowNull: false },
}, {
  tableName: 'course_reviews',
  timestamps: false,
});

module.exports = CourseReview;