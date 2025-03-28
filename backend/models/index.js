const { sequelize } = require('../config/database');
const User = require('./User');
const Test = require('./Test');
const TestPart = require('./TestPart');
const Question = require('./Question');
const Comment = require('./Comment');
const UserTestAttempt = require('./UserTestAttempt');
const ExamTypeTags = require('./ExamTypeTags');

const Category = require('./Category');
const Course = require('./Course');
const CourseObjective = require('./CourseObjective');
const CourseTeacher = require('./CourseTeacher');
const CourseCurriculum = require('./CourseCurriculum');
const CurriculumFeature = require('./CurriculumFeature');
const CourseReview = require('./CourseReview');
const CourseRatingStat = require('./CourseRatingStat');
const Order = require('./order');
const LessonSubItem = require('./LessonSubItem');
const VocabularyWord = require('./VocabularyWord');

const Document = require('./Document');

module.exports = {
  sequelize,
  User,
  Test,
  TestPart,
  Question,
  Comment,
  UserTestAttempt,
  ExamTypeTags,
  Category,
  Course,
  CourseObjective, 
  CourseTeacher,
  CourseCurriculum, 
  CurriculumFeature, 
  CourseReview, 
  CourseRatingStat, 
  Order,
  LessonSubItem,
  VocabularyWord,
  Document
};

// Relationships
User.hasMany(Order, { foreignKey: 'userId', as: 'Orders', onDelete: 'CASCADE' });
Order.belongsTo(User, { foreignKey: 'userId', as: 'User' });

Course.hasMany(Order, { foreignKey: 'courseId', as: 'Orders', onDelete: 'CASCADE' });
Order.belongsTo(Course, { foreignKey: 'courseId', as: 'Course' });

Category.hasMany(Course, { foreignKey: 'categoryId', as: 'Courses', onDelete: 'CASCADE' });
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

Course.hasMany(CourseObjective, { foreignKey: 'courseId', as: 'Objectives', onDelete: 'CASCADE' });
CourseObjective.belongsTo(Course, { foreignKey: 'courseId', as: 'Course' });

Course.hasMany(CourseTeacher, { foreignKey: 'courseId', as: 'Teachers', onDelete: 'CASCADE' });
CourseTeacher.belongsTo(Course, { foreignKey: 'courseId', as: 'Course' });

Course.hasMany(CourseCurriculum, { foreignKey: 'courseId', as: 'Curriculum', onDelete: 'CASCADE' });
CourseCurriculum.belongsTo(Course, { foreignKey: 'courseId', as: 'Course' });

CourseCurriculum.hasMany(CurriculumFeature, { foreignKey: 'curriculumId', as: 'Features', onDelete: 'CASCADE' });
CurriculumFeature.belongsTo(CourseCurriculum, { foreignKey: 'curriculumId', as: 'Curriculum' });

Course.hasMany(CourseReview, { foreignKey: 'courseId', as: 'Reviews', onDelete: 'CASCADE' });
CourseReview.belongsTo(Course, { foreignKey: 'courseId', as: 'Course' });

Course.hasMany(CourseRatingStat, { foreignKey: 'courseId', as: 'RatingStats', onDelete: 'CASCADE' });
CourseRatingStat.belongsTo(Course, { foreignKey: 'courseId', as: 'Course' });

CourseCurriculum.hasMany(LessonSubItem, { foreignKey: 'curriculumId', as: 'SubItems', onDelete: 'CASCADE' });
LessonSubItem.belongsTo(CourseCurriculum, { foreignKey: 'curriculumId', as: 'Curriculum' });

LessonSubItem.hasMany(VocabularyWord, { foreignKey: 'subItemId', as: 'VocabularyWords', onDelete: 'CASCADE' });
VocabularyWord.belongsTo(LessonSubItem, { foreignKey: 'subItemId', as: 'SubItem' });

UserTestAttempt.belongsTo(Test, { foreignKey: 'testId', as: 'Test' });
Test.hasMany(UserTestAttempt, { foreignKey: 'testId', as: 'UserTestAttempts' });
