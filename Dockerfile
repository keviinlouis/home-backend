FROM node:latest

RUN npm i -g nodemon

ENV APP_HOME /home_back
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME

EXPOSE 4000
CMD [ "npm", "start" ]
