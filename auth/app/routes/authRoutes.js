const express = require('express');
const controller = require('../controllers/authController');
const router = express.Router();

const {auth} = require("../middlewares");

router.post('/login', controller.login);
router.post('/sign-up', controller.signUp);
router.post('/validate-token', controller.validateToken);
router.get('/auth/me', [auth], controller.me);

router.use((err, req, res, next) => {
  if (err.name === "ValidationError") {
    const errors = {};

    Object.keys(err.errors).forEach((key) => {
      errors[key] = [err.errors[key].message];
    });

    return res.status(400).json({errors});
  }
  if (err.name === "TokenExpiredError") {
    return res.status(401).json({error: 'Sessão Expirada'})
  }
  if (err.name === "MongoError" && err.code === 11000) {
    return res.status(400).json({
      "email": {
        "message": "O campo email precisa ser único."
      }
    })
  }
  console.log(err)
  res.status(500).json(err)
});

module.exports = router;
