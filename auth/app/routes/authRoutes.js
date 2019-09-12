const express = require('express');
const controller = require('../controllers/authController');
const router = express.Router();

router.post('/login', controller.login);
router.post('/sign-in', controller.signIn);
router.post('/validate-token', controller.validateToken);

router.use((err, req, res, next) => {
    if(err.name === "ValidationError"){
        return res.status(400).json(err.errors)
    }
    if(err.name === "TokenExpiredError"){
        return res.status(401).json({error: 'Sessão Expirada'})
    }
    if(err.name === "MongoError" && err.code === 11000){
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
