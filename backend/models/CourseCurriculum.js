const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CourseCurriculum = sequelize.define('CourseCurriculum', {
  courseId: { type: DataTypes.INTEGER, allowNull: false },
  section: { type: DataTypes.STRING, allowNull: false },
  lesson: { type: DataTypes.STRING, allowNull: false },
}, {
  tableName: 'course_curriculum',
  timestamps: false,
});

module.exports = CourseCurriculum;