const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DocumentCategory = sequelize.define('DocumentCategory', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  }
}, {
  tableName: 'DocumentCategories',
  timestamps: false,
});

module.exports = DocumentCategory;
