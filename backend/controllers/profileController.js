const { User } = require('../models');
const jwt = require('jsonwebtoken');
const transporter = require('../config/email');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Middleware xác thực người dùng
const authenticateUser = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Vui lòng đăng nhập!' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Phiên đăng nhập không hợp lệ!' });
  }
};

// Cấu hình upload ảnh
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads/profiles');
    
    // Tạo thư mục nếu chưa tồn tại
    if (!fs.existsSync(uploadDir)){
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Giới hạn 5MB
  fileFilter: (req, file, cb) => {
    const filetypes = /jpeg|jpg|png|gif/;
    const mimetype = filetypes.test(file.mimetype);
    const extname = filetypes.test(path.extname(file.originalname).toLowerCase());

    if (mimetype && extname) {
      return cb(null, true);
    }
    cb(new Error('Chỉ chấp nhận file ảnh (jpeg/jpg/png/gif)!'));
  }
});

// Lấy thông tin profile
const getProfile = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.userId, {
      attributes: { 
        exclude: ['password'] 
      }
    });

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Cập nhật profile
const updateProfile = async (req, res) => {
  const { firstName, lastName, gender, dateOfBirth, phoneNo, username, email } = req.body;
  
  try {
    const user = await User.findByPk(req.user.userId);

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    // Kiểm tra username
    if (username && username !== user.username) {
      const existingUsername = await User.findOne({ where: { username } });
      if (existingUsername) {
        return res.status(400).json({ message: 'Tên người dùng đã tồn tại!' });
      }
    }

    // Cập nhật các trường
    if (firstName) user.firstName = firstName;
    if (lastName) user.lastName = lastName;
    if (gender) user.gender = gender;
    if (dateOfBirth) user.dateOfBirth = dateOfBirth;
    if (phoneNo) user.phoneNo = phoneNo;
    if (username) user.username = username;
    if (email) user.email = email;

    await user.save();

    const updatedUser = await User.findByPk(user.id, {
      attributes: { exclude: ['password'] }
    });

    res.status(200).json(updatedUser);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Cập nhật ảnh đại diện
const updateAvatar = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.userId);

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    // Xóa ảnh cũ nếu tồn tại
    if (user.avatarUrl) {
      const oldFilePath = path.join(__dirname, '../', user.avatarUrl);
      if (fs.existsSync(oldFilePath)) {
        fs.unlinkSync(oldFilePath);
      }
    }

    // Cập nhật ảnh mới
    const avatarPath = req.file.path;
    const relativePath = avatarPath.split('uploads')[1];
    user.avatarUrl = `/uploads${relativePath}`;
    await user.save();

    res.status(200).json({ 
      message: 'Cập nhật ảnh đại diện thành công!', 
      avatarUrl: user.avatarUrl 
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Cập nhật ảnh bìa
const updateCoverImage = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.userId);

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    // Xóa ảnh bìa cũ nếu tồn tại
    if (user.coverImageUrl) {
      const oldFilePath = path.join(__dirname, '../', user.coverImageUrl);
      if (fs.existsSync(oldFilePath)) {
        fs.unlinkSync(oldFilePath);
      }
    }

    // Cập nhật ảnh bìa mới
    const coverImagePath = req.file.path;
    const relativePath = coverImagePath.split('uploads')[1];
    user.coverImageUrl = `/uploads${relativePath}`;
    await user.save();

    res.status(200).json({ 
      message: 'Cập nhật ảnh bìa thành công!', 
      coverImageUrl: user.coverImageUrl 
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Gửi mã OTP để thay đổi email
const sendEmailChangeOTP = async (req, res) => {
    const { currentEmail, newEmail } = req.body;
  
    if (!currentEmail || !newEmail) {
      return res.status(400).json({ message: 'Vui lòng cung cấp email hiện tại và email mới!' });
    }
  
    try {
      // Kiểm tra người dùng
      const user = await User.findOne({ where: { email: currentEmail } });
      if (!user) {
        return res.status(404).json({ message: 'Người dùng không tồn tại!' });
      }
  
      // Kiểm tra email mới đã tồn tại chưa
      const existingUser = await User.findOne({ where: { email: newEmail } });
      if (existingUser) {
        return res.status(400).json({ message: 'Email mới đã được sử dụng!' });
      }
  
      // Tạo mã OTP
      const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
      const otpToken = jwt.sign(
        { 
          currentEmail, 
          newEmail, 
          otp: otpCode 
        }, 
        process.env.JWT_SECRET, 
        { expiresIn: '10m' }
      );
  
      // Gửi email chứa mã OTP
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: newEmail,
        subject: 'Mã OTP Thay Đổi Email',
        html: `
          <h2>Mã OTP Thay Đổi Email</h2>
          <p>Mã OTP của bạn là: <strong>${otpCode}</strong></p>
          <p>Mã này có hiệu lực trong 10 phút.</p>
        `
      });
  
      res.status(200).json({ 
        otpToken, 
        message: 'Mã OTP đã được gửi đến email mới!' 
      });
    } catch (error) {
      console.error('Lỗi gửi OTP:', error);
      res.status(500).json({ message: 'Lỗi server!' });
    }
  };
  
  // Xác thực OTP và thay đổi email
  const verifyEmailChangeOTP = async (req, res) => {
    const { otpToken, otp } = req.body;
  
    if (!otpToken || !otp) {
      return res.status(400).json({ message: 'Vui lòng cung cấp token và mã OTP!' });
    }
  
    try {
      // Giải mã token
      const decoded = jwt.verify(otpToken, process.env.JWT_SECRET);
  
      // Kiểm tra mã OTP
      if (decoded.otp !== otp) {
        return res.status(400).json({ message: 'Mã OTP không chính xác!' });
      }
  
      // Tìm người dùng
      const user = await User.findOne({ where: { email: decoded.currentEmail } });
      if (!user) {
        return res.status(404).json({ message: 'Người dùng không tồn tại!' });
      }
  
      // Cập nhật email và đặt lại trạng thái xác thực
      user.email = decoded.newEmail;
    //   user.isEmailVerified = false; // Yêu cầu xác thực lại
  
      await user.save();
  
      // Gửi email thông báo
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: decoded.newEmail,
        subject: 'Thông Báo Thay Đổi Email',
        html: `
          <h2>Thay Đổi Email Thành Công</h2>
          <p>Email của bạn đã được thay đổi. Vui lòng xác thực lại email mới.</p>
        `
      });
  
      res.status(200).json({ 
        message: 'Thay đổi email thành công!' 
      });
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        return res.status(400).json({ message: 'Mã OTP đã hết hạn!' });
      }
      console.error('Lỗi xác thực OTP:', error);
      res.status(500).json({ message: 'Lỗi server!' });
    }
  };

module.exports = {
  authenticateUser,
  upload,
  getProfile,
  updateProfile,
  updateAvatar,
  updateCoverImage,
  sendEmailChangeOTP,
  verifyEmailChangeOTP
};