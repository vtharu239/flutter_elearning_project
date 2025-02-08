const express = require('express');
const router = express.Router();
const emailController = require('../controllers/emailController');

router.post('/send-confirmation-email', emailController.sendConfirmationEmail);
router.get('/verify-email', emailController.verifyEmail);
router.post('/verify-email-token', emailController.verifyEmailToken);

module.exports = router;
