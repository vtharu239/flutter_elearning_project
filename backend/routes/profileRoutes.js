const express = require('express');
const router = express.Router();
const { 
  authenticateUser, 
  upload,
  getProfile, 
  updateProfile, 
  updateAvatar,
  updateCoverImage,
  sendCurrentEmailOTP,
  verifyCurrentEmailAndSendNewOTP,
  verifyNewEmailAndComplete,
  changePassword
} = require('../controllers/profileController');

// Lấy thông tin profile
router.get('/profile', authenticateUser, getProfile);

// Cập nhật thông tin profile
router.put('/profile', authenticateUser, updateProfile);

// Cập nhật ảnh đại diện
router.post('/profile/avatar', 
  authenticateUser, 
  upload.single('avatar'), 
  updateAvatar
);

// Cập nhật ảnh bìa
router.post('/profile/cover', 
  authenticateUser, 
  upload.single('coverImage'), 
  updateCoverImage
);

// Route thay đổi email
router.post('/profile/send-current-email-otp', authenticateUser, sendCurrentEmailOTP);
router.post('/profile/verify-current-email', authenticateUser, verifyCurrentEmailAndSendNewOTP);
router.post('/profile/verify-new-email', authenticateUser, verifyNewEmailAndComplete);

// Thay đổi mật khẩu
router.post('/profile/change-password', authenticateUser, changePassword);

module.exports = router;