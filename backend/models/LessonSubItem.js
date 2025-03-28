const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const LessonSubItem = sequelize.define('LessonSubItem', {
  curriculumId: { type: DataTypes.INTEGER, allowNull: false },
  subItem: { type: DataTypes.STRING, allowNull: false },
}, {
  tableName: 'lesson_sub_items',
  timestamps: false,
});

module.exports = LessonSubItem;