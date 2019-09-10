const express = require('express');
const controller = require('../controllers/userController');
const middlewares = require('../middlewares')
const router = express.Router();

router.use(middlewares.auth);

router.get('/user', controller.index);
router.get('/user/:id', controller.show);

router.use((err, req, res, next) => {
    if(err.name === "ValidationError"){
        return res.status(400).json(err.errors)
    }
    if(err.name === "TokenExpiredError"){
        return res.status(401).json({error: 'Sessão Expirada'})
    }
    console.log(err)
    res.status(500).json(err)
});

module.exports = router;
