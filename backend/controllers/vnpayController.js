const crypto = require('crypto');
const moment = require('moment');
const querystring = require('querystring');
const User = require('../models/User');
const Order = require('../models/order');

function sortObject(obj) {
  let sorted = {};
  const keys = Object.keys(obj).sort();
  for (let key of keys) {
    sorted[key] = obj[key];
  }
  return sorted;
}

const vnpayController = {
  createPaymentUrl: async (req, res) => {
    try {
      const userId = req.user.userId;
      const { amount, courseId, orderDescription } = req.body;

      if (!amount || !courseId) {
        return res.status(400).json({ message: 'Vui lòng nhập đầy đủ thông tin thanh toán!' });
      }

      const user = await User.findByPk(userId);
      if (!user) {
        return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
      }

      const order = await Order.create({
        userId,
        courseId,
        amount,
        status: 'pending',
        description: orderDescription || 'Thanh toán khóa học',
      });

      const vnp_TmnCode = "ADH2MKPG";
      const vnp_HashSecret = "XIEWSZDVZMTOMCLXMYXLFUFEAKPFQZKP";
      const vnp_Url = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
      const vnp_ReturnUrl = 'https://clear-tomcat-informally.ngrok-free.app/vnpay-return';

      const date = new Date();
      const createDate = moment(date).format('YYYYMMDDHHmmss');
      const ipAddr = req.headers['x-forwarded-for'] || 
        req.connection.remoteAddress || 
        req.socket.remoteAddress || 
        req.connection.socket.remoteAddress;

      let vnp_Params = {
        vnp_Version: '2.1.0',
        vnp_Command: 'pay',
        vnp_TmnCode: vnp_TmnCode,
        vnp_Locale: 'vn',
        vnp_CurrCode: 'VND',
        vnp_TxnRef: order.id.toString(),
        vnp_OrderInfo: orderDescription || `Thanh toan khoa hoc #${courseId}`,
        vnp_OrderType: 'billpayment',
        vnp_Amount: amount * 100,
        vnp_ReturnUrl: vnp_ReturnUrl,
        vnp_IpAddr: ipAddr,
        vnp_CreateDate: createDate,
      };
 
      vnp_Params = sortObject(vnp_Params);

      const signData = Object.keys(vnp_Params)
        .map(key => `${key}=${encodeURIComponent(vnp_Params[key]).replace(/%20/g, '+')}`)
        .join('&');
      console.log('Chuỗi dữ liệu để tạo chữ ký:', signData);

      const hmac = crypto.createHmac('sha512', vnp_HashSecret);
      const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
      console.log('Chữ ký được tạo:', signed);

      vnp_Params['vnp_SecureHash'] = signed;

      const paymentUrl = `${vnp_Url}?${querystring.stringify(vnp_Params)}`;

      res.status(200).json({ 
        success: true, 
        paymentUrl: paymentUrl,
        orderId: order.id,
        signData: signData,
        generatedSignature: signed
      });
    } catch (error) {
      console.error('Create payment URL error:', error);
      res.status(500).json({ message: 'Lỗi server!' });
    }
  },

  paymentReturn: async (req, res) => {
    try {
      let vnp_Params = { ...req.query }; // Sao chép toàn bộ query params
      const secureHash = vnp_Params['vnp_SecureHash'];
      delete vnp_Params['vnp_SecureHash'];
      delete vnp_Params['vnp_SecureHashType'];

      const sortedParams = sortObject(vnp_Params); // Sắp xếp tất cả tham số
      const vnp_HashSecret = "XIEWSZDVZMTOMCLXMYXLFUFEAKPFQZKP";

      const signData = Object.keys(sortedParams)
        .map(key => `${key}=${encodeURIComponent(sortedParams[key]).replace(/%20/g, '+')}`)
        .join('&');
      console.log('Return - Chuỗi dữ liệu để kiểm tra chữ ký:', signData);

      const hmac = crypto.createHmac('sha512', vnp_HashSecret);
      const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
      console.log('Return - Chữ ký được tạo lại:', signed);
      console.log('Return - Chữ ký từ VNPay:', secureHash);

      if (secureHash === signed) {
        const orderId = vnp_Params['vnp_TxnRef'];
        const responseCode = vnp_Params['vnp_ResponseCode'];

        const order = await Order.findByPk(orderId);
        if (!order) {
          return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng!' });
        }

        if (responseCode === '00') {
          order.status = 'completed';
          order.transactionId = vnp_Params['vnp_TransactionNo'];
          order.paymentDate = new Date();
          await order.save();
          return res.status(200).json({ 
            success: true, 
            message: 'Thanh toán thành công', 
            orderId: orderId 
          });
        } else {
          order.status = 'failed';
          order.transactionId = vnp_Params['vnp_TransactionNo'] || null;
          await order.save();
          return res.status(200).json({ 
            success: false, 
            message: 'Thanh toán thất bại', 
            orderId: orderId, 
            responseCode: responseCode 
          });
        }
      } else {
        console.log('Return - Chữ ký không khớp!');
        return res.status(400).json({ 
          success: false, 
          message: 'Chữ ký không hợp lệ', 
          signData: signData, 
          generated: signed, 
          received: secureHash 
        });
      }
    } catch (error) {
      console.error('Payment return error:', error);
      return res.status(500).json({ success: false, message: 'Lỗi server!' });
    }
  },

  ipnHandler: async (req, res) => {
    try {
      let vnp_Params = { ...req.query };
      const secureHash = vnp_Params['vnp_SecureHash'];
      delete vnp_Params['vnp_SecureHash'];
      delete vnp_Params['vnp_SecureHashType'];

      vnp_Params = sortObject(vnp_Params);
      const vnp_HashSecret = "XIEWSZDVZMTOMCLXMYXLFUFEAKPFQZKP";

      const signData = Object.keys(vnp_Params)
        .map(key => `${key}=${encodeURIComponent(vnp_Params[key]).replace(/%20/g, '+')}`)
        .join('&');
      console.log('IPN - Chuỗi dữ liệu để kiểm tra chữ ký:', signData);

      const hmac = crypto.createHmac('sha512', vnp_HashSecret);
      const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
      console.log('IPN - Chữ ký được tạo lại:', signed);
      console.log('IPN - Chữ ký từ VNPay:', secureHash);

      if (secureHash === signed) {
        const orderId = vnp_Params['vnp_TxnRef'];
        const transactionStatus = vnp_Params['vnp_TransactionStatus'];
        const amount = vnp_Params['vnp_Amount'] / 100;

        const order = await Order.findByPk(orderId);
        if (order) {
          if (transactionStatus === '00') {
            order.status = 'completed';
            order.transactionId = vnp_Params['vnp_TransactionNo'];
            order.paymentDate = new Date();
            await order.save();
            res.status(200).json({ RspCode: '00', Message: 'Success' });
          } else {
            order.status = 'failed';
            order.transactionId = vnp_Params['vnp_TransactionNo'] || null;
            await order.save();
            res.status(200).json({ RspCode: '00', Message: 'Success' });
          }
        } else {
          res.status(200).json({ RspCode: '01', Message: 'Order not found' });
        }
      } else {
        console.log('IPN - Chữ ký không khớp!');
        res.status(200).json({ RspCode: '97', Message: 'Invalid signature' });
      }
    } catch (error) {
      console.error('IPN handler error:', error);
      res.status(200).json({ RspCode: '99', Message: 'Unknown error' });
    }
  },

  getOrderInfo: async (req, res) => {
    try {
      const orderId = req.params.id;
      const userId = req.user.userId;

      const order = await Order.findOne({
        where: { id: orderId, userId: userId },
        include: [{
          model: User,
          as: 'User',
          attributes: ['id', 'username', 'email', 'fullName']
        }]
      });

      if (!order) {
        return res.status(404).json({ message: 'Không tìm thấy đơn hàng!' });
      }

      res.status(200).json(order);
    } catch (error) {
      console.error('Get order error:', error);
      res.status(500).json({ message: 'Lỗi server!' });
    }
  },

  getUserOrders: async (req, res) => {
    try {
      const userId = req.user.userId;
      const orders = await Order.findAll({
        where: { userId },
        order: [['createdAt', 'DESC']]
      });

      res.status(200).json(orders);
    } catch (error) {
      console.error('Get user orders error:', error);
      res.status(500).json({ message: 'Lỗi server!' });
    }
  }
};

module.exports = vnpayController;