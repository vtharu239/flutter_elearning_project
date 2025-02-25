const express = require('express');
const router = express.Router();
const { 
  authenticateUser, 
  upload,
  getProfile, 
  updateProfile, 
  updateAvatar,
  updateCoverImage,
  verifyCurrentPassword,
  initiateEmailChange,
  completeEmailChange,
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

// Route kiểm tra mật khẩu
router.post('/profile/verify-password', authenticateUser, verifyCurrentPassword);

// Route thay đổi email
router.post('/profile/initiate-email-change', authenticateUser, initiateEmailChange);
router.post('/profile/complete-email-change', authenticateUser, completeEmailChange);

// Thay đổi mật khẩu
router.post('/profile/change-password', authenticateUser, changePassword);

module.exports = router;