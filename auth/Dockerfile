FROM node:latest

RUN npm i -g nodemon

ENV APP_HOME /auth
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME

RUN npm i

EXPOSE 4000
CMD [ "npm", "start" ]
