const express = require('express');
const router = express.Router();
const { 
  authenticateUser, 
  upload,
  getProfile, 
  updateProfile, 
  updateAvatar,
  updateCoverImage,
  sendEmailChangeOTP,
  verifyEmailChangeOTP
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
router.post('/profile/send-email-change-otp', authenticateUser, sendEmailChangeOTP);
router.post('/profile/verify-email-change-otp', authenticateUser, verifyEmailChangeOTP);

module.exports = router;