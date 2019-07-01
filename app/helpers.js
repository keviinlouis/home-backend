const errorMongoHandler = function(err, res){
    console.log(err);
    let statusCode = 500;
    if(err.name === 'ValidationError'){
        statusCode = 400;
    }
    res.status(statusCode).json(err.message)
};

function wrapAsync(fn) {
    return function(req, res, next) {
        fn(req, res, next).catch(next);
    };
}

module.exports = {
    errorMongoHandler,
    wrapAsync
};
