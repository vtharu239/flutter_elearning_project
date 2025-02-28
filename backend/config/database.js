const { Sequelize } = require('sequelize');
const mysql = require('mysql2');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME || 'elearning_db',
  process.env.DB_USER || 'root',
  process.env.DB_PASSWORD || '12345678',
  {
    host: process.env.DB_HOST || 'localhost',
    dialect: 'mysql',
    logging: false,
    define: {
      timestamps: true,
      paranoid: true,
    },
  }
);

async function initializeDatabase() {
  return new Promise((resolve, reject) => {
    const connection = mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '12345678',
    });

    connection.query(
      `CREATE DATABASE IF NOT EXISTS ${process.env.DB_NAME || 'elearning_db'}`,
      (err) => {
        connection.end(); // Đảm bảo đóng kết nối trong mọi trường hợp
        
        if (err) {
          console.error('Lỗi khi tạo database:', err);
          reject(err);
        } else {
          console.log('Database đã sẵn sàng!');
          resolve();
        }
      }
    );
  });
}

module.exports = { sequelize, initializeDatabase };