const UserModel = require('../../app/models/userModel');
const app = require('../../app/app');
const request = require('supertest')(app);
const faker = require('faker');

const userDummy = {
    email: 'dummy@mail.com',
    name: 'dummy name',
    password: 'dummy_password'
};

async function generateUsers(size = 20){
    await UserModel.deleteMany({});
    const users = [];
    for(let i = 0; i < size; i++){
        const userData = {
            email: faker.internet.email(),
            name: faker.name.findName(),
            password: Math.random() * 10000
        };
        const user = new UserModel(userData);
        await user.save();
        users.push(user)
    }
    return users;
}

describe('User Controller', () => {
    describe('list users', () => {
        it('expect list all users without logged user ', async () => {
            const users = await generateUsers();
            const user = users[0];
            const response = await request
                .get('/user')
                .set('Authorization', `Bearer ${user.generateToken()}`);

            const index = response.body.find(item => item.name === user.name);
            expect(response.statusCode).toEqual(200);
            expect(index).toBe(undefined);
            expect(response.body.length).toBe(users.length - 1)
        });

        it('expect list all users without logged user and deleted user', async () => {
            const users = await generateUsers();
            const user = users[0];
            const deletedUser = users[1];

            await deletedUser.delete();

            const response = await request
                .get('/user')
                .set('Authorization', `Bearer ${user.generateToken()}`);

            const userLoggedInBody = response.body.find(item => item.name === user.name);
            const userDeletedInBody = response.body.find(item => item.name === deletedUser.name);
            expect(response.statusCode).toEqual(200);
            expect(userLoggedInBody).toBe(undefined);
            expect(userDeletedInBody).toBe(undefined);
            expect(response.body.length).toBe(users.length - 2)
        });
    });

    describe('show user', () => {
        it('expect to show user info', async () => {
            const users = await generateUsers();
            const loggedUser = users[0];
            const expectedUser = users[1];
            const response = await request
                .get(`/user/${expectedUser._id}`)
                .set('Authorization', `Bearer ${loggedUser.generateToken()}`);

            expect(response.statusCode).toEqual(200);
            expect(response.body).toHaveProperty('id');
            expect(response.body).toHaveProperty('email');
            expect(response.body).toHaveProperty('name');
            expect(response.body.id).toEqual(expectedUser.id);
            expect(response.body.email).toEqual(expectedUser.email);
            expect(response.body.name).toEqual(expectedUser.name);
        });

        it('expect return 404 when id is wrong', async () => {
            const users = await generateUsers();
            const loggedUser = users[0];
            const response = await request
                .get(`/user/1`)
                .set('Authorization', `Bearer ${loggedUser.generateToken()}`);

            expect(response.statusCode).toEqual(404);
        });

        it('expect return 404 when id is a string', async () => {
            const users = await generateUsers();
            const loggedUser = users[0];
            const response = await request
                .get(`/user/string`)
                .set('Authorization', `Bearer ${loggedUser.generateToken()}`);

            expect(response.statusCode).toEqual(404);
        });

        it('expect return 404 when user is deleted', async () => {
            const users = await generateUsers();
            const loggedUser = users[0];
            const deletedUser = users[1];

            await deletedUser.delete();

            const response = await request
                .get(`/user/${deletedUser._id}`)
                .set('Authorization', `Bearer ${loggedUser.generateToken()}`);

            expect(response.statusCode).toEqual(404);
        });
    });
});

