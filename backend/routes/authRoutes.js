const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/signup/email', authController.signupWithEmail);
router.post('/signup/phone', authController.signupWithPhone);
router.post('/verify-otp-set-password', authController.verifyOTPAndSetPassword);
router.post('/login', authController.login);
router.post('/social-login', authController.socialLogin);

module.exports = router;