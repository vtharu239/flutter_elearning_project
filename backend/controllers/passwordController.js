const bcrypt = require('bcrypt');
const db = require('../config/database');
const transporter = require('../config/email');
const jwt = require('jsonwebtoken');

// Gửi mã OTP
const sendOTP = async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ message: 'Email không được để trống!' });
  }

  try {
    const [results] = await db.query('SELECT id FROM users WHERE email = ?', [email]);

    if (results.length === 0) {
      return res.status(404).json({ message: 'Email không tồn tại!' });
    }

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const otpToken = jwt.sign({ email, otp: otpCode }, process.env.JWT_SECRET, { expiresIn: '10m' });

    const mailOptions = {
      from: 'bobacoderohyeah@gmail.com',
      to: email,
      subject: 'Mã OTP của bạn',
      text: `Mã OTP của bạn là: ${otpCode}. Mã này sẽ hết hạn sau 10 phút.`,
    };

    await transporter.sendMail(mailOptions);
    res.status(200).json({ otpToken, message: 'Mã OTP đã được gửi!' });
   
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
  const { email, newPassword, resetToken } = req.body;

  if (!email || !newPassword || !resetToken) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  try {
    const decoded = jwt.verify(resetToken, process.env.JWT_SECRET);
    if (decoded.email !== email) {
      return res.status(400).json({ message: 'Token không hợp lệ!' });
    }

    const [rows] = await db.query('SELECT password FROM users WHERE email = ?', [email]);
   
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Email không tồn tại!' });
    }

    const oldPasswordHash = rows[0].password;
    const isSamePassword = await bcrypt.compare(newPassword, oldPasswordHash);

    if (isSamePassword) {
      return res.status(400).json({ message: 'Mật khẩu mới không được trùng với mật khẩu cũ!' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await db.query('UPDATE users SET password = ? WHERE email = ?', [hashedPassword, email]);

    res.status(200).json({ message: 'Đặt lại mật khẩu thành công!' });
   
  } catch (error) {
    console.error('Error in resetPassword:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

module.exports = {
  sendOTP,
  verifyOTP,
  resetPassword
};
