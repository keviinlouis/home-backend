const UserModel = require('../../app/models/userModel');
const app = require('../../app/app');
const request = require('supertest')(app);
const jwt = require('jsonwebtoken');

const userDummy = {
    email: 'dummy@mail.com',
    name: 'dummy name',
    password: 'dummy_password'
};

async function createDummyUser() {
    await UserModel.deleteMany({});
    const user = new UserModel(userDummy);
    await user.save();
    return user;
}

describe('Auth Controller', () => {
    describe('login', () => {
        beforeEach(async () => await createDummyUser());

        it('expect login successfully and fetch token', async () => {
            const response = await request
                .post('/login')
                .send(userDummy)

            expect(response.statusCode).toEqual(200);
            expect(response.body).toHaveProperty('token');
            expect(response.body).toHaveProperty('email');
            expect(response.body).toHaveProperty('name');
            expect(response.body.email).toEqual(userDummy.email);
            expect(response.body.name).toEqual(userDummy.name);
        });

        it('expect login unsuccessfully with wrong email', async () => {
            const userWrongDummy = {
                ...userDummy,
                email: 'wrong@email.com'
            };

            const response = await request
                .post('/login')
                .send(userWrongDummy);

            expect(response.statusCode).toEqual(404);
            expect(response.body).not.toHaveProperty('email');
            expect(response.body).not.toHaveProperty('name');
            expect(response.body).not.toHaveProperty('token');
        });

        it('expect login unsuccessfully with wrong password', async () => {
            const userWrongDummy = {
                ...userDummy,
                password: 'wrong_password'
            };

            const response = await request
                .post('/login')
                .send(userWrongDummy);

            expect(response.statusCode).toEqual(401);
            expect(response.body).not.toHaveProperty('email');
            expect(response.body).not.toHaveProperty('name');
            expect(response.body).not.toHaveProperty('token');
        });
    });

    describe('signIn', () => {
        beforeEach(async () => await createDummyUser());
        it('expect sign in successfully and fetch token', async () => {
            const newUserDummy= {
                email: 'dum2my@mail.com',
                name: 'dummy name',
                password: 'dummy_password'
            };
            const response = await request
                .post('/sign-in')
                .send(newUserDummy);

            expect(response.statusCode).toEqual(201);
            expect(response.body).toHaveProperty('token');
            expect(response.body).toHaveProperty('email');
            expect(response.body).toHaveProperty('name');
            expect(response.body.email).toEqual(newUserDummy.email);
            expect(response.body.name).toEqual(newUserDummy.name);
        });

        it('expect sign in unsuccessfully when has duplicate email', async () => {
            const response = await request
                .post('/sign-in')
                .send(userDummy);

            expect(response.statusCode).toEqual(400);
            expect(response.body).not.toHaveProperty('token');
            expect(response.body).not.toHaveProperty('name');
            expect(response.body).toHaveProperty('email');
        });

        it('expect sign in unsuccessfully when has small password', async () => {
            const response = await request
                .post('/sign-in')
                .send({
                    ...userDummy,
                    password: '1'
                });

            expect(response.statusCode).toEqual(400);
            expect(response.body).not.toHaveProperty('token');
            expect(response.body).not.toHaveProperty('name');
            expect(response.body).not.toHaveProperty('email');
            expect(response.body).toHaveProperty('password');
        });

        it('expect sign in unsuccessfully when has small name', async () => {
            const response = await request
                .post('/sign-in')
                .send({
                    ...userDummy,
                    name: 'a'
                });

            expect(response.statusCode).toEqual(400);
            expect(response.body).not.toHaveProperty('token');
            expect(response.body).not.toHaveProperty('email');
            expect(response.body).toHaveProperty('name');
        });
    });
    describe('validateToken', () => {
        it('should return data from user', async function () {
            const user = await createDummyUser();
            const token = user.generateToken();

            const response = await request
                .post('/validate-token')
                .send({
                   token
                });

            expect(response.statusCode).toEqual(200);
            expect(response.body).toHaveProperty('email');
            expect(response.body).toHaveProperty('name');
            expect(response.body.email).toEqual(user.email);
            expect(response.body.name).toEqual(user.name);
        });

        it('should return invalid token', async function () {
            const token = 'invalid token';

            const response = await request
                .post('/validate-token')
                .send({
                    token
                });

            expect(response.statusCode).toEqual(404);
            expect(response.body).toHaveProperty('error');
            expect(response.body.error).toEqual('Usuário não encontrado');
        });

        it('should refresh token', async function () {
            const date = new Date();
            const secret = process.env.JWT_SECRET || 'secret';
            date.setDate(date.getDate()-1);
            const user = await createDummyUser();
            const userData = user.toResponse();
            const payload = {id: user._id.toString(), exp: Math.floor(date / 1000) + (60 * 60)};
            const token = jwt.sign(payload, secret);

            const response = await request
                .post('/validate-token')
                .send({
                    token
                });

            expect(response.statusCode).toEqual(200);
            expect(response.body).toHaveProperty('email');
            expect(response.body).toHaveProperty('name');
            expect(response.body.email).toEqual(user.email);
            expect(response.body.name).toEqual(user.name);
            expect(response.headers["refreshtoken"]).toBeDefined();

            const newToken = response.headers["refreshtoken"];

            const newPayload = jwt.decode(newToken);

            expect(newPayload.id.toString()).toEqual(userData.id.toString());
        });
    });

});

