const { sequelize } = require('../config/database');
const User = require('./User');

// Thêm các model khác ở đây
module.exports = {
  sequelize,
  User
};