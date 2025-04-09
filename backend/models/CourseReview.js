const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const User = require('./User');

const CourseReview = sequelize.define('CourseReview', {
  userId: { // Thêm trường userId
    type: DataTypes.INTEGER,
    allowNull: true,
    references: {
      model: 'Users', // Tên bảng User trong database
      key: 'id',
    },
  },
  courseId: { type: DataTypes.INTEGER, allowNull: false },
  userName: { type: DataTypes.STRING, allowNull: false },
  userInfo: { type: DataTypes.STRING, allowNull: false },
  comment: { type: DataTypes.TEXT, allowNull: false },
  rating: { type: DataTypes.DECIMAL(2, 1), allowNull: false },
  createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW, allowNull: false },
  updatedAt: { 
    type: DataTypes.DATE, 
    allowNull: false, 
    defaultValue: DataTypes.NOW 
  },
}, {
  tableName: 'course_reviews',
  timestamps: true,
});
module.exports = CourseReview;