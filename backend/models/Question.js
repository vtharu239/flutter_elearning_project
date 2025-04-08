const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Question = sequelize.define('Question', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  testPartId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'TestParts', key: 'id' }
  },
  content: {
    type: DataTypes.STRING,
    allowNull: true
  },
  options: { // Các lựa chọn A, B, C, D dưới dạng JSON
    type: DataTypes.JSON,
    allowNull: false
  },
  answer: { // Đáp án đúng (A, B, C, hoặc D)
    type: DataTypes.STRING,
    allowNull: false
  },
  transcript: { // Transcript cho Listening
    type: DataTypes.TEXT,
    allowNull: true
  },
  explanation: { // Giải thích đáp án
    type: DataTypes.TEXT,
    allowNull: true
  },
  tag: { // Phân loại câu hỏi (ví dụ: "Tranh tả người")
    type: DataTypes.STRING,
    allowNull: true
  },
  imageUrl: {
    type: DataTypes.STRING,
    allowNull: true
  },
  audioUrl: { 
    type: DataTypes.STRING,
    allowNull: true,
  },
}, {
  tableName: 'Questions'
});

module.exports = Question;