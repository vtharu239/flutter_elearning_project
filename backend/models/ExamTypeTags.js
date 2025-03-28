const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const ExamTypeTags = sequelize.define('ExamTypeTags', {
  examType: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      isIn: [['TOEIC', 'IELTS', 'TOEFL', 'OTHER']] // Giới hạn examType
    }
  },
  tags: {
    type: DataTypes.JSON,
    allowNull: false,
    defaultValue: []
  }
}, {
  tableName: 'ExamTypeTags'
});

module.exports = ExamTypeTags;