const UserModel = require('../models/userModel');

exports.login = async (req, res) => {
    const {email, password} = req.body;
    const user = await UserModel.findOne({email}).exec();

    if (!user) {
        return res.status(404).json({error: 'NOT_FOUNDED'})
    }
    // test a matching password
    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
        return res.status(401).json({error: 'WRONG_PASSWORD'});
    }
    res.status(200).json(user);
};

exports.signIn = async (req, res, next) => {
    const user = new UserModel(req.body);
    const userSaved = await user.save();
    console.log(userSaved);
    res.status(201).json(userSaved);
    next();
};

