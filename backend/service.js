const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Cấu hình CORS cho phép tất cả origins
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '123456789',
  database: 'elearning_db',
});

// Email configuration
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: "bobacoderohyeah@gmail.com",
    pass: "ywjt jnum baey foej",
  },
});

// Đăng ký người dùng
app.post('/signup', async (req, res) => {
  const { firstName, lastName, username, email, phoneNo, password } = req.body;
  if (!firstName || !lastName || !username || !email || !phoneNo || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const query = 'INSERT INTO users (firstName, lastName, username, email, phoneNo, password) VALUES (?, ?, ?, ?, ?, ?)';
    db.query(query, [firstName, lastName, username, email, phoneNo, hashedPassword], async (err, result) => {
      if (err) {
        if (err.code === 'ER_DUP_ENTRY') {
          if (err.sqlMessage.includes('email')) {
            return res.status(400).json({ message: 'Email đã được sử dụng!' });
          }
          if (err.sqlMessage.includes('username')) {
            return res.status(400).json({ message: 'Tên người dùng đã tồn tại!' });
          }
          return res.status(400).json({ message: 'Thông tin đã tồn tại!' });
        }
      }
      
      // Automatically send confirmation email after successful registration
      try {
        const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: '1h' });
        const confirmationLink = `https://efb4-2402-800-63b9-9991-ad7a-7bd7-b69-9945.ngrok-free.app/verify-email?token=${token}`;

        await transporter.sendMail({
          from: "bobacoderohyeah@gmail.com",
          to: email,
          subject: 'Xác nhận email',
          html: `
            <h2>Xác nhận email của bạn</h2>
            <p>Vui lòng nhấp vào liên kết sau để xác nhận email:</p>
            <a href="${confirmationLink}">Xác nhận email</a>
          `,
        });

        res.status(201).json({ 
          message: 'Đăng ký thành công! Vui lòng kiểm tra email để xác nhận.', 
          email 
        });
      } catch (emailError) {
        // If email sending fails, still return successful registration
        res.status(201).json({ 
          message: 'Đăng ký thành công! Không thể gửi email xác nhận.', 
          email 
        });
      }
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
});
// Gửi email xác nhận
app.post('/send-confirmation-email', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: 'Email là bắt buộc!' });

  try {
    const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: '1h' });
    const confirmationLink = `https://clear-tomcat-informally.ngrok-free.app/verify-email?token=${token}`;

    await transporter.sendMail({
      from: "bobacoderohyeah@gmail.com",
      to: email,
      subject: 'Xác nhận email',
      html: `
        <h2>Xác nhận email của bạn</h2>
        <p>Vui lòng nhấp vào liên kết sau để xác nhận email:</p>
        <a href="${confirmationLink}">Xác nhận email</a>
      `,
    });

    res.status(200).json({ message: 'Email xác nhận đã được gửi!' });
  } catch (error) {
    res.status(500).json({ message: 'Không thể gửi email!' });
  }
});
// Thêm route GET để xử lý verification link
app.get('/verify-email', async (req, res) => {
  const { token } = req.query;
  if (!token) {
    return res.status(400).send('<h1>Token không hợp lệ!</h1>');
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const query = 'UPDATE users SET isEmailVerified = 1 WHERE email = ?';
    
    db.query(query, [decoded.email], (err) => {
      if (err) {
        return res.status(500).send('<h1>Lỗi xác nhận email!</h1>');
      }
      // Trả về HTML thân thiện với người dùng
      res.send(`
        <h1>Xác nhận email thành công!</h1>
        <p>Bạn có thể đóng tab này và quay lại ứng dụng.</p>
      `);
    });
  } catch (error) {
    res.status(400).send('<h1>Token không hợp lệ hoặc đã hết hạn!</h1>');
  }
});


app.post('/verify-email-token', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: 'Email không hợp lệ!' });

  try {
    const query = 'SELECT isEmailVerified FROM users WHERE email = ?';
    db.query(query, [email], (err, results) => {
      if (err) throw err;
      if (results.length === 0) {
        return res.status(404).json({ message: 'Không tìm thấy email!' });
      }
      if (results[0].isEmailVerified === 1) {
        return res.status(200).json({ message: 'Email đã được xác nhận!' });
      }
      res.status(400).json({ message: 'Email chưa được xác nhận!' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
});   
app.post('/check-username-email', (req, res) => {
  const { username, email } = req.body;

  if (!username && !email) {
      return res.status(400).json({ message: 'Cần ít nhất một trường để kiểm tra!' });
  }

  let query = 'SELECT username, email FROM users WHERE ';
  const conditions = [];
  const params = [];

  if (username) {
    conditions.push('username = ?');
    params.push(username);
  }

  if (email) {
    conditions.push('email = ?');
    params.push(email);
  }

  query += conditions.join(' OR ');

  db.query(query, params, (err, results) => {
    if (err) {
      return res.status(500).json({ 
        message: 'Lỗi server!',
        error: err.message 
      });
    }

    const response = {
      username: false,
      email: false,
      message: ''
    };

    if (results.length > 0) {
      results.forEach(result => {
        if (result.username === username) {
          response.username = true;
          response.message += 'Tên người dùng đã tồn tại. ';
        }
        if (result.email === email) {
          response.email = true;
          response.message += 'Email đã được sử dụng. ';
        }
      });
    }

    res.json(response);
  });
});

// Thêm endpoint login
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  try {
    // Kiểm tra email tồn tại
    const query = 'SELECT * FROM users WHERE email = ?';
    db.query(query, [email], async (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Lỗi server!' });
      }

      if (results.length === 0) {
        return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng!' });
      }

      const user = results[0];

      // Kiểm tra email đã xác thực chưa
      if (!user.isEmailVerified) {
        return res.status(401).json({ message: 'Vui lòng xác thực email trước khi đăng nhập!' });
      }

      // Kiểm tra password
      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) {
        return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng!' });
      }

      // Tạo JWT token
      const token = jwt.sign(
        { 
          userId: user.id,
          email: user.email,
          username: user.username 
        },
        process.env.JWT_SECRET,
        { expiresIn: '24h' }
      );

      // Trả về thông tin user và token
      res.status(200).json({
        message: 'Đăng nhập thành công!',
        token,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          firstName: user.firstName,
          lastName: user.lastName
        }
      });
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
});
app.listen(80, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:80');
});
