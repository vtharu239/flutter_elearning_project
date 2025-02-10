const { Sequelize } = require('sequelize');
const mysql = require('mysql2'); // Sử dụng mysql2 để kiểm tra và tạo database
require('dotenv').config();

// Initialize database connection
const sequelize = new Sequelize(
  process.env.DB_NAME || 'elearning_db',
  process.env.DB_USER || 'root',
  process.env.DB_PASSWORD || '123456789',
  {
    host: process.env.DB_HOST || 'localhost',
    dialect: 'mysql',
    logging: false,
    define: {
      timestamps: true, // Tự động thêm createdAt và updatedAt
      paranoid: true, // Tự động thêm deletedAt (soft delete)
    },
  }
);

// Kiểm tra và tạo Database nếu chưa tồn tại
const initializeDatabase = async () => {
  const connection = mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '123456789',
  });

  return new Promise((resolve, reject) => {
    connection.query(
      `CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME || 'elearning_db'}`,
      (err) => {
        if (err) {
          console.error('Lỗi khi tạo database:', err);
          reject(err);
        } else {
          console.log('Database đã sẵn sàng!');
          resolve();
        }
        connection.end(); // Đóng kết nối
      }
    );
  });
};

// Initialize database
initializeDatabase()
  .then(() => sequelize.authenticate())
  .then(() => console.log('Kết nối cơ sở dữ liệu đã được thiết lập'))
  .catch((err) => console.error('Lỗi khi khởi tạo database:', err));

module.exports = { sequelize };