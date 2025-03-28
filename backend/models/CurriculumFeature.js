const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const CurriculumFeature = sequelize.define('CurriculumFeature', {
    curriculumId: { type: DataTypes.INTEGER, allowNull: false },
    feature: { type: DataTypes.TEXT, allowNull: false },
  }, {
    tableName: 'curriculum_features',
    timestamps: false,
  });
  
  module.exports = CurriculumFeature;