const { DataTypes, Op } = require('sequelize');
const { sequelize } = require('../config/database');
const bcrypt = require('bcrypt');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  fullName: {
    type: DataTypes.STRING,
    allowNull: true
  },
  gender: {
    type: DataTypes.ENUM('male', 'female', 'other'),
    allowNull: true
  },
  dateOfBirth: {
    type: DataTypes.DATEONLY,
    allowNull: true
  },
  username: {
    type: DataTypes.STRING,
    allowNull: true
  },
  email: {
    type: DataTypes.STRING,
    allowNull: true,
    validate: {
      isEmail: true
    }
  },
  phoneNo: {
    type: DataTypes.STRING,
    allowNull: true
  },
  password: {
    type: DataTypes.STRING,
    allowNull: true,
    set(value) {
      const hash = bcrypt.hashSync(value, 10);
      this.setDataValue('password', hash);
    }
  },
  avatarUrl: {
    type: DataTypes.STRING,
    allowNull: true
  },
  coverImageUrl: {
    type: DataTypes.STRING,
    allowNull: true
  },
  isEmailVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  isPhoneVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  googleId: {
    type: DataTypes.STRING,
    allowNull: true
  },
  facebookId: {
    type: DataTypes.STRING,
    allowNull: true
  },
}, {
  indexes: [
    { unique: true, fields: ['email'], where: { email: { [Op.ne]: null } } },
    { unique: true, fields: ['username'], where: { username: { [Op.ne]: null } } },
    { unique: true, fields: ['phoneNo'], where: { phoneNo: { [Op.ne]: null } } },
    { unique: true, fields: ['googleId'], where: { googleId: { [Op.ne]: null } } },
    { unique: true, fields: ['facebookId'], where: { facebookId: { [Op.ne]: null } } }
  ]
});

// Hàm tạo username và fullName ngẫu nhiên
const generateRandomString = (length) => {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

User.generateRandomCredentials = () => {
  const username = `${generateRandomString(4)}${Math.floor(1000 + Math.random() * 9000)}`; // Ví dụ: abcd1234
  const fullName = `Người dùng ${generateRandomString(6)}`; // Ví dụ: Người dùng abc123
  return { username, fullName };
};

module.exports = User;