  const express = require('express');
  const bodyParser = require('body-parser');
  const cors = require('cors');
  const path = require('path');
  const { initializeDatabase } = require('./config/database');
  const db = require('./models');
  const app = express();
  require('dotenv').config();

  // Middleware
  app.use(cors());
  app.use(bodyParser.json());

  // Phục vụ các tệp tải lên tĩnh
  app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
  app.use('/uploads/profiles', express.static(path.join(__dirname, 'uploads/profiles')));

  // Routes
  const authRoutes = require('./routes/authRoutes');
  const emailRoutes = require('./routes/emailRoutes');
  const passwordRoutes = require('./routes/passwordRoutes');
  const profileRoutes = require('./routes/profileRoutes');
  const categoryRoutes = require('./routes/category');
  const courseRoutes = require('./routes/course');
  const courseObjective = require('./routes/courseObjective');
  const courseTeacher = require('./routes/courseTeacher');
  const courseCurriculum = require('./routes/courseCurriculum');
  const courseReview = require('./routes/courseReview');
  const courseRatingStat = require('./routes/courseRatingStat');
  const testRoutes = require('./routes/testRoutes');
  const paymentRoutes = require('./routes/paymentRoutes');
  app.use(authRoutes);
  app.use(emailRoutes);
  app.use(passwordRoutes);
  app.use(profileRoutes);
  app.use(categoryRoutes);
  app.use(courseRoutes);
  app.use(courseObjective);
  app.use(courseTeacher);
  app.use(courseCurriculum);
  app.use(courseReview);
  app.use(courseRatingStat);
  app.use(testRoutes);
  app.use(paymentRoutes);
  // Initialize application
  async function startServer() {
    try {
      // 1. First create database if it doesn't exist
      await initializeDatabase();
      
      // 2. Then sync models
      await db.sequelize.sync({ force: false, alter: true});
      console.log('Cơ sở dữ liệu đã được đồng bộ thành công');
      
      // 3. Finally start the server
      const PORT = process.env.PORT || 80;
      app.listen(PORT, '0.0.0.0', () => {
        console.log(`Máy chủ đang chạy trên port ${PORT}`);
      });
    } catch (error) {
      console.error('Lỗi khởi động server:', error);
      process.exit(1);
    }
  }

  startServer();