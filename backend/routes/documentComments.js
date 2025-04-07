const express = require('express');
const router = express.Router();
const controller = require('../controllers/documentCommentController');

router.get('/api/document-comments', controller.getDocumentComments);
router.post('/api/document-comments', controller.addDocumentComment);

module.exports = router;
