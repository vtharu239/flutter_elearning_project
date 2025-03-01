const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const transporter = require('../config/email');

// Đăng ký người dùng
const signup = async (req, res) => {
  const { fullName, gender, username, email, phoneNo, password } = req.body;

  if (!fullName || !gender || !username || !email || !phoneNo || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  try {
    const user = await User.create({
      fullName,
      gender,
      username,
      email,
      phoneNo,
      password, // Password sẽ tự động được hash bởi Sequelize setter
    });

      // Tạo token xác nhận email
      const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: '1h' });

      // Phuong
      const confirmationLink = `https://equipped-living-osprey.ngrok-free.app/verify-email?token=${token}`;

      // Ngoc
      //  const confirmationLink = `https://clear-tomcat-informally.ngrok-free.app/verify-email?token=${token}`;

      // Xuan
      // const confirmationLink = `https://resolved-sawfish-equally.ngrok-free.app/verify-email?token=${token}`;

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

    } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({ 
        message: error.errors[0].path === 'email' 
          ? 'Email đã được sử dụng!' 
          : 'Tên người dùng đã tồn tại!' 
      });
    }
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
    // Tìm người dùng theo email
    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(401).json({ message: 'Email hoặc mật khẩu không đúng!' });
    }

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
        username: user.username,
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
        fullName: user.fullName,
        gender: user.gender,
        dateOfBirth: user.dateOfBirth,
        phoneNo: user.phoneNo,
        avatarUrl: user.avatarUrl,
        coverImageUrl: user.coverImageUrl      
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Kiểm tra username và email
const checkUsernameEmail = async (req, res) => {
  const { username, email } = req.body;

  if (!username && !email) {
    return res.status(400).json({ message: 'Cần ít nhất một trường để kiểm tra!' });
  }

  try {
    const response = {
      username: false,
      email: false,
      message: '',
    };

    if (username) {
      const user = await User.findOne({ where: { username } });
      if (user) {
        response.username = true;
        response.message += 'Tên người dùng đã tồn tại. ';
      }
    }

    if (email) {
      const user = await User.findOne({ where: { email } });
      if (user) {
        response.email = true;
        response.message += 'Email đã được sử dụng. ';
      }
    }

    res.json(response);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

module.exports = {
  signup,
  login,
  checkUsernameEmail,
};
