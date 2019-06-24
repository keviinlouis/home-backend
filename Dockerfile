FROM node:latest
RUN mkdir -p /home_back
WORKDIR /home_back/

COPY . /home_back/
COPY package.json /usr/src/app/
RUN npm install
COPY . /usr/src/app
RUN npm i -g nodemon
EXPOSE 3000
CMD [ "npm", "start" ]
