const express = require('express');
const controller = require('../controllers/authController');
const router = express.Router();

router.post('/login', controller.login);
router.post('/sign-in', controller.signIn);

router.use((err, req, res, next) => {
    if(err.name === "MongoError"){
        if(err.code === 11000){
            return res.status(400).json({error: 'DUPLICATE_ENTRY'})
        }
    }
    res.status(500).json(err)
});

module.exports = router;
