const UserModel = require('../models/userModel');

exports.index = async (req, res) => {
    const users = await UserModel.find({
        _id: { $ne: req.user._id }
    });

    return res.json(users.map(user => user.toResponse()));
};

exports.show = async (req, res) => {
    const { id } = req.params;

    if(!parseInt(id)){
        return res.status(404).json()
    }
    try {
        const user = await UserModel.findById(id);

        if(!user){
            return res.status(404).json()
        }

        return res.status(200).json(user.toResponse())
    } catch (e) {
        return res.status(404).json()
    }
};

