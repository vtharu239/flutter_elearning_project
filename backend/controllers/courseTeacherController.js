
const { CourseTeacher } = require('../models');

const courseTeacherController = {
  createTeacher: async (req, res) => {
    try {
      const { courseId, name, credentials } = req.body;
      const newTeacher = await CourseTeacher.create({ courseId, name, credentials });
      res.status(201).json(newTeacher);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
 getTeachersByCourseId: async (req, res) => {
  try {
    const { courseId } = req.params;
    const teachers = await CourseTeacher.findAll({
      where: { courseId }
    });
    res.status(200).json(teachers);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!', error: error.message });
  }
}
};

module.exports = courseTeacherController;