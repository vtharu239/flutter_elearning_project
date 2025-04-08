
const express = require('express');
const router = express.Router();
const vnpayController = require('../controllers/vnpayController');
const { authenticateUser } = require('../controllers/profileController');

// Create payment URL - requires authentication
router.post('/api/payment/create-payment-url', authenticateUser, vnpayController.createPaymentUrl);

// IPN handler - called by VNPay
router.get('/api/payment/vnpay-ipn', vnpayController.ipnHandler);

// Payment return handler - user is redirected here after payment
router.get('/vnpay-return', vnpayController.paymentReturn);

// Get order information - requires authentication
router.get('/api/orders/:id', authenticateUser, vnpayController.getOrderInfo);

// Get user's orders - requires authentication
router.get('/api/user/orders', authenticateUser, vnpayController.getUserOrders);

router.get('/check-purchase/:userId/:courseId', authenticateUser, vnpayController.checkPurchaseStatus);

module.exports = router;