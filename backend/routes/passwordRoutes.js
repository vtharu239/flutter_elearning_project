const express = require('express');
const router = express.Router();
const passwordController = require('../controllers/passwordController');

router.post('/send-otp', passwordController.sendOTP);
router.post('/verify-otp', passwordController.verifyOTP);
router.post('/reset-password', passwordController.resetPassword);

module.exports = router;
