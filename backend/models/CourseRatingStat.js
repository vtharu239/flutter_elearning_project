const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const CourseRatingStat = sequelize.define('CourseRatingStat', {
  courseId: { type: DataTypes.INTEGER, allowNull: false },
  stars: { type: DataTypes.INTEGER, allowNull: false },
  count: { type: DataTypes.INTEGER, allowNull: false },
  percentage: { type: DataTypes.DECIMAL(3, 2), allowNull: false },
}, {
  tableName: 'course_rating_stats',
  timestamps: false,
});

module.exports = CourseRatingStat;