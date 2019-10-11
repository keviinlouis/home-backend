const UserModel = require('../models/userModel');
const elasticsearch = require('../elasticsearch');

exports.index = async (req, res) => {
  const query = req.query.q;

  if (!query) {
    const users = await UserModel.find({
      _id: {$ne: req.user._id}
    });

    return res.json(users.map(user => user.toResponse()));
  }

  const {body} = await elasticsearch.search({
    index: 'users',
    body: {
      query: {
        bool: {
          must_not: {
            ids: {
              values: [
                req.user._id
              ]
            }
          },
          should: [
            {
              multi_match: {
                query: query,
                type : "phrase_prefix",
                fields: ['email', 'name']
              }
            }
          ],
        },
      }
    }
  });

  const ids = body.hits.hits.map(item => item._id);

  const users = await UserModel.find({
    _id: { $in: ids }
  });


  return res.json(users.map(user => user.toResponse()));


};

exports.show = async (req, res) => {
  const {id} = req.params;

  if (!parseInt(id)) {
    return res.status(404).json()
  }
  try {
    const user = await UserModel.findById(id);

    if (!user) {
      return res.status(404).json()
    }

    return res.status(200).json(user.toResponse())
  }
  catch (e) {
    return res.status(404).json()
  }
};

