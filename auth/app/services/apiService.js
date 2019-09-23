const axios = require('axios');

class ApiGateway {
    constructor(url, userId) {
        this.axios = axios.create({
            baseURL: url,
        });

        this.axios.defaults.headers.common['Authorization'] = userId;
    }

    async get(url) {
        const response = await this.axios.get(url);
        return response.data;
    }

    async post(url, data) {
        const response = await this.axios.post(url, data);
        return response.data;
    }

    async put(url, data) {
        const response = await this.axios.put(url, data);
        return response.data;
    }

    async delete(url) {
        const response = await this.axios.delete(url);
        return response.data;
    }
}

module.exports = ApiGateway;

