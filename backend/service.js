const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./models');
const app = express();
require('dotenv').config();

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Initialize database and sync models
db.sequelize.sync({ force: false, alter: true }) // force: false: Không xóa và tạo lại bảng nếu nó đã tồn tại - alter: true: Tự động cập nhật schema nếu có thay đổi trong model.
  .then(() => {
    console.log('Cơ sở dữ liệu đã được đồng bộ thành công');
  })
  .catch((err) => {
    console.error('Lỗi đồng bộ cơ sở dữ liệu:', err);
  });

// Routes
const authRoutes = require('./routes/authRoutes');
const emailRoutes = require('./routes/emailRoutes');
const passwordRoutes = require('./routes/passwordRoutes');

app.use(authRoutes);
app.use(emailRoutes);
app.use(passwordRoutes);

const PORT = process.env.PORT || 80;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Máy chủ đang chạy trên port ${PORT}`);
});