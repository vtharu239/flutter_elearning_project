

const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
    const Order = sequelize.define('Order', {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'id'
        }
      },
      courseId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'Courses',
          key: 'id'
        }
      },
      amount: {
        type: DataTypes.INTEGER,
        allowNull: false
      },
      status: {
        type: DataTypes.ENUM('pending', 'completed', 'failed', 'refunded'),
        defaultValue: 'pending'
      },
      description: {
        type: DataTypes.STRING
      },
      transactionId: {
        type: DataTypes.STRING
      },
      paymentMethod: {
        type: DataTypes.STRING,
        defaultValue: 'vnpay'
      },
      paymentDate: {
        type: DataTypes.DATE
      }
    }, {
      timestamps: true
    });

    module.exports = Order;