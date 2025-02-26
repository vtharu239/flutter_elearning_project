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

// Routes
const authRoutes = require('./routes/authRoutes');
const emailRoutes = require('./routes/emailRoutes');
const passwordRoutes = require('./routes/passwordRoutes');
const profileRoutes = require('./routes/profileRoutes');
const categoryRoutes = require('./routes/category');
const courseRoutes = require('./routes/course');

app.use(authRoutes);
app.use(emailRoutes);
app.use(passwordRoutes);
app.use(profileRoutes);
app.use(categoryRoutes);
app.use(courseRoutes);

// Initialize application
async function startServer() {
  try {
    // 1. First create database if it doesn't exist
    await initializeDatabase();
    
    // 2. Then sync models
    await db.sequelize.sync({ force: false, alter: true });
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