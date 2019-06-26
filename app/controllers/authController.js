const UserModel = require('../models/userModel');
const { errorMongoHandler } = require('../helpers');

exports.login = (req, res, next) => {
    UserModel.findOne(req.body).exec(function (err, user) {
        if (err) return errorMongoHandler(err);

        if(!user){
            res.status(404).json({error:'NOT_FOUNDED'})
        }

        res.status(200).json(user);
    });
};

exports.signIn = (req, res) => {
   const user = new UserModel(req.body);
   user.save(function(err){
       if (err) return errorMongoHandler(err);

       res.status(201).json(user);
   })
};

