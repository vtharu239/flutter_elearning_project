const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const TestPart = sequelize.define('TestPart', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  testId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'Tests', key: 'id' }
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  questionCount: {
    type: DataTypes.INTEGER,
    allowNull: true,
    defaultValue: 0
  },
  partType: { // Loại part: Listening Part 1, Reading Part 5,...
    type: DataTypes.STRING,
    allowNull: false
  },
  tags: {
    type: DataTypes.JSON, // Lưu trữ tags dưới dạng JSON
    allowNull: true
  }
}, {
  tableName: 'TestParts'
});

module.exports = TestPart;