const UserModel = require('../models/userModel');

exports.index = async (req, res) => {
    const users = await UserModel.find({
        $and: [
            { _id: { $ne: req.user } }
        ]
    });

    return res.json(users.map(user => user.toResponse()));
};

exports.show = async (req, res) => {
    const { id } = req.params;

    const user = await UserModel.findById(id);

    if(!user){
        return res.status(404).json()
    }

    return res.status(200).json(user.toResponse())
};

