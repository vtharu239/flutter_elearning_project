const { User } = require('../models');
const jwt = require('jsonwebtoken');
const transporter = require('../config/email');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { Op } = require('sequelize');
const admin = require('firebase-admin'); // Firebase Admin SDK

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
  const { fullName, gender, dateOfBirth, phoneNo, username } = req.body;
  
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
    if (fullName) user.fullName = fullName;
    if (gender) user.gender = gender;
    if (dateOfBirth) user.dateOfBirth = dateOfBirth;
    if (phoneNo) user.phoneNo = phoneNo;
    if (username) user.username = username;

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

    // Đảm bảo thư mục uploads/profiles tồn tại
    const uploadDir = path.join(__dirname, '../uploads/profiles');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }

    const avatarPath = '/uploads/profiles/' + req.file.filename;
    
    // Xóa ảnh cũ nếu tồn tại
    if (user.avatarUrl) {
      const oldFilePath = path.join(__dirname, '..', user.avatarUrl);
      if (fs.existsSync(oldFilePath)) {
        fs.unlinkSync(oldFilePath);
      }
    }

    user.avatarUrl = avatarPath;
    await user.save();

    const baseUrl = process.env.BASE_URL || `${req.protocol}://${req.get('host')}`;
    const fullUrl = `${baseUrl}${avatarPath}`;

    res.status(200).json({
      message: 'Cập nhật ảnh đại diện thành công!',
      avatarUrl: avatarPath,
      fullUrl: fullUrl
    });
  } catch (error) {
    console.error('Update avatar error:', error);
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
    let coverImagePath = req.file.path.replace(/\\/g, '/'); // Chuyển tất cả \ thành /
    coverImagePath = coverImagePath.replace(path.join(__dirname, '../uploads').replace(/\\/g, '/'), '/uploads');

    user.coverImageUrl = coverImagePath;
    await user.save();

    res.status(200).json({ 
      message: 'Cập nhật ảnh bìa thành công!', 
      coverImageUrl: user.coverImageUrl 
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Khởi tạo thay đổi email và gửi OTP
const initiateEmailChange = async (req, res) => {
  const { newEmail } = req.body;

  if (!newEmail || !newEmail.trim()) {
    return res.status(400).json({ message: 'Vui lòng cung cấp email mới hợp lệ!' });
  }

  try {
    // Tìm user hiện tại
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
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
        userId: user.id,
        currentEmail: user.email || null,
        newEmail: newEmail,
        otp: otpCode
      },
      process.env.JWT_SECRET,
      { expiresIn: '10m' }
    );

    // Kiểm tra email mới một lần nữa trước khi gửi
    if (!newEmail || !newEmail.trim()) {
      return res.status(400).json({ message: 'Email mới không hợp lệ!' });
    }

    // Gửi email chứa mã OTP
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: newEmail,
      subject: 'Xác Thực Email Mới',
      html: `
        <h2>Xác Thực Email Mới</h2>
        <p>Bạn đã yêu cầu ${user.email ? 'thay đổi email từ ' + user.email + ' sang ' + newEmail : 'thêm email ' + newEmail}</p>
        <p>Mã OTP của bạn là: <strong>${otpCode}</strong></p>
        <p>Mã này có hiệu lực trong 10 phút.</p>
        <p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email này.</p>
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

// Xác thực OTP và hoàn tất thay đổi email
const completeEmailChange = async (req, res) => {
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

    // Kiểm tra email mới có tồn tại không
    if (!decoded.newEmail || !decoded.newEmail.trim()) {
      return res.status(400).json({ message: 'Email mới không hợp lệ!' });
    }

    // Tìm người dùng
    const user = await User.findByPk(decoded.userId);
    if (!user) {
      return res.status(404).json({ message: 'Người dùng không tồn tại!' });
    }

    // Kiểm tra lại email mới có bị trùng không
    const existingUser = await User.findOne({ where: { email: decoded.newEmail } });
    if (existingUser && existingUser.id !== user.id) {
      return res.status(400).json({ message: 'Email mới đã được sử dụng!' });
    }

    // Lưu email cũ
    const oldEmail = user.email;

    // Cập nhật email mới
    user.email = decoded.newEmail;
    user.isEmailVerified = true; // Đánh dấu email đã được xác thực
    await user.save();

    // Tạo một mảng promises để xử lý bất đồng bộ
    const emailPromises = [];

    // Gửi thông báo đến email cũ (chỉ khi email cũ tồn tại và khác email mới)
    if (oldEmail && oldEmail.trim() && oldEmail !== decoded.newEmail) {
      const oldEmailPromise = transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: oldEmail,
        subject: 'Thông Báo Thay Đổi Email',
        html: `
          <h2>Email Của Bạn Đã Được Thay Đổi</h2>
          <p>Email của tài khoản đã được thay đổi thành: ${decoded.newEmail}</p>
          <p>Nếu bạn không thực hiện thay đổi này, vui lòng liên hệ với chúng tôi ngay lập tức.</p>
        `
      }).catch(err => {
        console.error('Không thể gửi email thông báo đến email cũ:', err);
        // Tiếp tục mà không làm gián đoạn luồng
      });
      
      emailPromises.push(oldEmailPromise);
    }

    // Gửi xác nhận đến email mới
    if (decoded.newEmail && decoded.newEmail.trim()) {
      const newEmailPromise = transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: decoded.newEmail,
        subject: 'Thay Đổi Email Thành Công',
        html: `
          <h2>Thay Đổi Email Thành Công</h2>
          <p>Email của bạn đã được thay đổi thành công.</p>
          <p>Bạn có thể sử dụng email này để đăng nhập vào tài khoản.</p>
        `
      }).catch(err => {
        console.error('Không thể gửi email xác nhận đến email mới:', err);
        // Tiếp tục mà không làm gián đoạn luồng
      });
      
      emailPromises.push(newEmailPromise);
    }

    // Đợi tất cả các email được gửi (hoặc thất bại) mà không dừng luồng chính
    await Promise.allSettled(emailPromises);

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

  // Kiểm tra độ mạnh của mật khẩu
const isStrongPassword = (password) => {
  const minLength = 8;
  const hasUpperCase = /[A-Z]/.test(password);
  const hasLowerCase = /[a-z]/.test(password);
  const hasNumbers = /\d/.test(password);
  const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

  return (
    password.length >= minLength &&
    hasUpperCase &&
    hasLowerCase &&
    hasNumbers &&
    hasSpecialChar
  );
};

// Khởi tạo thay đổi mật khẩu và gửi OTP
const initiatePasswordChange = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    let target;
    if (user.phoneNo) {
      target = user.phoneNo;
    } else if (user.email) {
      target = user.email;
    } else {
      return res.status(400).json({ message: 'Không có email hoặc số điện thoại để gửi OTP!' });
    }

    if (user.phoneNo) {
      // Trả về thông tin để client gửi OTP qua Firebase
      return res.status(200).json({ 
        message: 'Vui lòng xác minh số điện thoại qua OTP!',
        method: 'phone',
        target: user.phoneNo
      });
    } else if (user.email) {
      const otpCode = Math.floor(100000 + Math.random() * 900000).toString();
      const otpToken = jwt.sign(
        {
          userId: user.id,
          otp: otpCode
        },
        process.env.JWT_SECRET,
        { expiresIn: '10m' }
      );

      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: 'Xác Thực Thay Đổi Mật Khẩu',
        html: `
          <h2>Xác Thực Thay Đổi Mật Khẩu</h2>
          <p>Mã OTP của bạn là: <strong>${otpCode}</strong></p>
          <p>Mã này có hiệu lực trong 10 phút.</p>
          <p>Nếu bạn không yêu cầu thay đổi mật khẩu, vui lòng bỏ qua email này.</p>
        `
      });

      return res.status(200).json({
        otpToken,
        message: 'Mã OTP đã được gửi đến email của bạn!'
      });
    }
  } catch (error) {
    console.error('Lỗi gửi OTP thay đổi mật khẩu:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Xác minh OTP thay đổi mật khẩu
const verifyPasswordOtp = async (req, res) => {
  const { otpToken, otp } = req.body;

  if (!otpToken || !otp) {
    return res.status(400).json({ message: 'Vui lòng cung cấp token và mã OTP!' });
  }

  try {
    const decoded = jwt.verify(otpToken, process.env.JWT_SECRET);
    if (decoded.otp !== otp) {
      return res.status(400).json({ message: 'Mã OTP không chính xác!' });
    }

    const user = await User.findByPk(decoded.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    const idToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: '10m' }
    );

    res.status(200).json({ idToken, message: 'Xác minh OTP thành công!' });
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(400).json({ message: 'Mã OTP đã hết hạn!' });
    }
    console.error('Lỗi xác minh OTP:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Cập nhật mật khẩu mới
const updatePassword = async (req, res) => {
  const { idToken, newPassword, confirmPassword } = req.body;

  if (!idToken || !newPassword || !confirmPassword) {
    return res.status(400).json({ message: 'Vui lòng cung cấp đầy đủ thông tin!' });
  }

  if (newPassword !== confirmPassword) {
    return res.status(400).json({ message: 'Mật khẩu xác nhận không khớp!' });
  }

  if (!isStrongPassword(newPassword)) {
    return res.status(400).json({ 
      message: 'Mật khẩu mới phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt!' 
    });
  }

  try {
    let user;
    // Thử xác minh idToken bằng Firebase trước (cho trường hợp phone)
    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const phoneNumber = decodedToken.phone_number;
      user = await User.findOne({ where: { phoneNo: phoneNumber } });
      if (!user) {
        return res.status(404).json({ message: 'Không tìm thấy người dùng với số điện thoại này!' });
      }
    } catch (firebaseError) {
      // Nếu không phải token Firebase, thử xác minh bằng jsonwebtoken (cho trường hợp email)
      if (firebaseError.code === 'auth/argument-error' || firebaseError.code === 'auth/invalid-id-token') {
        const decoded = jwt.verify(idToken, process.env.JWT_SECRET, { algorithms: ['HS256'] });
        user = await User.findByPk(decoded.userId);
        if (!user) {
          return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
        }
      } else {
        throw firebaseError;
      }
    }

    // Cập nhật mật khẩu
    user.password = newPassword;
    await user.save();

    if (user.email) {
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: 'Thông Báo Thay Đổi Mật Khẩu',
        html: `
          <h2>Thay Đổi Mật Khẩu Thành Công</h2>
          <p>Mật khẩu của bạn đã được thay đổi thành công.</p>
          <p>Nếu bạn không thực hiện thay đổi này, vui lòng liên hệ với chúng tôi ngay lập tức.</p>
        `
      });
    }

    res.status(200).json({ message: 'Thay đổi mật khẩu thành công!' });
  } catch (error) {
    if (error.name === 'TokenExpiredError' || error.code === 'auth/id-token-expired') {
      return res.status(400).json({ message: 'Token đã hết hạn!' });
    }
    console.error('Lỗi cập nhật mật khẩu:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Khởi tạo thay đổi số điện thoại và gửi OTP qua Firebase
const initiatePhoneChange = async (req, res) => {
  const { newPhoneNo } = req.body;

  if (!newPhoneNo) {
    return res.status(400).json({ message: 'Vui lòng cung cấp số điện thoại mới!' });
  }

  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    // Kiểm tra số điện thoại mới đã tồn tại chưa
    const existingUser = await User.findOne({ where: { phoneNo: newPhoneNo } });
    if (existingUser) {
      return res.status(400).json({ message: 'Số điện thoại mới đã được sử dụng!' });
    }

    // Trả về thông tin để client gửi OTP qua Firebase
    res.status(200).json({ message: 'Vui lòng xác minh số điện thoại mới qua OTP!' });
  } catch (error) {
    console.error('Lỗi khởi tạo thay đổi số điện thoại:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Hoàn tất thay đổi số điện thoại
const completePhoneChange = async (req, res) => {
  const { newPhoneNo, idToken } = req.body;

  if (!newPhoneNo || !idToken) {
    return res.status(400).json({ message: 'Vui lòng cung cấp số điện thoại mới và token!' });
  }

  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    // Xác minh idToken từ Firebase
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    if (decodedToken.phone_number !== newPhoneNo) {
      return res.status(400).json({ message: 'Số điện thoại không khớp với token!' });
    }

    // Xóa số điện thoại cũ khỏi Firebase nếu có
    if (user.phoneNo) {
      try {
        const firebaseUser = await admin.auth().getUserByPhoneNumber(user.phoneNo);
        await admin.auth().deleteUser(firebaseUser.uid);
      } catch (firebaseError) {
        console.warn('Không thể xóa số cũ khỏi Firebase:', firebaseError);
      }
    }

    // Cập nhật số điện thoại mới
    user.phoneNo = newPhoneNo;
    user.isPhoneVerified = true;
    await user.save();

    res.status(200).json({ message: 'Thay đổi số điện thoại thành công!' });
  } catch (error) {
    console.error('Lỗi hoàn tất thay đổi số điện thoại:', error);
    if (error.code === 'auth/id-token-expired') {
      return res.status(400).json({ message: 'Token đã hết hạn!' });
    }
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Hủy liên kết số điện thoại
const unlinkPhone = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    if (!user.phoneNo) {
      return res.status(400).json({ message: 'Không có số điện thoại để hủy liên kết!' });
    }

    // Kiểm tra xem tài khoản còn phương thức xác thực nào khác không
    if (!user.email) {
      return res.status(400).json({
        message: 'Không thể hủy liên kết số điện thoại vì đây là phương thức xác thực duy nhất của bạn!',
      });
    }

    // Xóa số điện thoại khỏi Firebase
    try {
      const firebaseUser = await admin.auth().getUserByPhoneNumber(user.phoneNo);
      await admin.auth().deleteUser(firebaseUser.uid);
    } catch (firebaseError) {
      console.warn('Không thể xóa số khỏi Firebase:', firebaseError);
    }

    // Xóa số điện thoại khỏi MySQL
    user.phoneNo = null;
    user.isPhoneVerified = false;
    await user.save();

    res.status(200).json({ message: 'Hủy liên kết số điện thoại thành công!' });
  } catch (error) {
    console.error('Lỗi hủy liên kết số điện thoại:', error);
    res.status(500).json({ message: 'Lỗi server!' });
  }
};

// Hủy liên kết email
const unlinkEmail = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.userId);
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }

    if (!user.email) {
      return res.status(400).json({ message: 'Không có email để hủy liên kết!' });
    }

    // Kiểm tra xem tài khoản còn phương thức xác thực nào khác không
    if (!user.phoneNo) {
      return res.status(400).json({
        message: 'Không thể hủy liên kết email vì đây là phương thức xác thực duy nhất của bạn!',
      });
    }

    // Lưu email cũ để gửi thông báo
    const oldEmail = user.email;

    // Xóa email khỏi MySQL
    user.email = null;
    user.isEmailVerified = false;
    await user.save();

    // Gửi thông báo đến email cũ (kiểm tra email tồn tại)
    if (oldEmail && oldEmail.trim()) {
      try {
        await transporter.sendMail({
          from: process.env.EMAIL_USER,
          to: oldEmail,
          subject: 'Thông Báo Hủy Liên Kết Email',
          html: `
            <h2>Email Đã Bị Hủy Liên Kết</h2>
            <p>Email của bạn (${oldEmail}) đã bị hủy liên kết khỏi tài khoản.</p>
            <p>Nếu bạn không thực hiện hành động này, vui lòng liên hệ với chúng tôi ngay lập tức.</p>
          `,
        });
      } catch (emailError) {
        console.error('Không thể gửi email thông báo hủy liên kết:', emailError);
        // Tiếp tục xử lý mà không làm gián đoạn luồng chính
      }
    }

    res.status(200).json({ message: 'Hủy liên kết email thành công!' });
  } catch (error) {
    console.error('Lỗi hủy liên kết email:', error);
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
  initiateEmailChange,
  completeEmailChange,
  initiatePhoneChange, 
  completePhoneChange,
  unlinkPhone,        
  unlinkEmail,
  initiatePasswordChange,
  verifyPasswordOtp,
  updatePassword,
};