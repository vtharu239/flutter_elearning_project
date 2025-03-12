const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const transporter = require('../config/email');
const admin = require('firebase-admin');

// Gửi mã OTP
const sendOTP = async (req, res) => {
  const { email, phoneNo } = req.body;

  if (!email && !phoneNo) {
    return res.status(400).json({ message: 'Email hoặc số điện thoại là bắt buộc!' });
  }

  try {
    let user;
    if (email) {
      user = await User.findOne({ where: { email } });
      if (!user) {
        return res.status(404).json({ message: 'Email không tồn tại!' });
      }

      const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
      const otpToken = jwt.sign({ email, otp: otpCode }, process.env.JWT_SECRET, { expiresIn: '10m' });

      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Mã OTP của bạn',
        text: `Mã OTP của bạn là: ${otpCode}. Mã này sẽ hết hạn sau 10 phút.`,
      };

      await transporter.sendMail(mailOptions);
      res.status(200).json({ otpToken, message: 'Mã OTP đã được gửi qua email!' });
    } else if (phoneNo) {
      user = await User.findOne({ where: { phoneNo } });
      if (!user) {
        return res.status(404).json({ message: 'Số điện thoại không tồn tại!' });
      }
      // OTP sẽ được gửi qua Firebase từ client, backend chỉ trả về thông báo
      res.status(200).json({ message: 'Vui lòng xác minh OTP qua SMS!' });
    }
  } catch (error) {
    console.error('Error in sendOTP:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Xác nhận mã OTP
const verifyOTP = async (req, res) => {
  const { otpToken, otp } = req.body;

  if (!otpToken || !otp) {
    return res.status(400).json({ message: 'Vui lòng nhập mã OTP và token!' });
  }

  try {
    const decoded = jwt.verify(otpToken, process.env.JWT_SECRET);
    if (decoded.otp !== otp) {
      return res.status(400).json({ message: 'Mã OTP không hợp lệ!' });
    }

    const resetToken = jwt.sign({ email: decoded.email }, process.env.JWT_SECRET, { expiresIn: '15m' });
    res.status(200).json({ resetToken, message: 'Xác thực OTP thành công!' });
  } catch (error) {
    console.error('Error in verifyOTP:', error);
    return res.status(400).json({ message: 'OTP đã hết hạn hoặc không hợp lệ!' });
  }
};

// Đổi mật khẩu
const resetPassword = async (req, res) => {
  const { identifier, newPassword, resetToken, type } = req.body;

  console.log('Reset password request:', { identifier, resetToken, type });

  if (!identifier || !newPassword || !resetToken || !type) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  try {
    let user;
    if (type === 'email') {
      const decoded = jwt.verify(resetToken, process.env.JWT_SECRET);
      console.log('Email token decoded:', decoded);
      if (decoded.email !== identifier) {
        return res.status(400).json({ message: 'Token không hợp lệ!' });
      }
      user = await User.findOne({ where: { email: identifier } });
    } else if (type === 'phone') {
      try {
        const decodedToken = await admin.auth().verifyIdToken(resetToken);
        console.log('Phone token decoded:', decodedToken);
        if (decodedToken.phone_number !== identifier) {
          return res.status(400).json({ message: 'Token không hợp lệ!' });
        }
        user = await User.findOne({ where: { phoneNo: identifier } });
      } catch (firebaseError) {
        console.error('Firebase token error:', firebaseError);
        return res.status(400).json({ message: 'Token Firebase không hợp lệ!' });
      }
    }

    if (!user) {
      console.log('User not found for identifier:', identifier);
      return res.status(404).json({ message: 'Tài khoản không tồn tại!' });
    }

    await User.update({ password: newPassword }, { where: { id: user.id } });
    res.status(200).json({ message: 'Đặt lại mật khẩu thành công!' });
  } catch (error) {
    console.error('Error in resetPassword:', error);
    if (error.name === 'TokenExpiredError') {
      return res.status(400).json({ message: 'Token đã hết hạn!' });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(400).json({ message: 'Token không hợp lệ!' });
    }
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

module.exports = {
  sendOTP,
  verifyOTP,
  resetPassword,
};