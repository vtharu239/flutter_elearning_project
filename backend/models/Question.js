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
    references: {
      model: 'TestParts',
      key: 'id'
    }
  },
  content: {
    type: DataTypes.STRING,
    allowNull: false
  },
  answer: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  tableName: 'Questions'
});

module.exports = Question;