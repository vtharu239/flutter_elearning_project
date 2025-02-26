const { sequelize } = require('../config/database');
const User = require('./User');
const Category = require('./Category');
const Course = require('./Course');
module.exports = {
  sequelize,
  User,
  Category,
  Course
};
Category.hasMany(Course, {
  foreignKey: 'categoryId',
  as: 'Courses'
});

Course.belongsTo(Category, {
  foreignKey: 'categoryId',
  as: 'Category'
});
