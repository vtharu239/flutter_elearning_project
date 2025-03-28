
const { CourseObjective } = require('../models');

const courseObjectiveController = {
  createObjective: async (req, res) => {
    try {
      const { courseId, objective } = req.body;
      const newObjective = await CourseObjective.create({ courseId, objective });
      res.status(201).json(newObjective);
    } catch (error) {
      res.status(500).json({ message: 'Lỗi server!', error: error.message });
    }
  },
// Add this new method
getObjectivesByCourseId: async (req, res) => {
  try {
    const { courseId } = req.params;
    const objectives = await CourseObjective.findAll({
      where: { courseId },
      order: [['id', 'ASC']]
    });
    res.status(200).json(objectives);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!', error: error.message });
  }
}
};


module.exports = courseObjectiveController;