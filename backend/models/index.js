const { sequelize } = require('../config/database');
const User = require('./User');
const Category = require('./Category');
const Course = require('./Course');
const Test = require('./Test');
const TestPart = require('./TestPart');
const Question = require('./Question');
const Comment = require('./Comment');
const UserTestAttempt = require('./UserTestAttempt');
const ExamTypeTags = require('./ExamTypeTags');
const Document = require('./Document');

module.exports = {
  sequelize,
  User,
  Category,
  Course,
  Test,
  TestPart,
  Question,
  Comment,
  UserTestAttempt,
  ExamTypeTags,
  Document
};

// Relationships
Category.hasMany(Course, { foreignKey: 'categoryId', as: 'Courses' });
Course.belongsTo(Category, { foreignKey: 'categoryId', as: 'Category' });

Category.hasMany(Test, { foreignKey: 'categoryId', as: 'Tests' });
Test.belongsTo(Category, { foreignKey: 'categoryId', as: 'Category' });

Test.hasMany(TestPart, { foreignKey: 'testId', as: 'Parts' });
TestPart.belongsTo(Test, { foreignKey: 'testId', as: 'Test' });

TestPart.hasMany(Question, { foreignKey: 'testPartId', as: 'Questions' });
Question.belongsTo(TestPart, { foreignKey: 'testPartId', as: 'TestPart' });

Test.hasMany(Comment, { foreignKey: 'testId', as: 'Comments' });
Comment.belongsTo(Test, { foreignKey: 'testId', as: 'Test' });
Comment.belongsTo(User, { foreignKey: 'userId', as: 'User' });

UserTestAttempt.belongsTo(Test, { foreignKey: 'testId', as: 'Test' });
Test.hasMany(UserTestAttempt, { foreignKey: 'testId', as: 'UserTestAttempts' });