const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/AuthController');
const UserController = require('../controllers/UserController');

// 인증 API
router.post('/api/auth/login', AuthController.login);
router.post('/api/auth/logout', AuthController.logout);
router.post('/api/auth/register', AuthController.register);

// 사용자 API
router.get('/api/users/:id', UserController.getUser);
router.put('/api/users/:id', UserController.updateUser);

module.exports = router;
