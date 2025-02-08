const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
const transporter = require('../config/email');

// Đăng ký người dùng
const signup = async (req, res) => {
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
        return res.status(500).json({ message: 'Lỗi server!' });
      }

      // Tạo token xác nhận email
      const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: '1h' });

      // Ngoc
      // const confirmationLink = `https://clear-tomcat-informally.ngrok-free.app/verify-email?token=${token}`;

      // Xuan
      const confirmationLink = `https://resolved-sawfish-equally.ngrok-free.app/verify-email?token=${token}`;

      // Gửi email xác nhận
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
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
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Đăng nhập
const login = async (req, res) => {
  const { email, password } = req.body;

  console.log("Login API received request:", req.body); // Debug log

  if (!email || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  try {
    const query = 'SELECT * FROM users WHERE email = ?';
    db.query(query, [email], async (err, results) => {
      if (err) {
        return res.status(500).json({ message: 'Lỗi server!' });
      }

      if (results.length === 0) {
        return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng!' });
      }

      console.log("User found:", results[0]);  // Debug log

      const user = results[0];

      // Kiểm tra email đã xác thực chưa
      if (!user.isEmailVerified) {
        return res.status(401).json({ message: 'Vui lòng xác thực email trước khi đăng nhập!' });
      }

      // Kiểm tra mật khẩu
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

      console.log("Login successful! Returning token.");  // Debug log
      
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
};

// Kiểm tra username và email
const checkUsernameEmail = (req, res) => {
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
};

module.exports = {
  signup,
  login,
  checkUsernameEmail,
};
