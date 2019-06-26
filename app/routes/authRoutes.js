const express = require('express');
const controller = require('../controllers/authController');
const router = express.Router();

router.post('/login', controller.login);
router.post('/sign-in', controller.signIn);

module.exports = router;
