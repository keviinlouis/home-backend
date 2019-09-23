const express = require('express');
const router = express.Router();
const {auth} = require('./middlewares');
const ApiGateway = require('./services/apiService');

const services = [
  'financial'
];

const routerGenerator = function(resource){
  const url = process.env[`${resource.toUpperCase()}_URL`];

  router.use(auth);

  router.use((req, res, next) => {
    req.api = new ApiGateway(url, req.user.id);
    req.service_path = req.url.replace('/financial');
    next();
  });

  router.get('*', async (req, res) => {
    const response = await req.api.get(req.service_path);
    res.json(response)
  });

  router.post('*', async (req, res) => {
    const response = await req.api.post(req.service_path, req.body);
    res.json(response)
  });

  router.put('*', async (req, res) => {
    const response = await req.api.put(req.service_path, req.body);
    res.json(response)
  });

  router.delete('*', async (req, res) => {
    const response = await req.api.delete(req.service_path);
    res.json(response)
  });

  router.use((err, req, res, next) => {
    if(err.isAxiosError){
      return res.status(err.response.status).json(err.response.data)
    }

    next(err);
  });

  return router;
};

module.exports = {routerGenerator, services};