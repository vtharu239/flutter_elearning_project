const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const CourseObjective = sequelize.define('CourseObjective', {
  courseId: { type: DataTypes.INTEGER, allowNull: false },
  objective: { type: DataTypes.TEXT, allowNull: false },
}, {
  tableName: 'course_objectives',
  timestamps: false,
});

module.exports = CourseObjective;