const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CourseTeacher = sequelize.define('CourseTeacher', {
  courseId: { type: DataTypes.INTEGER, allowNull: false },
  name: { type: DataTypes.STRING, allowNull: false },
  credentials: { type: DataTypes.TEXT },
}, {
  tableName: 'course_teachers',
  timestamps: false,
});

module.exports = CourseTeacher;