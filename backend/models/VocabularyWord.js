const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const VocabularyWord = sequelize.define('VocabularyWord', {
  subItemId: { type: DataTypes.INTEGER, allowNull: false },
  word: { type: DataTypes.STRING, allowNull: false },
  pronunciationUK: { type: DataTypes.STRING },
  pronunciationUS: { type: DataTypes.STRING },
  definition: { type: DataTypes.STRING, allowNull: false },
  explanation: { type: DataTypes.STRING },
  examples: { type: DataTypes.JSON }, 
}, {
  tableName: 'vocabulary_words',
  timestamps: false,
});

module.exports = VocabularyWord;