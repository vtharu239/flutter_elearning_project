const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Test = sequelize.define('Test', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  categoryId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'Categories',
      key: 'id'
    }
  },
  duration: { // Thời gian làm bài (phút)
    type: DataTypes.INTEGER,
    allowNull: false
  },
  parts: { // Số phần trong bài thi
    type: DataTypes.INTEGER,
    allowNull: false
  },
  difficulty: { // Độ khó: easy, medium, hard
    type: DataTypes.ENUM('easy', 'medium', 'hard'),
    allowNull: false
  },
  testCount: { // Số lượt thi
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  commentCount: { // Số bình luận
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  imageUrl: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'Tests'
});

module.exports = Test;