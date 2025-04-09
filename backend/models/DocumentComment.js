const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DocumentComment = sequelize.define('DocumentComment', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    documentId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    userId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    parentId: { //  Thêm dòng này để hỗ trợ reply
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: null,
    },
    date: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  }, {
    tableName: 'DocumentComments',
});

// DocumentComment.belongsTo(Document, { foreignKey: 'documentId', as: 'Document' });
// DocumentComment.belongsTo(User, { foreignKey: 'userId', as: 'User' });

module.exports = DocumentComment;
