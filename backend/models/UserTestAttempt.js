const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const UserTestAttempt = sequelize.define('UserTestAttempt', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'Users', key: 'id' }
  },
  testId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: { model: 'Tests', key: 'id' }
  },
  answers: { // Đáp án người dùng chọn (JSON: { questionId: answer })
    type: DataTypes.JSON,
    allowNull: false
  },
  startTime: {
    type: DataTypes.DATE,
    allowNull: false
  },
  submitTime: {
    type: DataTypes.DATE,
    allowNull: true
  },
  isSubmitted: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  correctCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  skippedCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  wrongCount: { 
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  scaledScore: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  completionTime: {
    type: DataTypes.STRING, // Changed from INTEGER to STRING to store HH:mm:ss
    allowNull: false,
    defaultValue: '00:00:00',
  },
  isFullTest: {
    type: DataTypes.BOOLEAN, // Phân biệt Practice hay Full Test
    defaultValue: false,
  },
  selectedParts: {
    type: DataTypes.JSON, // Lưu danh sách partIds đã chọn (dùng cho Practice Mode)
  },
  duration: { 
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
}, {
  tableName: 'UserTestAttempts'
});

module.exports = UserTestAttempt;