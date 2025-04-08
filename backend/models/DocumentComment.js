// models/DocumentComment.js
module.exports = (sequelize, DataTypes) => {
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
      type: DataTypes.STRING,
      defaultValue: () => new Date().toISOString(),
    },
  }, {
    tableName: 'DocumentComments',
  });

  return DocumentComment;
};
