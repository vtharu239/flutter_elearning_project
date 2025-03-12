const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const transporter = require('../config/email');
const { Op } = require('sequelize');
const admin = require('firebase-admin'); // Thêm Firebase Admin SDK

// Khởi tạo Firebase Admin SDK
const serviceAccount = require('../config/firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Đăng ký bằng email
const signupWithEmail = async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: 'Email là bắt buộc!' });

  try {
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser && existingUser.isEmailVerified) {
      return res.status(400).json({ message: 'Email đã được sử dụng!' });
    }

    const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
    const otpToken = jwt.sign({ email, otp: otpCode }, process.env.JWT_SECRET, { expiresIn: '10m' });

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Mã OTP của bạn',
      text: `Mã OTP của bạn là: ${otpCode}. Hết hạn sau 10 phút.`
    });

    res.status(200).json({ otpToken, message: 'Mã OTP đã được gửi!' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Đăng ký bằng số điện thoại (dùng Firebase)
const signupWithPhone = async (req, res) => {
  const { phoneNo } = req.body;
  if (!phoneNo) return res.status(400).json({ message: 'Số điện thoại là bắt buộc!' });

  try {
    const existingUser = await User.findOne({ where: { phoneNo } });
    if (existingUser && existingUser.isPhoneVerified) {
      return res.status(400).json({ message: 'Số điện thoại đã được sử dụng!' });
    }

    // Gửi OTP qua Firebase (client-side sẽ xử lý, backend chỉ kiểm tra)
    res.status(200).json({ message: 'Vui lòng xác minh OTP qua client!' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Xác minh OTP và tạo mật khẩu
const verifyOTPAndSetPassword = async (req, res) => {
  const { otpToken, otp, password, confirmPassword, type, email, phoneNo } = req.body;

  console.log('Received request:', req.body); // Debug

  if (!otp || !password || !confirmPassword || !type) {
    return res.status(400).json({ message: 'Thiếu thông tin bắt buộc!' });
  }
  if (password !== confirmPassword) {
    return res.status(400).json({ message: 'Mật khẩu không khớp!' });
  }
  if (type === 'email' && !email) {
    return res.status(400).json({ message: 'Email là bắt buộc cho loại email!' });
  }
  if (type === 'phone' && !phoneNo) {
    return res.status(400).json({ message: 'Số điện thoại là bắt buộc cho loại phone!' });
  }

  try {
    const { username, fullName } = User.generateRandomCredentials();
    let user;

    if (type === 'email') {
      const decoded = jwt.verify(otpToken, process.env.JWT_SECRET);
      if (decoded.otp !== otp) {
        return res.status(400).json({ message: 'Mã OTP không hợp lệ!' });
      }
      if (decoded.email !== email) {
        return res.status(400).json({ message: 'Email không khớp với token!' });
      }

      user = await User.findOne({ where: { email } });
      if (!user) {
        user = await User.create({
          email,
          password,
          username,
          fullName,
          isEmailVerified: true
        });
      } else {
        await user.update({ password, isEmailVerified: true, username, fullName });
      }
    } else if (type === 'phone') {
      // Không cần otpToken từ Firebase, chỉ kiểm tra phoneNo đã tồn tại chưa
      user = await User.findOne({ where: { phoneNo } });
      if (!user) {
        user = await User.create({
          phoneNo,
          password,
          username,
          fullName,
          isPhoneVerified: true
        });
      } else {
        await user.update({ password, isPhoneVerified: true, username, fullName });
      }
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
    res.status(201).json({ message: 'Tạo tài khoản thành công!', token, user });
  } catch (error) {
    console.error('Error in verifyOTPAndSetPassword:', error);
    if (error.name === 'TokenExpiredError') {
      return res.status(400).json({ message: 'OTP đã hết hạn!' });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(400).json({ message: 'Token không hợp lệ!' });
    }
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({ message: 'Email hoặc số điện thoại đã được sử dụng!' });
    }
    return res.status(500).json({ message: 'Không thể xác minh OTP do lỗi server!', error: error.message });
  }
};

// Đăng nhập bằng email hoặc phone
const login = async (req, res) => {
  const { identifier, password } = req.body; // identifier có thể là email hoặc phone
  if (!identifier || !password) {
    return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin!' });
  }

  try {
    console.log('Login attempt with identifier:', identifier);

    // Chuẩn hóa số điện thoại
    let normalizedPhone = identifier;
    if (identifier.startsWith('+84')) {
      normalizedPhone = identifier.replace('+84', ''); // Loại bỏ +84
      if (normalizedPhone.startsWith('0')) {
        normalizedPhone = normalizedPhone.substring(1); // Loại bỏ 0 đầu nếu có
      }
      normalizedPhone = `+84${normalizedPhone}`; // Thêm lại +84
    } else if (/^\d{9,10}$/.test(identifier)) {
      normalizedPhone = identifier.startsWith('0') ? identifier.substring(1) : identifier;
      normalizedPhone = `+84${normalizedPhone}`; // Thêm +84 sau khi loại 0 đầu
    }

    console.log('Normalized phone:', normalizedPhone); // Debug

    const user = await User.findOne({
      where: {
        [Op.or]: [
          { email: identifier },
          { phoneNo: identifier }, // Định dạng gốc
          { phoneNo: normalizedPhone }, // Định dạng chuẩn hóa
        ],
      },
    });

    if (!user) {
      console.log('User not found for identifier:', identifier);
      return res.status(400).json({ message: 'Email hoặc số điện thoại không tồn tại!' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password || '');
    if (!isPasswordValid) {
      console.log('Invalid password for user:', user.id);
      return res.status(400).json({ message: 'Mật khẩu không đúng!' });
    }

    if (!user.isEmailVerified && !user.isPhoneVerified) {
      console.log('User not verified:', user.id);
      return res.status(400).json({ message: 'Tài khoản chưa được xác minh!' });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
    console.log('Login successful for user:', user.id);
    res.status(200).json({ message: 'Đăng nhập thành công!', token, user });
  } catch (error) {
    console.error('Error in login:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Đăng nhập bằng Google/Facebook
const socialLogin = async (req, res) => {
  const { idToken, provider } = req.body; // idToken từ Firebase, provider: 'google' hoặc 'facebook'
  if (!idToken || !provider) {
    return res.status(400).json({ message: 'Thiếu thông tin bắt buộc!' });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    const socialId = decodedToken.uid;
    const email = decodedToken.email;

    let user = await User.findOne({
      where: { [provider === 'google' ? 'googleId' : 'facebookId']: socialId }
    });

    if (!user && email) {
      user = await User.findOne({ where: { email } });
      if (user) {
        // Liên kết tài khoản hiện có với Google/Facebook
        await user.update({ [provider === 'google' ? 'googleId' : 'facebookId']: socialId });
      }
    }

    if (!user) {
      // Tạo tài khoản mới
      const { username, fullName } = User.generateRandomCredentials();
      user = await User.create({
        email,
        [provider === 'google' ? 'googleId' : 'facebookId']: socialId,
        username,
        fullName,
        isEmailVerified: true
      });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
    res.status(200).json({ message: 'Đăng nhập thành công!', token, user });
  } catch (error) {
    res.status(400).json({ message: 'Token không hợp lệ!' });
  }
};

module.exports = {
  signupWithEmail,
  signupWithPhone,
  verifyOTPAndSetPassword,
  login,
  socialLogin
};