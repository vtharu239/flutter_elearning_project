const jwt = require('jsonwebtoken');
const db = require('../config/database');
const transporter = require('../config/email');

// Gửi email xác nhận
const sendConfirmationEmail = async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email là bắt buộc!' });
  }

  try {
    const token = jwt.sign({ email }, process.env.JWT_SECRET, { expiresIn: '1h' });
    
    // Ngoc
    // const confirmationLink = `https://clear-tomcat-informally.ngrok-free.app/verify-email?token=${token}`;

    // Xuan
    const confirmationLink = `https://resolved-sawfish-equally.ngrok-free.app/verify-email?token=${token}`;

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'Xác nhận email',
      html: `
        <h2>Xác nhận email của bạn</h2>
        <p>Vui lòng nhấp vào liên kết sau để xác nhận email:</p>
        <a href="${confirmationLink}">Xác nhận email</a>
      `,
    });

    res.status(200).json({ message: 'Email xác nhận đã được gửi!' });
  } catch (error) {
    res.status(500).json({ message: 'Không thể gửi email!' });
  }
};

// Xác nhận email
const verifyEmail = async (req, res) => {
  const { token } = req.query;

  if (!token) {
    return res.status(400).send('<h1>Token không hợp lệ!</h1>');
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const query = 'UPDATE users SET isEmailVerified = 1 WHERE email = ?';
   
    db.query(query, [decoded.email], (err) => {
      if (err) {
        return res.status(500).send('<h1>Lỗi xác nhận email!</h1>');
      }

      // Trả về HTML thân thiện với người dùng
      res.send(`
        <h1>Xác nhận email thành công!</h1>
        <p>Bạn có thể đóng tab này và quay lại ứng dụng.</p>
      `);
    });
  } catch (error) {
    res.status(400).send('<h1>Token không hợp lệ hoặc đã hết hạn!</h1>');
  }
};

// Xác nhận token email
const verifyEmailToken = async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: 'Email không hợp lệ!' });

  try {
    const query = 'SELECT isEmailVerified FROM users WHERE email = ?';
    db.query(query, [email], (err, results) => {
      if (err) throw err;
      if (results.length === 0) {
        return res.status(404).json({ message: 'Không tìm thấy email!' });
      }
      if (results[0].isEmailVerified === 1) {
        return res.status(200).json({ message: 'Email đã được xác nhận!' });
      }
      res.status(400).json({ message: 'Email chưa được xác nhận!' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server!' });
  }
}

module.exports = {
  sendConfirmationEmail,
  verifyEmail,
  verifyEmailToken
};
