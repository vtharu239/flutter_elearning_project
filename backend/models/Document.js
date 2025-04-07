const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const DocumentCategory = require('./DocumentCategory');

const Document = sequelize.define('Document', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  categoryId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: DocumentCategory,
      key: 'id',
    },
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  imageUrl: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  commentCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  author: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  date: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW,
  },
  status: {
    type: DataTypes.STRING,
    defaultValue: 'pending'
  }
  
}, {
  tableName: 'Documents',
});

Document.belongsTo(DocumentCategory, { foreignKey: 'categoryId', as: 'category' });

module.exports = Document;
