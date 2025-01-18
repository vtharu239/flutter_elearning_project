const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const nodemailer = require('nodemailer'); // Thêm thư viện gửi email

const app = express();
const port = 4000;
const cors = require('cors');
const { getMaxListeners } = require('nodemailer/lib/xoauth2');
app.use(cors());

// Cấu hình MySQL
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '123456789', 
  database: 'elearning_db',  
});

// Kết nối MySQL
db.connect((err) => {
  if (err) throw err;
  console.log('Connected to MySQL');
});

// Middleware
app.use(bodyParser.json());

// Đăng ký người dùng
app.post('/signup', async (req, res) => {
  const { firstName, lastName, username, email, phoneNo, password } = req.body;

  if (!firstName || !lastName || !username || !email || !phoneNo || !password) {
    return res.status(400).send({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  // Mã hóa mật khẩu
  const hashedPassword = await bcrypt.hash(password, 10);

  // Thêm người dùng vào database
  const query = 'INSERT INTO users (firstName, lastName, username, email, phoneNo, password) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(query, [firstName, lastName, username, email, phoneNo, hashedPassword], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).send({ message: 'Lỗi máy chủ!' });
    }
    res.status(201).send({ message: 'Đăng ký thành công!' });
  });
});


// Chạy server
app.listen(4000, 'localhost', () => {
  console.log('Server running on http://localhost:4000');
});

// Cấu hình transporter cho nodemailer
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: "bobacoderohyeah@gmail.com", // Thay bằng email của bạn
    pass: "ywjt jnum baey foej", // Thay bằng mật khẩu ứng dụng email của bạn
  },
});

// Gửi email xác nhận
app.post('/send-confirmation-email', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).send({ message: 'Email là bắt buộc!' });
  }

  // Tạo token xác nhận
  const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: '1h' });

  // Gửi email
  const confirmationLink = `http://localhost:4000/verify-email?token=${token}`;
  const mailOptions = {
    from: "bobacoderohyeah@gmail.com",
    to: email,
    subject: 'Xác nhận email',
    text: `Vui lòng nhấp vào liên kết sau để xác nhận email: ${confirmationLink}`,
  };

  transporter.sendMail(mailOptions, (err, info) => {
    if (err) {
      console.error(err);
      return res.status(500).send({ message: 'Không thể gửi email!' });
    }
    res.status(200).send({ message: 'Email xác nhận đã được gửi!' });
  });
});

// Xác nhận email
app.get('/verify-email', async (req, res) => {
  const { token } = req.query;

  if (!token) {
    return res.status(400).send({ message: 'Token không hợp lệ!' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const { email } = decoded;

    // Cập nhật trạng thái xác nhận email trong database
    const query = 'UPDATE users SET isEmailVerified = 1 WHERE email = ?';
    db.query(query, [email], (err, result) => {
      if (err) {
        console.error(err);
        return res.status(500).send({ message: 'Lỗi máy chủ!' });
      }
      res.status(200).send({ message: 'Email xác nhận thành công!' });
    });
  } catch (error) {
    return res.status(400).send({ message: 'Token hết hạn hoặc không hợp lệ!' });
  }
});
app.use((req, res) => {
  res.status(404).send({ message: 'Endpoint không tồn tại!' });
});
