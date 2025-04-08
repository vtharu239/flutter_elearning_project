// documentRoutes.js
const express = require('express');
const router = express.Router();
const documentController = require('../controllers/documentController');



router.get('/documents', documentController.getDocuments);
router.post('/documents', documentController.createDocument);
router.put('/documents/:id', documentController.updateDocument);
router.delete('/documents/:id', documentController.deleteDocument);
// Thêm route cập nhật status (admin duyệt bài)
router.put('/documents/:id/status', documentController.updateStatus);

module.exports = router;
