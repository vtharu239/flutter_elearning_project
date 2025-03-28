const express = require('express');
const router = express.Router();
const { 
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
  updatePassword
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
router.post('/profile/initiate-email-change', authenticateUser, initiateEmailChange);
router.post('/profile/complete-email-change', authenticateUser, completeEmailChange);
router.post('/profile/unlink-email', authenticateUser, unlinkEmail);

// Thay đổi mật khẩu
router.post('/profile/initiate-password-change', authenticateUser, initiatePasswordChange);
router.post('/profile/verify-password-otp', authenticateUser, verifyPasswordOtp);
router.post('/profile/update-password', authenticateUser, updatePassword);

// Route cho số điện thoại
router.post('/profile/initiate-phone-change', authenticateUser, initiatePhoneChange);
router.post('/profile/complete-phone-change', authenticateUser, completePhoneChange);
router.post('/profile/unlink-phone', authenticateUser, unlinkPhone);

module.exports = router;