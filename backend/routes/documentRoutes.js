const express = require('express');
const router = express.Router();
const documentController = require('../controllers/documentController');

router.get('/api/documents', documentController.getDocuments);
router.post('/api/documents', documentController.createDocument);
router.put('/api/documents/:id', documentController.updateDocument);
router.delete('/api/documents/:id', documentController.deleteDocument);

module.exports = router;
